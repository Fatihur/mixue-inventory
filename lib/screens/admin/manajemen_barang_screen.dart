import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/firestore_service.dart';
import '../../models/barang_model.dart';
import '../../models/kategori_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/barcode_scanner_widget.dart';

class ManajemenBarangScreen extends StatefulWidget {
  const ManajemenBarangScreen({super.key});

  @override
  State<ManajemenBarangScreen> createState() => _ManajemenBarangScreenState();
}

class _ManajemenBarangScreenState extends State<ManajemenBarangScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari barang...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddBarangDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<BarangModel>>(
              stream: _firestoreService.getBarang(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyWidget(
                    message: 'Tidak ada data barang',
                    icon: Icons.inventory_2_outlined,
                  );
                }

                var barangList = snapshot.data!;
                if (_searchQuery.isNotEmpty) {
                  barangList = barangList
                      .where(
                        (b) =>
                            b.nama.toLowerCase().contains(_searchQuery) ||
                            b.barcode.toLowerCase().contains(_searchQuery) ||
                            b.kategori.toLowerCase().contains(_searchQuery),
                      )
                      .toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: barangList.length,
                  itemBuilder: (context, index) {
                    final barang = barangList[index];
                    return _buildBarangCard(barang);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarangCard(BarangModel barang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: barang.isStokRendah
              ? AppColors.warning
              : AppColors.success,
          child: Icon(Icons.inventory_2, color: Colors.white),
        ),
        title: Text(
          barang.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('QR Code: ${barang.barcode}'),
            Text('Kategori: ${barang.kategori}'),
            Text('${barang.pcsPerBox} pcs/box'),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildInfoChip(
                  'Stok: ${barang.stokFormatted}',
                  barang.isStokRendah ? AppColors.warning : AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Helpers.formatCurrency(barang.harga),
                  AppColors.info,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, barang),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Hapus', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleMenuAction(String action, BarangModel barang) {
    switch (action) {
      case 'edit':
        _showEditBarangDialog(context, barang);
        break;
      case 'delete':
        _showDeleteDialog(context, barang);
        break;
    }
  }

  void _showAddBarangDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final barcodeController = TextEditingController();
    final pcsPerBoxController = TextEditingController(text: '1');
    final stokMinimalController = TextEditingController(text: '10');
    String? selectedKategori;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Barang'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // QR Code dengan tombol scan
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: barcodeController,
                          label: 'Barcode',
                          validator: (v) =>
                              Helpers.validateRequired(v, 'Barcode'),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final scannedCode = await _scanQRCode(context);
                          if (scannedCode != null) {
                            setDialogState(() {
                              barcodeController.text = scannedCode;
                            });
                          }
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: namaController,
                    label: 'Nama Barang',
                    validator: (v) => Helpers.validateRequired(v, 'Nama'),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<KategoriModel>>(
                    stream: _firestoreService.getKategori(),
                    builder: (context, snapshot) {
                      final kategoriList = snapshot.data ?? [];
                      if (kategoriList.isEmpty) {
                        return const Text(
                          'Belum ada kategori. Tambahkan kategori terlebih dahulu.',
                          style: TextStyle(color: AppColors.warning, fontSize: 12),
                        );
                      }
                      return CustomDropdown<String>(
                        value: selectedKategori,
                        label: 'Kategori',
                        items: kategoriList
                            .map((k) => DropdownMenuItem(value: k.nama, child: Text(k.nama)))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedKategori = v),
                        validator: (v) => v == null ? 'Pilih kategori' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: pcsPerBoxController,
                    label: 'Jumlah Pcs per Box/Dus',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => Helpers.validateNumber(v, 'Pcs per Box'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: stokMinimalController,
                    label: 'Stok Minimal (per Box/Dus)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => Helpers.validateNumber(v, 'Stok Minimal'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() && selectedKategori != null) {
                  final barang = BarangModel(
                    id: '',
                    nama: namaController.text.trim(),
                    barcode: barcodeController.text.trim(),
                    kategori: selectedKategori!,
                    satuan: 'pcs',
                    stok: 0,
                    stokMinimal: int.parse(stokMinimalController.text),
                    pcsPerBox: int.parse(pcsPerBoxController.text),
                    harga: 0,
                    deskripsi: '',
                    dibuatPada: DateTime.now(),
                    diubahPada: DateTime.now(),
                  );
                  await _firestoreService.addBarang(barang);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Barang berhasil ditambahkan'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _scanQRCode(BuildContext context) async {
    return await showBarcodeScanner(context);
  }

  void _showEditBarangDialog(BuildContext context, BarangModel barang) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: barang.nama);
    final barcodeController = TextEditingController(text: barang.barcode);
    final pcsPerBoxController = TextEditingController(
      text: barang.pcsPerBox.toString(),
    );
    final stokMinimalController = TextEditingController(
      text: barang.stokMinimal.toString(),
    );
    String selectedKategori = barang.kategori;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Barang'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: barcodeController,
                    label: 'QR Code',
                    validator: (v) => Helpers.validateRequired(v, 'QR Code'),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: namaController,
                    label: 'Nama Barang',
                    validator: (v) => Helpers.validateRequired(v, 'Nama'),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<KategoriModel>>(
                    stream: _firestoreService.getKategori(),
                    builder: (context, snapshot) {
                      final kategoriList = snapshot.data ?? [];
                      // Jika kategori barang tidak ada di list, tambahkan
                      final allKategori = kategoriList.map((k) => k.nama).toList();
                      if (!allKategori.contains(selectedKategori) && selectedKategori.isNotEmpty) {
                        allKategori.insert(0, selectedKategori);
                      }
                      return CustomDropdown<String>(
                        value: selectedKategori.isEmpty ? null : selectedKategori,
                        label: 'Kategori',
                        items: allKategori
                            .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedKategori = v ?? ''),
                        validator: (v) => v == null || v.isEmpty ? 'Pilih kategori' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: pcsPerBoxController,
                    label: 'Jumlah Pcs per Box/Dus',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => Helpers.validateNumber(v, 'Pcs per Box'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: stokMinimalController,
                    label: 'Stok Minimal (per Box/Dus)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => Helpers.validateNumber(v, 'Stok Minimal'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await _firestoreService.updateBarang(barang.id, {
                    'nama': namaController.text.trim(),
                    'barcode': barcodeController.text.trim(),
                    'kategori': selectedKategori,
                    'pcs_per_box': int.parse(pcsPerBoxController.text),
                    'stok_minimal': int.parse(stokMinimalController.text),
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Barang berhasil diupdate'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, BarangModel barang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus ${barang.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.deleteBarang(barang.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Barang berhasil dihapus'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
