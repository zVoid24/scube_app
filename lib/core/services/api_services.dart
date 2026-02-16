import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  Future<List<dynamic>> getProducts(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response != null) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to load data");
  }
}
