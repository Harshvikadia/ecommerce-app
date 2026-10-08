import 'package:flutter/foundation.dart';
import 'package:ecommerce_app_task/features/products/data/product_model.dart';
import 'package:ecommerce_app_task/features/products/data/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  static const int _limit = 10;

  final List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 0;
  String _query = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get query => _query;

  // query khali ho to normal list, warna search API
  Future<List<Product>> _fetch(int skip) {
    if (_query.isEmpty) {
      return _service.fetchProducts(limit: _limit, skip: skip);
    }
    return _service.searchProducts(_query, limit: _limit, skip: skip);
  }

  // Page open / Retry / Search. query dene par naya search set hota hai.
  Future<void> loadProducts({String? query}) async {
    if (query != null) _query = query;

    final requestQuery = _query;
    _isLoading = true;
    _error = null;
    _hasMore = true;
    _page = 0;
    notifyListeners();

    try {
      final result = await _fetch(0);
      // Agar tab tak user ne aur type kar diya, to purana result ignore
      if (requestQuery != _query) return;
      _products
        ..clear()
        ..addAll(result);
      _page = 1;
      _hasMore = result.length == _limit;
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

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    final requestQuery = _query;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _fetch(_page * _limit);
      if (requestQuery != _query) return;
      _products.addAll(result);
      _page++;
      _hasMore = result.length == _limit;
    } catch (e) {
      debugPrint('Load more failed: $e');
    } finally {
      if (requestQuery == _query) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshProducts() async {
    _error = null;
    final requestQuery = _query;

    try {
      final result = await _fetch(0);
      if (requestQuery != _query) return;
      _products
        ..clear()
        ..addAll(result);
      _page = 1;
      _hasMore = result.length == _limit;
    } catch (e) {
      if (requestQuery != _query) return;
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }
}