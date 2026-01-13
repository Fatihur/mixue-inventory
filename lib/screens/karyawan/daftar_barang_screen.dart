import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/barang_model.dart';
import '../../models/kategori_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';

class DaftarBarangScreen extends StatefulWidget {
  const DaftarBarangScreen({super.key});

  @override
  State<DaftarBarangScreen> createState() => _DaftarBarangScreenState();
}

class _DaftarBarangScreenState extends State<DaftarBarangScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';
  String _selectedKategori = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
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
                const SizedBox(height: 12),
                StreamBuilder<List<KategoriModel>>(
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
                            b.barcode.toLowerCase().contains(_searchQuery),
                      )
                      .toList();
                }

                if (_selectedKategori != 'Semua') {
                  barangList = barangList
                      .where((b) => b.kategori == _selectedKategori)
                      .toList();
                }

                if (barangList.isEmpty) {
                  return const EmptyWidget(
                    message: 'Tidak ada barang ditemukan',
                    icon: Icons.search_off,
                  );
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

  Widget _buildFilterChip(String kategori) {
    final isSelected = _selectedKategori == kategori;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(kategori),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedKategori = kategori);
        },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
        checkmarkColor: Colors.white,
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
              ? AppColors.warning.withOpacity(0.2)
              : AppColors.success.withOpacity(0.2),
          child: Icon(
            Icons.inventory_2,
            color: barang.isStokRendah ? AppColors.warning : AppColors.success,
          ),
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
            const SizedBox(height: 8),
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
            if (barang.isStokRendah) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      'Stok Rendah! (Min: ${barang.stokMinimal} box)',
                      style: TextStyle(fontSize: 12, color: AppColors.warning),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        onTap: () => _showBarangDetail(context, barang),
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

  void _showBarangDetail(BuildContext context, BarangModel barang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: barang.isStokRendah
                      ? AppColors.warning.withOpacity(0.2)
                      : AppColors.success.withOpacity(0.2),
                  child: Icon(
                    Icons.inventory_2,
                    size: 30,
                    color: barang.isStokRendah
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barang.nama,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        barang.kategori,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('QR Code', barang.barcode),
            _buildDetailRow('Pcs per Box', '${barang.pcsPerBox} pcs'),
            _buildDetailRow('Stok', barang.stokFormatted),
            _buildDetailRow('Stok Minimal', '${barang.stokMinimal} box'),
            _buildDetailRow('Harga', Helpers.formatCurrency(barang.harga)),
            if (barang.deskripsi.isNotEmpty)
              _buildDetailRow('Deskripsi', barang.deskripsi),
            _buildDetailRow(
              'Terakhir Update',
              Helpers.formatDateTime(barang.diubahPada),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
