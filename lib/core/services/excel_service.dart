import 'package:flutter_application_1/core/services/layouts/excel_layouts.dart';
import 'package:flutter_application_1/core/services/styles/excel_styles.dart';
import 'package:flutter_application_1/core/utils/excel_helpers.dart';
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
    ExcelStyles.clear();

    final sheet = workbook.worksheets[0];
    sheet.name = 'Project Information';

    ExcelHelpers.setColumnWidths(sheet);

    await ExcelLayout.addLogo(sheet, workbook);

    ExcelLayout.addInfoRow(sheet, workbook, 1, 'Project Name', projectName);
    ExcelLayout.addInfoRow(sheet, workbook, 2, 'Address', address);
    ExcelLayout.addInfoRow(
      sheet,
      workbook,
      3,
      'Printed Date & Time',
      DateTime.now().toString(),
    );
    ExcelLayout.addInfoRow(sheet, workbook, 4, 'User Name', userName);

    const tableStartRow = 6;
    ExcelLayout.addTable(
      sheet,
      workbook,
      startRow: tableStartRow,
      headers: headers,
      rows: rows,
    );

    final footerRow = tableStartRow + rows.length + 2;
    ExcelLayout.addFooter(sheet, workbook, footerRow, headers.length);

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    await FileHelper.saveAndOpen(
      bytes,
      'project_report.xlsx',
      mime: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }
}
