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
      final res = await _dio.get('/services', queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'category_id': categoryId,
        if (featured) 'featured': 1,
        'per_page': 50,
      });
      final list = res.data['data'] as List;
      return list
          .map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e as Map)))
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
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}