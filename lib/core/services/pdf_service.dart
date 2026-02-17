import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/utils/file_helper.dart';
import 'package:flutter_application_1/data/models/product_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  static Future<void> generate(List<Product> products) async {
    // =====================
    // DOCUMENT SETTINGS
    // =====================
    final document = PdfDocument();

    // VERY WIDE PAGE (custom size)
    document.pageSettings.size = const Size(2000, 842); // ultra-wide landscape
    document.pageSettings.orientation = PdfPageOrientation.landscape;
    document.pageSettings.margins.all = 20;

    // =====================
    // FOOTER (ALL PAGES)
    // =====================
    const footerHeight = 35.0;

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
    // PROJECT INFORMATION TITLE
    // =====================
    page.graphics.drawString(
      'Project Information',
      headerFont,
      bounds: Rect.fromLTWH(300, cursorY, pageWidth - 300, 20),
    );

    // =====================
    // PROJECT INFO GRID
    // =====================
    final infoGrid = PdfGrid();
    infoGrid.columns.add(count: 2);

    void addInfo(String key, String value) {
      final row = infoGrid.rows.add();
      row.cells[0].value = key;
      row.cells[1].value = value;

      row.cells[0].style.font = normalFont;
      row.cells[1].style.font = valueBoldFont;
    }

    addInfo('Project Name :', 'Fakruddin Textile Mills Ltd.');
    addInfo('Installed DC Capacity', '500 kWp');
    addInfo('Plant AC Capacity', '450 kW');
    addInfo('Address', 'Gazipur, Dhaka, Bangladesh');
    addInfo('Date & Time', '27 Jan 2026, 10:30 am');
    addInfo('User Name', 'Karim Ahmed');

    infoGrid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 8, right: 8, top: 6, bottom: 6),
    );

    final infoResult = infoGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(300, cursorY + 25, pageWidth - 300, 0),
    )!;

    // Move cursor BELOW header section
    cursorY =
        (infoResult.bounds.bottom > 180 ? infoResult.bounds.bottom : 180) + 30;

    // =====================
    // TABLE TITLE
    // =====================
    page.graphics.drawString(
      'Product Data Table',
      titleFont,
      bounds: Rect.fromLTWH(0, cursorY, pageWidth, 25),
    );

    cursorY += 35;

    // =====================
    // PRODUCT TABLE (ONE PAGE ONLY)
    // =====================
    final table = PdfGrid();
    table.columns.add(count: 4);
    table.headers.add(1);

    final header = table.headers[0];
    header.cells[0].value = 'ID';
    header.cells[1].value = 'Title';
    header.cells[2].value = 'Category';
    header.cells[3].value = 'Price';

    for (int i = 0; i < header.cells.count; i++) {
      header.cells[i].style = PdfGridCellStyle(
        font: headerFont,
        backgroundBrush: PdfSolidBrush(PdfColor(200, 230, 255)),
      );
    }

    for (int i = 0; i < products.length; i++) {
      final p = products[i];
      final row = table.rows.add();

      row.cells[0].value = p.id.toString();
      row.cells[1].value = p.title;
      row.cells[2].value = p.category;
      row.cells[3].value = p.price.toStringAsFixed(2);

      if (i.isEven) {
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

    // Draw FULL table in ONE page
    table.draw(page: page, bounds: Rect.fromLTWH(0, cursorY, pageWidth, 0));

    // =====================
    // SAVE
    // =====================
    final bytes = document.saveSync();
    document.dispose();

    await FileHelper.saveAndOpen(
      bytes,
      'products_report.pdf',
      mime: 'application/pdf',
    );
  }
}
