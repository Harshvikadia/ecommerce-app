import 'package:dio/dio.dart';
import 'package:ecommerce_app_task/core/utils/constants.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: Constant.BASE_URL,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: false,
      responseHeader: false,
      responseBody: true, // poora response
      error: true,
      logPrint: (obj) => debugPrint(obj.toString(), wrapWidth: 1024),
    ),
  );
}