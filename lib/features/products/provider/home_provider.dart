import 'package:flutter/foundation.dart';
import 'package:ecommerce_app_task/features/products/data/product_model.dart';
import 'package:ecommerce_app_task/features/products/data/product_service.dart';

class HomeProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  static const int _homeLimit = 6; // Home par sirf 6

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String _query = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;

  // query khali ho to normal 6, warna search ke 6
  Future<List<Product>> _fetch() {
    if (_query.isEmpty) {
      return _service.fetchProducts(limit: _homeLimit, skip: 0);
    }
    return _service.searchProducts(_query, limit: _homeLimit, skip: 0);
  }

  // Dashboard khulte hi / Retry / Search (query dene par naya search)
  Future<void> loadProducts({String? query}) async {
    if (query != null) _query = query;

    final requestQuery = _query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _fetch();
      // User ne tab tak aur type kar diya, to purana result ignore
      if (requestQuery != _query) return;
      _products = result;
    } catch (e) {
      if (requestQuery != _query) return;
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (requestQuery == _query) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Pull to refresh (current search ke saath)
  Future<void> refreshProducts() async {
    _error = null;
    final requestQuery = _query;

    try {
      final result = await _fetch();
      if (requestQuery != _query) return;
      _products = result;
    } catch (e) {
      if (requestQuery != _query) return;
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }
}