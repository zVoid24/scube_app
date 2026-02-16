import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/api_services.dart';
import 'package:flutter_application_1/data/repositories/product_repo.dart';
import 'package:flutter_application_1/presentation/controllers/product_controller.dart';
import 'package:flutter_application_1/presentation/widgets/download_bottom_sheet.dart';
import 'package:flutter_application_1/presentation/widgets/product_table.dart';
import 'package:get/get.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController(ProductRepo(ApiService())));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              Get.bottomSheet(DownloadBottomSheet(controller: controller));
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ProductTable(products: controller.products),
        );
      }),
    );
  }
}
