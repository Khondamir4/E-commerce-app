import 'package:flutter/foundation.dart';
import 'package:shoppy/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<dynamic> _products = [];
  List<dynamic> get products => _products;

  void setProducts(List<dynamic> products) {
    _products = products;
    notifyListeners();
  }

  void clearProducts() {
    _products = [];
    notifyListeners();
  }

  void removeProduct(int productId) {
    _products.removeWhere((product) => product.id == productId);
    notifyListeners();
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}
