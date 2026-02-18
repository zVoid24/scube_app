import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EnergyGridScreen(),
    );
  }
}

// ================= SCREEN =================

class EnergyGridScreen extends StatelessWidget {
  const EnergyGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final source = EnergyDataSource(_buildRows());

    return Scaffold(
      appBar: AppBar(title: const Text('Energy Report')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SfDataGrid(
          source: source,
          columnWidthMode: ColumnWidthMode.fill,
          frozenColumnsCount: 2, // 🔥 Date + Unit FIXED
          headerRowHeight: 42,
          rowHeight: 34,
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          columns: [
            GridColumn(columnName: 'date', label: _header('Date'), width: 90),
            GridColumn(columnName: 'unit', label: _header('Unit'), width: 70),
            GridColumn(
              columnName: 'total',
              label: _header('Total Energy & Cost'),
              width: 200,
            ),
            GridColumn(
              columnName: 'reb',
              label: _header('REB Energy & Cost'),
              width: 200,
            ),
            GridColumn(
              columnName: 'solar',
              label: _header('Solar Energy & Cost'),
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _header(String text) {
    return Container(
      alignment: Alignment.center,
      color: const Color(0xFF5E6C8A),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  static List<EnergyRow> _buildRows() {
    final List<EnergyRow> rows = [];

    for (int i = 0; i < 8; i++) {
      rows.add(
        EnergyRow(
          date: '01 Dec 24',
          unit: 'kWh',
          total: '2000',
          reb: '2000',
          solar: '2000',
          isTk: false,
        ),
      );
      rows.add(
        EnergyRow(
          date: '',
          unit: '৳',
          total: '2598257/10.2',
          reb: '2598257/10.2',
          solar: '2598257/10.2',
          isTk: true,
        ),
      );
    }

    return rows;
  }
}

// ================= DATA MODEL =================

class EnergyRow {
  EnergyRow({
    required this.date,
    required this.unit,
    required this.total,
    required this.reb,
    required this.solar,
    required this.isTk,
  });

  final String date;
  final String unit;
  final String total;
  final String reb;
  final String solar;
  final bool isTk;
}

// ================= DATA SOURCE =================

class EnergyDataSource extends DataGridSource {
  EnergyDataSource(List<EnergyRow> data) {
    _rows = data.map<DataGridRow>((e) {
      return DataGridRow(
        cells: [
          DataGridCell(columnName: 'date', value: e.date),
          DataGridCell(columnName: 'unit', value: e.unit),
          DataGridCell(columnName: 'total', value: e.total),
          DataGridCell(columnName: 'reb', value: e.reb),
          DataGridCell(columnName: 'solar', value: e.solar),
        ],
      );
    }).toList();

    _rowMeta = data;
  }

  late final List<DataGridRow> _rows;
  late final List<EnergyRow> _rowMeta;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final index = _rows.indexOf(row);
    final meta = _rowMeta[index];

    final Color bgColor = meta.isTk
        ? const Color(0xFFE0E1FF)
        : const Color(0xFFF2F3FF);

    return DataGridRowAdapter(
      color: bgColor,
      cells: row.getCells().map((cell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(cell.value.toString()),
        );
      }).toList(),
    );
  }
}
