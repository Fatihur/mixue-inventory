import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../services/firestore_service.dart';
import '../../models/barang_model.dart';
import '../../models/barang_expired_model.dart';
import '../../models/kategori_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/barcode_scanner_widget.dart';

class BarangExpiredScreen extends StatefulWidget {
  const BarangExpiredScreen({super.key});

  @override
  State<BarangExpiredScreen> createState() => _BarangExpiredScreenState();
}

class _BarangExpiredScreenState extends State<BarangExpiredScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();

  BarangModel? _selectedBarang;
  String _selectedKategori = 'Semua';
  DateTime _tanggalExpired = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Input Barang Expired',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Catat barang yang sudah expired',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              _buildScanButton(),
              const SizedBox(height: 16),
              _buildKategoriFilter(),
              const SizedBox(height: 16),
              _buildBarangSelector(),
              const SizedBox(height: 16),
              if (_selectedBarang != null) _buildSelectedBarangInfo(),
              const SizedBox(height: 16),
              _buildTanggalExpiredPicker(),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _jumlahController,
                label: 'Jumlah Expired (Box)',
                hint: _selectedBarang != null
                    ? '1 box = ${_selectedBarang!.pcsPerBox} pcs'
                    : null,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final error = Helpers.validateNumber(v, 'Jumlah');
                  if (error != null) return error;
                  if (_selectedBarang != null) {
                    final jumlahBox = int.tryParse(v ?? '0') ?? 0;
                    final jumlahPcs = jumlahBox * _selectedBarang!.pcsPerBox;
                    if (jumlahPcs > _selectedBarang!.stok) {
                      return 'Jumlah melebihi stok (${_selectedBarang!.jumlahBox} box)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _keteranganController,
                label: 'Keterangan (opsional)',
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Simpan Barang Expired',
                onPressed: _saveBarangExpired,
                isLoading: _isLoading,
                icon: Icons.save,
                backgroundColor: AppColors.warning,
              ),
              const SizedBox(height: 24),
              _buildRecentHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return CustomOutlinedButton(
      text: 'Scan QR Code',
      icon: Icons.qr_code_scanner,
      onPressed: _scanBarcode,
    );
  }

  Widget _buildKategoriFilter() {
    return StreamBuilder<List<KategoriModel>>(
      stream: _firestoreService.getKategori(),
      builder: (context, snapshot) {
        final kategoriList = snapshot.data ?? [];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Semua'),
              ...kategoriList.map((k) => _buildFilterChip(k.nama)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String kategori) {
    final isSelected = _selectedKategori == kategori;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(kategori),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedKategori = kategori;
            _selectedBarang = null;
          });
        },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildBarangSelector() {
    return StreamBuilder<List<BarangModel>>(
      stream: _firestoreService.getBarang(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CustomTextField(label: 'Pilih Barang', enabled: false);
        }

        var barangList = snapshot.data!;
        if (_selectedKategori != 'Semua') {
          barangList = barangList.where((b) => b.kategori == _selectedKategori).toList();
        }

        return CustomDropdown<String>(
          value: _selectedBarang?.id,
          label: 'Pilih Barang',
          items: barangList
              .map(
                (b) => DropdownMenuItem(
                  value: b.id,
                  child: Text('${b.nama} (Stok: ${b.stok})'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedBarang = snapshot.data!.firstWhere(
                  (b) => b.id == value,
                );
              });
            }
          },
          validator: (v) => v == null ? 'Pilih barang' : null,
        );
      },
    );
  }

  Widget _buildSelectedBarangInfo() {
    return Card(
      color: AppColors.warning.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedBarang!.nama,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('QR Code: ${_selectedBarang!.barcode}'),
            Text('Kategori: ${_selectedBarang!.kategori}'),
            Text('${_selectedBarang!.pcsPerBox} pcs/box'),
            Text('Stok Saat Ini: ${_selectedBarang!.stokFormatted}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTanggalExpiredPicker() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppColors.warning),
        title: const Text('Tanggal Expired'),
        subtitle: Text(Helpers.formatDate(_tanggalExpired)),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _tanggalExpired,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            setState(() => _tanggalExpired = date);
          }
        },
      ),
    );
  }

  Widget _buildRecentHistory() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Riwayat Barang Expired Hari Ini',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          StreamBuilder<List<BarangExpiredModel>>(
            stream: _firestoreService.getBarangExpired(
              startDate: Helpers.startOfDay(DateTime.now()),
              endDate: Helpers.endOfDay(DateTime.now()),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Belum ada data hari ini'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length > 5
                    ? 5
                    : snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.warning,
                      child: Icon(Icons.warning, color: Colors.white),
                    ),
                    title: Text(item.namaBarang),
                    subtitle: Text(
                      '-${item.jumlah} box | Exp: ${Helpers.formatDate(item.tanggalExpired)}',
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode() async {
    final result = await showBarcodeScanner(context);

    if (result != null && mounted) {
      final barang = await _firestoreService.getBarangByBarcode(result);
      if (mounted) {
        if (barang != null) {
          setState(() => _selectedBarang = barang);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Barang ditemukan: ${barang.nama}'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Barang tidak ditemukan'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveBarangExpired() async {
    if (_formKey.currentState!.validate() && _selectedBarang != null) {
      setState(() => _isLoading = true);

      final authProvider = context.read<app_auth.AuthProvider>();
      final barangExpired = BarangExpiredModel(
        id: '',
        barangId: _selectedBarang!.id,
        namaBarang: _selectedBarang!.nama,
        jumlah: int.parse(_jumlahController.text),
        keterangan: _keteranganController.text.trim(),
        userId: authProvider.user?.uid ?? '',
        namaUser: authProvider.user?.nama ?? '',
        tanggalExpired: _tanggalExpired,
        tanggalInput: DateTime.now(),
      );

      try {
        await _firestoreService.addBarangExpired(barangExpired);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Barang expired berhasil disimpan'),
              backgroundColor: AppColors.success,
            ),
          );
          _jumlahController.clear();
          _keteranganController.clear();
          setState(() {
            _selectedBarang = null;
            _tanggalExpired = DateTime.now();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }

      setState(() => _isLoading = false);
    }
  }
}
