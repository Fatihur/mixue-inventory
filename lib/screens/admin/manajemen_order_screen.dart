import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';
import '../../models/barang_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class ManajemenOrderScreen extends StatefulWidget {
  const ManajemenOrderScreen({super.key});

  @override
  State<ManajemenOrderScreen> createState() => _ManajemenOrderScreenState();
}

class _ManajemenOrderScreenState extends State<ManajemenOrderScreen> {
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
                  'Daftar Order',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddOrderDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Buat Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: _firestoreService.getOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyWidget(
                    message: 'Tidak ada data order',
                    icon: Icons.shopping_cart_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final order = snapshot.data![index];
                    return _buildOrderCard(order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor;
    switch (order.status) {
      case 'selesai':
        statusColor = AppColors.success;
        break;
      case 'diproses':
        statusColor = AppColors.info;
        break;
      case 'dibatalkan':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.receipt, color: statusColor),
        ),
        title: Text(order.nomorOrder, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Helpers.formatDateTime(order.tanggal)),
            Text(Helpers.formatCurrency(order.totalHarga),
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            Helpers.capitalize(order.status),
            style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.namaBarang} x${item.jumlah}'),
                      Text(Helpers.formatCurrency(item.subtotal)),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(Helpers.formatCurrency(order.totalHarga),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order.status == 'pending') ...[
                      TextButton(
                        onPressed: () => _updateOrderStatus(order.id, 'diproses'),
                        child: const Text('Proses'),
                      ),
                      TextButton(
                        onPressed: () => _updateOrderStatus(order.id, 'dibatalkan'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Batalkan'),
                      ),
                    ],
                    if (order.status == 'diproses')
                      TextButton(
                        onPressed: () => _updateOrderStatus(order.id, 'selesai'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.success),
                        child: const Text('Selesaikan'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(String orderId, String status) async {
    await _firestoreService.updateOrder(orderId, {'status': status});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status order diubah ke $status'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showAddOrderDialog(BuildContext context) {
    final authProvider = context.read<app_auth.AuthProvider>();
    List<OrderItemModel> orderItems = [];
    final keteranganController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          double totalHarga = orderItems.fold(0, (sum, item) => sum + item.subtotal);

          return AlertDialog(
            title: const Text('Buat Order Baru'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showSelectBarangDialog(context, (item) {
                        setDialogState(() => orderItems.add(item));
                      }),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Item'),
                    ),
                    const SizedBox(height: 16),
                    if (orderItems.isNotEmpty) ...[
                      const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...orderItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.namaBarang),
                          subtitle: Text('${item.jumlah} x ${Helpers.formatCurrency(item.harga)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(Helpers.formatCurrency(item.subtotal)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () => setDialogState(() => orderItems.removeAt(index)),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(Helpers.formatCurrency(totalHarga),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: keteranganController,
                      label: 'Keterangan',
                      maxLines: 2,
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
                onPressed: orderItems.isEmpty ? null : () async {
                  final nomorOrder = await _firestoreService.generateOrderNumber();
                  final order = OrderModel(
                    id: '',
                    nomorOrder: nomorOrder,
                    items: orderItems,
                    totalHarga: totalHarga,
                    status: 'pending',
                    keterangan: keteranganController.text.trim(),
                    userId: authProvider.user?.uid ?? '',
                    namaUser: authProvider.user?.nama ?? '',
                    tanggal: DateTime.now(),
                  );
                  await _firestoreService.addOrder(order);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order berhasil dibuat'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSelectBarangDialog(BuildContext context, Function(OrderItemModel) onSelect) {
    final jumlahController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Barang'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<List<BarangModel>>(
            stream: _firestoreService.getBarang(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LoadingWidget();

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final barang = snapshot.data![index];
                  return ListTile(
                    title: Text(barang.nama),
                    subtitle: Text('Stok: ${barang.stok} | ${Helpers.formatCurrency(barang.harga)}'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Jumlah ${barang.nama}'),
                          content: CustomTextField(
                            controller: jumlahController,
                            label: 'Jumlah',
                            keyboardType: TextInputType.number,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final jumlah = int.tryParse(jumlahController.text) ?? 1;
                                final item = OrderItemModel(
                                  barangId: barang.id,
                                  namaBarang: barang.nama,
                                  jumlah: jumlah,
                                  harga: barang.harga,
                                  subtotal: barang.harga * jumlah,
                                );
                                onSelect(item);
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                              },
                              child: const Text('Tambah'),
                            ),
                          ],
                        ),
                      );
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
