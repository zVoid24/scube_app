import 'dart:ui';

import 'package:flutter_application_1/core/utils/file_helper.dart';
import 'package:flutter_application_1/data/models/product_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  static Future<void> generate(List<Product> products) async {
    final document = PdfDocument();

    final grid = PdfGrid();
    grid.columns.add(count: 4);
    grid.headers.add(1);

    final header = grid.headers[0];
    header.cells[0].value = 'ID';
    header.cells[1].value = 'Title';
    header.cells[2].value = 'Category';
    header.cells[3].value = 'Price';

    for (final p in products) {
      final row = grid.rows.add();
      row.cells[0].value = p.id.toString();
      row.cells[1].value = p.title;
      row.cells[2].value = p.category;
      row.cells[3].value = p.price.toString();
    }

    grid.draw(
      page: document.pages.add(),
      bounds: const Rect.fromLTWH(0, 40, 0, 0),
    );

    final bytes = document.saveSync();
    document.dispose();

    await FileHelper.saveAndOpen(
      bytes,
      'products.pdf',
      mime: 'application/pdf',
    );
  }
}
