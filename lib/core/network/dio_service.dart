import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gym/core/constants/constants.dart';
import 'package:gym/core/services/storage_service.dart';
import 'package:gym/core/services/token_manager.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioService {
  DioService() : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: timeoutDuration),
      receiveTimeout: const Duration(milliseconds: timeoutDuration),
      sendTimeout: const Duration(milliseconds: timeoutDuration),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    _setupInterceptors();
  }

  static const int timeoutDuration = 30000; // 30 seconds
  final Dio _dio;
  final TokenManager _tokenManager = TokenManager();

  void _setupInterceptors() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenManager.getToken();
          if (token != null) {
            log(token);
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          String errorMessage = 'An error occurred';

          if (error.response != null) {
            // Handle API error responses
            final data = error.response?.data;
            if (data is Map<String, dynamic> && data.containsKey('error')) {
              errorMessage = data['error'].toString();
            } else if (data is Map<String, dynamic> &&
                data.containsKey('message')) {
              errorMessage = data['message'].toString();
            } else {
              errorMessage = error.response?.statusMessage ?? errorMessage;
            }
          } else if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            errorMessage =
                'Connection timeout. Please check your internet connection.';
          } else if (error.type == DioExceptionType.connectionError) {
            errorMessage = 'No internet connection.';
          }

          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: errorMessage,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> multipart(
    String path, {
    required FormData formData,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: formData,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      rethrow;
    }
  }
}
