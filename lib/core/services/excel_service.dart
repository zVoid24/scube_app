import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../utils/file_helper.dart';

class ExcelService {
  static Future<void> generate({
    required List<String> headers,
    required List<List<String>> rows,
    required String projectName,
    required String address,
    required String userName,
  }) async {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Project Information';

    /// ─────────────────────────────
    /// Column widths
    /// ─────────────────────────────
    /// ─────────────────────────────
    /// Column widths (SAFE WAY)
    /// ─────────────────────────────
    sheet.getRangeByIndex(1, 1).columnWidth = 18; // A
    sheet.getRangeByIndex(1, 2).columnWidth = 18; // B
    sheet.getRangeByIndex(1, 3).columnWidth = 18; // C
    sheet.getRangeByIndex(1, 4).columnWidth = 18; // D
    sheet.getRangeByIndex(1, 5).columnWidth = 22; // E
    sheet.getRangeByIndex(1, 6).columnWidth = 22; // F
    sheet.getRangeByIndex(1, 7).columnWidth = 22; // G
    sheet.getRangeByIndex(1, 8).columnWidth = 22; // H

    /// ─────────────────────────────
    /// LOGO (A1:D5)
    /// ─────────────────────────────
    sheet.getRangeByName('A1:B4').merge();
    for (int i = 1; i < 5; i++) {
      sheet.getRangeByIndex(i, 1).rowHeight = 22;
    }

    final ByteData logoData = await rootBundle.load('assets/Logo-scube.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final picture = sheet.pictures.addStream(1, 1, logoBytes);
    picture.height = 110;
    picture.width = 200;

    // // Anchor image strictly to cell
    // picture.moveWithCells = true;
    // picture.sizeWithCells = false;

    /// ─────────────────────────────
    /// PROJECT INFO (E1:H5)
    /// ─────────────────────────────
    _infoRow(sheet, 'C1', 'Project Name', projectName);
    _infoRow(sheet, 'C2', 'Address', address);
    _infoRow(sheet, 'C3', 'Printed Date & Time', DateTime.now().toString());
    _infoRow(sheet, 'C4', 'User Name', userName);

    /// ─────────────────────────────
    /// TABLE HEADER (Dynamic)
    /// ─────────────────────────────
    final headerRowIndex = 6;

    for (int col = 0; col < headers.length; col++) {
      final cell = sheet.getRangeByIndex(headerRowIndex, col + 1);
      cell.setText(headers[col]);
      cell.cellStyle
        ..bold = true
        ..backColor = '#D9E1F2'
        ..borders.all.lineStyle = LineStyle.thin
        ..hAlign = HAlignType.center;
    }

    /// ─────────────────────────────
    /// TABLE DATA (Dynamic)
    /// ─────────────────────────────
    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final excelRow = headerRowIndex + 1 + rowIndex;

      for (int colIndex = 0; colIndex < rows[rowIndex].length; colIndex++) {
        final cell = sheet.getRangeByIndex(excelRow, colIndex + 1);
        cell.setText(rows[rowIndex][colIndex]);
        cell.cellStyle.hAlign = HAlignType.center;
        cell.cellStyle.borders.all.lineStyle = LineStyle.thin;
      }
    }

    /// ─────────────────────────────
    /// FOOTER
    /// ─────────────────────────────
    final footerRow = headerRowIndex + rows.length + 2;

    // Merge footer across table width
    sheet.getRangeByName('A$footerRow:D$footerRow').merge();

    final footerCell = sheet.getRangeByIndex(footerRow, 1);
    footerCell.setText(
      'Data Source : UMS  |  Powered by : Scube Technologies Limited',
    );

    final footerStyle = footerCell.cellStyle;
    footerStyle
      ..italic = true
      ..bold = false
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..backColor =
          '#D9E1F2' // light blue
      ..fontColor = '#305496'; // dark blue text

    // Optional border on top
    // footerStyle.borders.top.lineStyle = LineStyle.thin;

    /// ─────────────────────────────
    /// SAVE
    /// ─────────────────────────────
    ///
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    await FileHelper.saveAndOpen(
      bytes,
      'project_report.xlsx',
      mime: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  static void _infoRow(
    Worksheet sheet,
    String cell,
    String label,
    String value,
  ) {
    final labelCell = sheet.getRangeByName(cell);
    labelCell.setText(label);
    labelCell.cellStyle
      ..bold = true
      ..borders.all.lineStyle = LineStyle.thin;

    final row = labelCell.row;

    final valueCell = sheet.getRangeByIndex(row, 4); // Column D
    valueCell.setText(value);
    valueCell.cellStyle
      ..wrapText = true
      ..borders.all.lineStyle = LineStyle.thin;
  }
}
