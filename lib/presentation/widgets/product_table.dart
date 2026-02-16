import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/product_model.dart';

class ProductTable extends StatelessWidget {
  final List<Product> products;

  const ProductTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = 700.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth > minWidth
                  ? constraints.maxWidth
                  : minWidth,
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Price')),
              ],
              rows: products
                  .map(
                    (p) => DataRow(
                      cells: [
                        DataCell(Text(p.id.toString())),
                        DataCell(Text(p.title)),
                        DataCell(Text(p.category)),
                        DataCell(Text('\$${p.price}')),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
