import 'package:flutter_application_1/core/services/excel_service.dart';
import 'package:flutter_application_1/core/services/pdf_service.dart';
import 'package:flutter_application_1/core/utils/excel_mapper.dart';
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
    final excelData = ExcelMapper.fromList<Product>(
      products,
      (product) => product.toJson(),
    );

    ExcelService.generate(
      headers: List<String>.from(excelData['headers']),
      rows: List<List<String>>.from(excelData['rows']),
      projectName: 'Paragon Poultry Ltd.',
      address: 'Haluaghat, Mymensingh, Bangladesh',
      userName: 'Karim Ahmed',
    );
  }

  void downloadPdf() {
    PdfService.generate(products);
  }
}
