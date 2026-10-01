import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'api_response.dart';

class GenericApiService {
  const GenericApiService(this._dio);

  final Dio _dio;

  Future<ListResponse<T>> getList<T>({
    required String path,
    required List<T> Function(List<dynamic> json) listDecoder,
    Map<String, Object?>? query,
  }) async {
    try {
      final response = await _dio.get<Object?>(path, queryParameters: query);
      final payload = Map<String, dynamic>.from(response.data! as Map);
      final products = payload['products'] as List<dynamic>? ?? const [];
      final total = (payload['total'] as num?)?.toInt() ?? products.length;
      final skip = (payload['skip'] as num?)?.toInt() ?? 0;
      final limit = (payload['limit'] as num?)?.toInt() ?? products.length;

      return ListResponse<T>(
        items: listDecoder(products),
        pagination: PaginationMeta(total: total, skip: skip, limit: limit),
      );
    } on DioException catch (error) {
      throw _toApiException(error);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        userMessage: 'We could not load products. Please try again.',
        developerMessage: error.toString(),
      );
    }
  }

  Future<SingleResponse<T>> get<T>({
    required String path,
    required T Function(dynamic json) decoder,
  }) async {
    try {
      final response = await _dio.get<Object?>(path);
      return SingleResponse<T>(data: decoder(response.data));
    } on DioException catch (error) {
      throw _toApiException(error);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        userMessage: 'We could not load this product. Please try again.',
        developerMessage: error.toString(),
      );
    }
  }

  ApiException _toApiException(DioException error) {
    final isNetworkError = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      _ => false,
    };

    return ApiException(
      userMessage: isNetworkError
          ? 'No internet connection. Check your connection and try again.'
          : 'We could not load products. Please try again.',
      developerMessage: error.message,
      statusCode: error.response?.statusCode,
      isNetworkError: isNetworkError,
    );
  }
}