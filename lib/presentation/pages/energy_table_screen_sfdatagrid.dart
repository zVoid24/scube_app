import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/energy_row_model.dart';
import 'package:flutter_application_1/data/source/energy_data_source.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class EnergyTableScreenSfdatagrid extends StatelessWidget {
  const EnergyTableScreenSfdatagrid({super.key});

  @override
  Widget build(BuildContext context) {
    final source = EnergyDataSource(_buildRows());
    return Scaffold(
      appBar: AppBar(title: const Text("Analysis Pro"), centerTitle: true),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: SfDataGrid(
          source: source,
          frozenColumnsCount: 1,
          columnWidthMode: ColumnWidthMode.fitByCellValue,
          headerRowHeight: 42,
          rowHeight: 34,
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          columns: [
            GridColumn(columnName: 'date', label: _header('Date')),

            GridColumn(
              columnName: 'runtime_reb',
              label: _header('Runtime'),
              // width: 90,
            ),
            GridColumn(
              columnName: 'energy_reb',
              label: _header('Energy (kWh)'),
              // width: 90,
            ),
            GridColumn(
              columnName: 'cost_reb',
              label: _header('Cost'),
              // width: 90,
            ),
            GridColumn(
              columnName: 'runtime_diesel',
              label: _header('Runtime'),
              // width: 90,
            ),
            GridColumn(
              columnName: 'energy_diesel',
              label: _header("Energy (kWh)"),
              // width: 90,
            ),
            GridColumn(
              columnName: 'cost_diesel',
              label: _header('Cost'),
              // width: 90,
            ),
            GridColumn(
              columnName: 'runtime_bess',
              label: _header('Runtime'),
              // width: 90,
            ),
            GridColumn(
              columnName: 'energyIn_bess',
              label: _header('Energy In (kWh)'),
              // width: 90,
            ),
            GridColumn(
              columnName: 'energyOut_bess',
              label: _header('Energy Out (kWh)'),
              // width: 90,
            ),
          ],
          stackedHeaderRows: [
            StackedHeaderRow(
              cells: [
                // // IMPORTANT: cover the frozen 'date' column
                // StackedHeaderCell(
                //   columnNames: ['date'],
                //   child: _header('Date'),
                // ),
                StackedHeaderCell(
                  columnNames: ['runtime_reb', 'energy_reb', 'cost_reb'],
                  child: _header('REB'),
                ),
                StackedHeaderCell(
                  columnNames: [
                    'runtime_diesel',
                    'energy_diesel',
                    'cost_diesel',
                  ],
                  child: _header('Diesel Generator'),
                ),
                StackedHeaderCell(
                  columnNames: [
                    'runtime_bess',
                    'energyIn_bess',
                    'energyOut_bess',
                  ],
                  child: _header('BESS'),
                ),
              ],
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

  static List<EnergyRowModel> _buildRows() {
    final List<EnergyRowModel> rows = [];
    for (int i = 0; i < 20; i++) {
      rows.add(
        EnergyRowModel(
          date: '01-03-24',
          runtime_reb: '10:45',
          energy_reb: '6840.65',
          cost_reb: '587434',
          runtime_diesel: '10:45',
          energy_diesel: '6840.65',
          cost_diesel: '587434',
          runtime_bess: '10:45',
          energyIn_bess: '556666',
          energyOut_bess: '55555',
        ),
      );
    }
    return rows;
  }
}
