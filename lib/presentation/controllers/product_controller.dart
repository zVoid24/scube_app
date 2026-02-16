import 'package:flutter_application_1/core/services/excel_service.dart';
import 'package:flutter_application_1/core/services/pdf_service.dart';
import 'package:flutter_application_1/data/models/product_model.dart';
import 'package:flutter_application_1/data/repositories/product_repo.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final ProductRepo repository;

  ProductController(this.repository);

  final products = <Product>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      products.value = await repository.fetchProducts();
    } finally {
      isLoading.value = false;
    }
  }

  void downloadExcel() {
    // 1️⃣ Define table headers (dynamic)
    final headers = ['ID', 'Title', 'Category', 'Price'];

    // 2️⃣ Convert Product list → rows
    final rows = products.map((product) {
      return [
        product.id.toString(),
        product.title,
        product.category,
        product.price.toString(),
      ];
    }).toList();

    // 3️⃣ Call ExcelService (NEW SIGNATURE)
    ExcelService.generate(
      headers: headers,
      rows: rows,
      projectName: 'Paragon Poultry Ltd.',
      address: 'Haluaghat, Mymensingh, Bangladesh',
      userName: 'Karim Ahmed',
    );
  }

  void downloadPdf() {
    PdfService.generate(products);
  }
}
