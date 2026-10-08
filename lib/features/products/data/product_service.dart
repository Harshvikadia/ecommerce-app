import 'package:dio/dio.dart';
import 'package:ecommerce_app_task/core/network/dio_client.dart';
import 'package:ecommerce_app_task/core/utils/app_string.dart';
import 'package:ecommerce_app_task/core/utils/constants.dart';
import 'product_model.dart';

class ProductService {
  final Dio _dio = DioClient.instance;

  Future<List<Product>> fetchProducts({int limit = 30, int skip = 0}) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {'limit': limit, 'skip': skip},
      );
      final list = response.data[Constant.PRODUCTS] as List;
      return list.map((e) => Product.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<List<Product>> searchProducts(
      String query, {
        int limit = 10,
        int skip = 0,
      }) async {
    try {
      final response = await _dio.get(
        '/products/search',
        queryParameters: {'q': query, 'limit': limit, 'skip': skip},
      );
      final list = response.data[Constant.PRODUCTS] as List;
      return list.map((e) => Product.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  String _errorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return AppStrings.errTimeout;
      case DioExceptionType.connectionError:
        return AppStrings.errNoInternet;
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode}).';
      default:
        return AppStrings.errSomethingWrong;
    }
  }
}