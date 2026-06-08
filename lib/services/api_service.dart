import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Central HTTP client for the Laravel API.
/// All services call through this single point so the base URL
/// and error handling are configured in one place.
class ApiService {
  // ── Change this to your PC's local IP for real-device testing ──
  // Android emulator → 10.0.2.2 maps to the host machine's localhost
  // Real device      → use your PC's LAN IP (e.g. 192.168.1.100)
  static const String baseUrl = 'https://sd-api-p04q.onrender.com/api';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  /// GET request — returns the `data` envelope or throws
  static Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return response.data['data'];
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// GET request returning the full response body (not just `data`)
  static Future<Map<String, dynamic>> getRaw(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// POST request
  static Future<dynamic> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// PUT request
  static Future<dynamic> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data['data'];
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// DELETE request
  static Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Upload a file (multipart)
  static Future<dynamic> upload(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?extraFields,
      });
      final response = await _dio.post(path, data: formData);
      return response.data['data'];
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Extracts a user-friendly error message from Dio exceptions
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('error')) {
          return data['error'].toString();
        }
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Check your network.';
        case DioExceptionType.connectionError:
          return 'Cannot connect to server. Is the API running?';
        default:
          return error.message ?? 'An unexpected error occurred';
      }
    }
    return error.toString();
  }

  static void _handleError(DioException e) {
    debugPrint('API Error: ${e.type} — ${e.message}');
    if (e.response != null) {
      debugPrint('Response: ${e.response?.statusCode} ${e.response?.data}');
    }
  }
}
