import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/firestore_service.dart';
import '../../models/barang_model.dart';
import '../../models/barang_masuk_model.dart';
import '../../models/barang_terpakai_model.dart';
import '../../models/barang_expired_model.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedPeriod = 'harian';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Laporan Inventory',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 24),
            _buildExportButtons(),
            const SizedBox(height: 24),
            _buildLaporanContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _buildPeriodChip('Harian', 'harian'),
            _buildPeriodChip('Mingguan', 'mingguan'),
            _buildPeriodChip('Bulanan', 'bulanan'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedPeriod = value);
          },
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(color: isSelected ? Colors.white : null),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(Helpers.formatDate(_selectedDate)),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (date != null) setState(() => _selectedDate = date);
        },
      ),
    );
  }

  Widget _buildExportButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _exportToPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _exportToCsv,
            icon: const Icon(Icons.table_chart),
            label: const Text('Export CSV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLaporanContent() {
    return Column(
      children: [
        _buildStokBarangCard(),
        const SizedBox(height: 16),
        _buildRingkasanCard(),
      ],
    );
  }

  Widget _buildStokBarangCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Stok Barang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          StreamBuilder<List<BarangModel>>(
            stream: _firestoreService.getBarang(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(32), child: LoadingWidget());

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('Kategori')),
                    DataColumn(label: Text('Stok'), numeric: true),
                    DataColumn(label: Text('Satuan')),
                    DataColumn(label: Text('Harga'), numeric: true),
                  ],
                  rows: snapshot.data!.map((b) => DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>((states) =>
                        b.isStokRendah ? AppColors.warning.withOpacity(0.1) : null),
                    cells: [
                      DataCell(Text(b.nama)),
                      DataCell(Text(b.kategori)),
                      DataCell(Text(b.stok.toString())),
                      DataCell(Text(b.satuan)),
                      DataCell(Text(Helpers.formatCurrency(b.harga))),
                    ],
                  )).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanCard() {
    final dateRange = _getDateRange();
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan Periode ${Helpers.capitalize(_selectedPeriod)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<List<BarangMasukModel>>(
              stream: _firestoreService.getBarangMasuk(startDate: dateRange['start'], endDate: dateRange['end']),
              builder: (context, snapshotMasuk) {
                return StreamBuilder<List<BarangTerpakaiModel>>(
                  stream: _firestoreService.getBarangTerpakai(startDate: dateRange['start'], endDate: dateRange['end']),
                  builder: (context, snapshotTerpakai) {
                    return StreamBuilder<List<BarangExpiredModel>>(
                      stream: _firestoreService.getBarangExpired(startDate: dateRange['start'], endDate: dateRange['end']),
                      builder: (context, snapshotExpired) {
                        return StreamBuilder<List<OrderModel>>(
                          stream: _firestoreService.getOrders(startDate: dateRange['start'], endDate: dateRange['end']),
                          builder: (context, snapshotOrder) {
                            final totalMasuk = snapshotMasuk.data?.fold(0, (sum, item) => sum + item.jumlah) ?? 0;
                            final totalTerpakai = snapshotTerpakai.data?.fold(0, (sum, item) => sum + item.jumlah) ?? 0;
                            final totalExpired = snapshotExpired.data?.fold(0, (sum, item) => sum + item.jumlah) ?? 0;
                            final totalOrder = snapshotOrder.data?.length ?? 0;
                            final totalPendapatan = snapshotOrder.data
                                ?.where((o) => o.status == 'selesai')
                                .fold(0.0, (sum, o) => sum + o.totalHarga) ?? 0.0;

                            return Column(
                              children: [
                                _buildRingkasanRow('Barang Masuk', '$totalMasuk item', AppColors.success),
                                _buildRingkasanRow('Barang Terpakai', '$totalTerpakai item', AppColors.info),
                                _buildRingkasanRow('Barang Expired', '$totalExpired item', AppColors.warning),
                                _buildRingkasanRow('Total Order', '$totalOrder order', AppColors.primary),
                                _buildRingkasanRow('Total Pendapatan', Helpers.formatCurrency(totalPendapatan), AppColors.success),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Map<String, DateTime> _getDateRange() {
    DateTime start, end;
    switch (_selectedPeriod) {
      case 'mingguan':
        start = Helpers.startOfWeek(_selectedDate);
        end = start.add(const Duration(days: 7));
        break;
      case 'bulanan':
        start = Helpers.startOfMonth(_selectedDate);
        end = Helpers.endOfMonth(_selectedDate);
        break;
      default:
        start = Helpers.startOfDay(_selectedDate);
        end = Helpers.endOfDay(_selectedDate);
    }
    return {'start': start, 'end': end};
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Inventory Mixue',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Periode: ${Helpers.capitalize(_selectedPeriod)}'),
              pw.Text('Tanggal: ${Helpers.formatDate(_selectedDate)}'),
              pw.SizedBox(height: 24),
              pw.Text('Diekspor pada: ${Helpers.formatDateTime(DateTime.now())}'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _exportToCsv() async {
    List<List<dynamic>> rows = [
      ['Laporan Inventory Mixue'],
      ['Periode', Helpers.capitalize(_selectedPeriod)],
      ['Tanggal', Helpers.formatDate(_selectedDate)],
      [],
    ];

    String csv = const ListToCsvConverter().convert(rows);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/laporan_mixue_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    
    await Share.shareXFiles([XFile(file.path)], text: 'Laporan Inventory Mixue');
  }
}
