import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class ExcelStyles {
  static final Map<String, Style> _cache = {};

  static Style _get(
    Workbook wb,
    String name,
    void Function(Style style) builder,
  ) {
    if (_cache.containsKey(name)) {
      return _cache[name]!;
    }

    final style = wb.styles.add(name); // returns Style
    builder(style);
    _cache[name] = style;
    return style;
  }

  static Style header(Workbook wb) {
    return _get(wb, 'headerStyle', (style) {
      style
        ..bold = true
        ..backColor = '#D9E1F2'
        ..hAlign = HAlignType.center
        ..vAlign = VAlignType.center
        ..borders.all.lineStyle = LineStyle.thin;
    });
  }

  static Style tableCell(Workbook wb) {
    return _get(wb, 'tableCellStyle', (style) {
      style
        ..hAlign = HAlignType.center
        ..vAlign = VAlignType.center
        ..borders.all.lineStyle = LineStyle.thin;
    });
  }

  static Style infoLabel(Workbook wb) {
    return _get(wb, 'infoLabelStyle', (style) {
      style
        ..bold = true
        ..hAlign = HAlignType.left
        ..vAlign = VAlignType.center
        ..borders.all.lineStyle = LineStyle.thin;
    });
  }

  static Style infoValue(Workbook wb) {
    return _get(wb, 'infoValueStyle', (style) {
      style
        ..hAlign = HAlignType.left
        ..vAlign = VAlignType.center
        ..borders.all.lineStyle = LineStyle.thin;
    });
  }

  static Style footer(Workbook wb) {
    return _get(wb, 'footerStyle', (style) {
      style
        ..italic = true
        ..hAlign = HAlignType.center
        ..vAlign = VAlignType.center
        ..backColor = '#D9E1F2'
        ..fontColor = '#305496';
    });
  }

  static void clear() {
    _cache.clear();
  }
}
