import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../services/firestore_service.dart';
import '../../models/refund_model.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class ManajemenRefundScreen extends StatefulWidget {
  const ManajemenRefundScreen({super.key});

  @override
  State<ManajemenRefundScreen> createState() => _ManajemenRefundScreenState();
}

class _ManajemenRefundScreenState extends State<ManajemenRefundScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Refund',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddRefundDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Buat Refund'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<RefundModel>>(
              stream: _firestoreService.getRefunds(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyWidget(
                    message: 'Tidak ada data refund',
                    icon: Icons.assignment_return_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final refund = snapshot.data![index];
                    return _buildRefundCard(refund);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundCard(RefundModel refund) {
    Color statusColor;
    switch (refund.status) {
      case 'disetujui':
      case 'selesai':
        statusColor = AppColors.success;
        break;
      case 'ditolak':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.assignment_return, color: statusColor),
        ),
        title: Text(
          'Refund: ${refund.nomorOrder}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Alasan: ${refund.alasan}'),
            Text('Jumlah: ${Helpers.formatCurrency(refund.jumlahRefund)}'),
            Text(Helpers.formatDateTime(refund.tanggal)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                Helpers.capitalize(refund.status),
                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        trailing: refund.status == 'pending'
            ? PopupMenuButton<String>(
                onSelected: (value) => _handleStatusChange(refund, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'disetujui', child: Text('Setujui')),
                  const PopupMenuItem(value: 'ditolak', child: Text('Tolak')),
                ],
              )
            : null,
      ),
    );
  }

  void _handleStatusChange(RefundModel refund, String status) async {
    await _firestoreService.updateRefund(refund.id, {'status': status});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Refund $status'),
          backgroundColor: status == 'disetujui' ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _showAddRefundDialog(BuildContext context) {
    final authProvider = context.read<app_auth.AuthProvider>();
    final alasanController = TextEditingController();
    final jumlahController = TextEditingController();
    OrderModel? selectedOrder;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Buat Refund Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => _showSelectOrderDialog(context, (order) {
                    setDialogState(() {
                      selectedOrder = order;
                      jumlahController.text = order.totalHarga.toInt().toString();
                    });
                  }),
                  child: Text(selectedOrder?.nomorOrder ?? 'Pilih Order'),
                ),
                const SizedBox(height: 16),
                if (selectedOrder != null) ...[
                  Text('Total Order: ${Helpers.formatCurrency(selectedOrder!.totalHarga)}'),
                  const SizedBox(height: 16),
                ],
                CustomTextField(
                  controller: jumlahController,
                  label: 'Jumlah Refund',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: alasanController,
                  label: 'Alasan Refund',
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: selectedOrder == null ? null : () async {
                final refund = RefundModel(
                  id: '',
                  orderId: selectedOrder!.id,
                  nomorOrder: selectedOrder!.nomorOrder,
                  alasan: alasanController.text.trim(),
                  jumlahRefund: double.tryParse(jumlahController.text) ?? 0,
                  status: 'pending',
                  userId: authProvider.user?.uid ?? '',
                  namaUser: authProvider.user?.nama ?? '',
                  tanggal: DateTime.now(),
                );
                await _firestoreService.addRefund(refund);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Refund berhasil dibuat'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectOrderDialog(BuildContext context, Function(OrderModel) onSelect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Order'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<List<OrderModel>>(
            stream: _firestoreService.getOrders(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LoadingWidget();

              final orders = snapshot.data!.where((o) => o.status == 'selesai').toList();
              if (orders.isEmpty) {
                return const Center(child: Text('Tidak ada order yang bisa di-refund'));
              }

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text(order.nomorOrder),
                    subtitle: Text(Helpers.formatCurrency(order.totalHarga)),
                    onTap: () {
                      onSelect(order);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
