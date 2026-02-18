import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/energy_row_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class EnergyDataSource extends DataGridSource {
  late final List<DataGridRow> _rows;
  EnergyDataSource(List<EnergyRowModel> data) {
    //final List<DataGridRow> rows;
    _rows = data.map<DataGridRow>((e) {
      return DataGridRow(
        cells: [
          DataGridCell(columnName: 'date', value: e.date),
          DataGridCell(columnName: 'runtime_reb', value: e.runtime_reb),
          DataGridCell(columnName: 'energy_reb', value: e.energy_reb),
          DataGridCell(columnName: 'cost_reb', value: e.cost_reb),
          DataGridCell(columnName: 'runtime_diesel', value: e.runtime_diesel),
          DataGridCell(columnName: 'energy_diesel', value: e.energy_diesel),
          DataGridCell(columnName: 'cost_diesel', value: e.cost_diesel),
          DataGridCell(columnName: 'runtime_bess', value: e.runtime_bess),
          DataGridCell(columnName: 'energyIn_bess', value: e.energyIn_bess),
          DataGridCell(columnName: 'energyOut_bess', value: e.energyOut_bess),
        ],
      );
    }).toList();
  }
  @override
  List<DataGridRow> get rows => _rows;
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final index = _rows.indexOf(row);

    final Color bgColor = index % 2 == 0
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
