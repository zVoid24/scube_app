import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class ExcelHelpers {
  static void setColumnWidths(Worksheet sheet) {
    final List<double> widths = [
      18.0,
      18.0,
      18.0,
      18.0,
      22.0,
      22.0,
      22.0,
      22.0,
    ];

    for (int i = 0; i < widths.length; i++) {
      sheet.getRangeByIndex(1, i + 1).columnWidth = widths[i];
    }
  }
}
