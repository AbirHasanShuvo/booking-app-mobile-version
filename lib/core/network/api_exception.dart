import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  factory ApiException.from(Object e) {
    if (e is ApiException) return e;
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        return ApiException(
          data['message'] as String,
          statusCode: e.response?.statusCode,
          errors: data['errors'] is Map
              ? Map<String, dynamic>.from(data['errors'] as Map)
              : null,
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return ApiException('The server took too long to respond.');
      }
      return ApiException('Cannot reach the server. Check your connection.');
    }
    return ApiException('Something went wrong. Please try again.');
  }

  @override
  String toString() => message;

  String get displayMessage {
    if (errors != null && errors!.isNotEmpty) {
      final first = errors!.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }
    return message;
  }
}
