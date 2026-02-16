import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/services/styles/excel_styles.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class ExcelLayout {
  static Future<void> addLogo(Worksheet sheet, Workbook workbook) async {
    sheet.getRangeByName('A1:B4').merge();

    for (int i = 1; i <= 4; i++) {
      sheet.getRangeByIndex(i, 1).rowHeight = 22;
    }

    final ByteData data = await rootBundle.load('assets/Logo-scube.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final picture = sheet.pictures.addStream(1, 1, bytes);
    picture.height = 110;
    picture.width = 200;
  }

  static void addInfoRow(
    Worksheet sheet,
    Workbook workbook,
    int row,
    String label,
    String value,
  ) {
    sheet.getRangeByName('C$row:D$row').merge();
    final labelCell = sheet.getRangeByIndex(row, 3);
    labelCell.setText(label);
    labelCell.cellStyle = ExcelStyles.infoLabel(workbook);

    sheet.getRangeByName('E$row:F$row').merge();
    final valueCell = sheet.getRangeByIndex(row, 5);
    valueCell.setText(value);
    valueCell.cellStyle = ExcelStyles.infoValue(workbook);
  }

  static void addTable(
    Worksheet sheet,
    Workbook workbook, {
    required int startRow,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    // headers
    for (int c = 0; c < headers.length; c++) {
      final cell = sheet.getRangeByIndex(startRow, c + 1);
      cell.setText(headers[c]);
      cell.cellStyle = ExcelStyles.header(workbook);
    }

    // data
    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < rows[r].length; c++) {
        final cell = sheet.getRangeByIndex(startRow + 1 + r, c + 1);
        cell.setText(rows[r][c]);
        cell.cellStyle = ExcelStyles.tableCell(workbook);
      }
    }
  }

  static void addFooter(
    Worksheet sheet,
    Workbook workbook,
    int row,
    int colSpan,
  ) {
    sheet.getRangeByName('A$row:D$row').merge();
    final cell = sheet.getRangeByIndex(row, 1);
    cell.setText(
      'Data Source : UMS  |  Powered by : Scube Technologies Limited',
    );
    cell.cellStyle = ExcelStyles.footer(workbook);
  }
}
