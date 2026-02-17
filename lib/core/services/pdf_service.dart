import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/utils/file_helper.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfTableData {
  final List<String> headers;
  final List<List<String>> rows;

  PdfTableData({required this.headers, required this.rows});
}

class PdfService {
  static Future<void> generate({
    required PdfTableData tableData,
    required String projectName,
    required String address,
    required String userName,
    required String installedDCCap,
    required String plantAcCap,
    required String dateandtime,
    String fileName = 'report.pdf',
  }) async {
    // =====================
    // PAGE HEIGHT CALCULATION (ONE PAGE GUARANTEE)
    // =====================
    const double rowHeight = 28;
    const double headerHeight = 40;
    const double topContentHeight = 300;
    const double footerHeight = 35;

    final double tableHeight =
        (tableData.rows.length * rowHeight) + headerHeight;

    final double pageHeight =
        topContentHeight + tableHeight + footerHeight + 50;

    // =====================
    // DOCUMENT SETTINGS
    // =====================
    final document = PdfDocument();

    document.pageSettings.size = Size(2000, pageHeight);
    document.pageSettings.orientation = PdfPageOrientation.landscape;
    document.pageSettings.margins.all = 20;

    // =====================
    // FOOTER
    // =====================
    final footer = PdfPageTemplateElement(
      Rect.fromLTWH(0, 0, 2000, footerHeight),
    );

    footer.graphics.drawRectangle(
      brush: PdfSolidBrush(PdfColor(190, 225, 245)),
      bounds: Rect.fromLTWH(0, 0, 2000, footerHeight),
    );

    footer.graphics.drawString(
      'Data Source : SolScada / Powered by : Scube Technologies Ltd.',
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, 8, 2000, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    document.template.bottom = footer;

    // =====================
    // PAGE
    // =====================
    final page = document.pages.add();
    double cursorY = 0;
    final pageWidth = page.getClientSize().width;

    // =====================
    // FONTS
    // =====================
    final titleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      16,
      style: PdfFontStyle.bold,
    );

    final headerFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      11,
      style: PdfFontStyle.bold,
    );

    final normalFont = PdfStandardFont(PdfFontFamily.helvetica, 11);

    final valueBoldFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      11,
      style: PdfFontStyle.bold,
    );

    // =====================
    // LOGO
    // =====================
    final logoData = await rootBundle.load('assets/Logo-scube.png');
    final logoImage = PdfBitmap(logoData.buffer.asUint8List());

    page.graphics.drawImage(logoImage, Rect.fromLTWH(0, cursorY, 280, 180));

    // =====================
    // PROJECT INFO
    // =====================
    page.graphics.drawString(
      'Project Information',
      headerFont,
      bounds: Rect.fromLTWH(300, cursorY, pageWidth - 300, 20),
    );

    final infoGrid = PdfGrid();
    infoGrid.columns.add(count: 2);

    void addInfo(String k, String v) {
      final r = infoGrid.rows.add();
      r.cells[0].value = k;
      r.cells[1].value = v;
      r.cells[0].style.font = normalFont;
      r.cells[1].style.font = valueBoldFont;
    }

    addInfo('Project Name :', projectName);
    addInfo('Installed DC Capacity', installedDCCap);
    addInfo('Plant AC Capacity', plantAcCap);
    addInfo('Address :', address);
    addInfo('Date & Time', dateandtime);
    addInfo('User Name :', userName);

    final infoResult = infoGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(300, cursorY + 25, pageWidth - 300, 0),
    )!;

    cursorY =
        (infoResult.bounds.bottom > 180 ? infoResult.bounds.bottom : 180) + 30;

    // =====================
    // TABLE TITLE
    // =====================
    page.graphics.drawString(
      'Data Table',
      titleFont,
      bounds: Rect.fromLTWH(0, cursorY, pageWidth, 25),
    );

    cursorY += 35;

    // =====================
    // DYNAMIC TABLE
    // =====================
    final table = PdfGrid();
    table.columns.add(count: tableData.headers.length);
    table.headers.add(1);

    final headerRow = table.headers[0];

    for (int i = 0; i < tableData.headers.length; i++) {
      headerRow.cells[i].value = tableData.headers[i];
      headerRow.cells[i].style = PdfGridCellStyle(
        font: headerFont,
        backgroundBrush: PdfSolidBrush(PdfColor(200, 230, 255)),
      );
    }

    for (int r = 0; r < tableData.rows.length; r++) {
      final row = table.rows.add();
      for (int c = 0; c < tableData.rows[r].length; c++) {
        row.cells[c].value = tableData.rows[r][c];
      }

      if (r.isEven) {
        for (int c = 0; c < row.cells.count; c++) {
          row.cells[c].style.backgroundBrush = PdfSolidBrush(
            PdfColor(245, 250, 255),
          );
        }
      }
    }

    table.style = PdfGridStyle(
      font: normalFont,
      cellPadding: PdfPaddings(left: 8, right: 8, top: 8, bottom: 8),
    );

    table.draw(page: page, bounds: Rect.fromLTWH(0, cursorY, pageWidth, 0));

    // =====================
    // SAVE
    // =====================
    final bytes = document.saveSync();
    document.dispose();

    await FileHelper.saveAndOpen(bytes, fileName, mime: 'application/pdf');
  }
}
