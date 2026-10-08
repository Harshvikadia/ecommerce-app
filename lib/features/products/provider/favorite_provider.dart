import 'package:flutter/foundation.dart';
import 'package:ecommerce_app_task/features/products/data/product_model.dart';

class FavoritesProvider extends ChangeNotifier {
  final Map<int, Product> _favorites = {};

  List<Product> get favorites => _favorites.values.toList();

  bool isFavorite(int id) => _favorites.containsKey(id);

  void toggle(Product product) {
    if (_favorites.containsKey(product.id)) {
      _favorites.remove(product.id);
    } else {
      _favorites[product.id] = product;
    }
    notifyListeners();
  }
}