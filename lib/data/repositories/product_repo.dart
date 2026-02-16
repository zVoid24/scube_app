import 'package:flutter_application_1/core/services/api_services.dart';
import 'package:flutter_application_1/data/models/product_model.dart';

class ProductRepo {
  final ApiService _api;
  ProductRepo(this._api);
  Future<List<Product>> fetchProducts() async {
    final data = await _api.getProducts('https://fakestoreapi.com/products');
    return data.map((e) => Product.fromJson(e)).toList();
  }
}
