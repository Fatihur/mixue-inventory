import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/barang_masuk_model.dart';
import '../../models/barang_terpakai_model.dart';
import '../../models/barang_expired_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';

class HistoriTransaksiScreen extends StatefulWidget {
  const HistoriTransaksiScreen({super.key});

  @override
  State<HistoriTransaksiScreen> createState() => _HistoriTransaksiScreenState();
}

class _HistoriTransaksiScreenState extends State<HistoriTransaksiScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Barang Masuk'),
              Tab(text: 'Terpakai'),
              Tab(text: 'Expired'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBarangMasukTab(),
              _buildBarangTerpakaiTab(),
              _buildBarangExpiredTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarangMasukTab() {
    return StreamBuilder<List<BarangMasukModel>>(
      stream: _firestoreService.getBarangMasuk(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyWidget(
            message: 'Tidak ada histori barang masuk',
            icon: Icons.inbox_outlined,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return _buildTransaksiCard(
              title: item.namaBarang,
              subtitle: 'Jumlah: +${item.jumlah}',
              tanggal: item.tanggal,
              user: item.namaUser,
              keterangan: item.keterangan,
              color: AppColors.success,
              icon: Icons.add_circle,
            );
          },
        );
      },
    );
  }

  Widget _buildBarangTerpakaiTab() {
    return StreamBuilder<List<BarangTerpakaiModel>>(
      stream: _firestoreService.getBarangTerpakai(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyWidget(
            message: 'Tidak ada histori barang terpakai',
            icon: Icons.inbox_outlined,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return _buildTransaksiCard(
              title: item.namaBarang,
              subtitle: 'Jumlah: -${item.jumlah}',
              tanggal: item.tanggal,
              user: item.namaUser,
              keterangan: item.keterangan,
              color: AppColors.info,
              icon: Icons.remove_circle,
            );
          },
        );
      },
    );
  }

  Widget _buildBarangExpiredTab() {
    return StreamBuilder<List<BarangExpiredModel>>(
      stream: _firestoreService.getBarangExpired(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyWidget(
            message: 'Tidak ada histori barang expired',
            icon: Icons.inbox_outlined,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return _buildTransaksiCard(
              title: item.namaBarang,
              subtitle: 'Jumlah: -${item.jumlah} (Expired: ${Helpers.formatDate(item.tanggalExpired)})',
              tanggal: item.tanggalInput,
              user: item.namaUser,
              keterangan: item.keterangan,
              color: AppColors.warning,
              icon: Icons.warning,
            );
          },
        );
      },
    );
  }

  Widget _buildTransaksiCard({
    required String title,
    required String subtitle,
    required DateTime tanggal,
    required String user,
    required String keterangan,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
            Text('Oleh: $user'),
            Text(Helpers.formatDateTime(tanggal), style: const TextStyle(fontSize: 12)),
            if (keterangan.isNotEmpty)
              Text('Ket: $keterangan', style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
