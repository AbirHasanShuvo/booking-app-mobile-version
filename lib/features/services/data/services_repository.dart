import 'package:booking_service_app/features/services/data/slot_model.dart';
import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import 'service_model.dart';

class ServicesRepository {
  final Dio _dio;

  ServicesRepository(this._dio);

  Future<List<ServiceModel>> getServices({
    String? search,
    int? categoryId,
    bool featured = false,
  }) async {
    try {
      final res = await _dio.get(
        '/services',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (categoryId != null) 'category_id': categoryId,
          if (featured) 'featured': 1,
          'per_page': 50,
        },
      );
      final list = res.data['data'] as List;
      return list
          .map(
            (e) => ServiceModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await _dio.get('/categories');
      final list = res.data['data'] as List;
      return list
          .map(
            (e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<ServiceModel> getService(int id) async {
    try {
      final res = await _dio.get('/services/$id');
      return ServiceModel.fromJson(
        Map<String, dynamic>.from(res.data['data'] as Map),
      );
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<List<SlotModel>> getAvailability(int serviceId, String date) async {
    try {
      final res = await _dio.get(
        '/services/$serviceId/availability',
        queryParameters: {'date': date},
      );
      final slots = res.data['data']['slots'] as List;
      return slots
          .map((e) => SlotModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}
