import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  Future<List<dynamic>> getProducts(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response != null) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      throw Exception("Failed to Load data");
    }
  }
}
