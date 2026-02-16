import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/product_controller.dart';

class DownloadBottomSheet extends StatelessWidget {
  final ProductController controller;

  const DownloadBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Download Excel'),
            onTap: controller.downloadExcel,
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Download PDF'),
            onTap: controller.downloadPdf,
          ),
        ],
      ),
    );
  }
}
