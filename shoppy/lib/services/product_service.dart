import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoppy/models/product_model.dart';

class ProductService {
  static const String baseUrl = 'http://10.0.2.2:8000/products';

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['products'];
      return data.map((productJson) => Product.fromJson(productJson)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
