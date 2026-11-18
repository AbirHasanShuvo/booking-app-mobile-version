import 'package:dio/dio.dart';
import '../../../core/network/api_exception.dart';
import 'appointment_model.dart';

class BookingsRepository {
  final Dio _dio;
  BookingsRepository(this._dio);

  Future<AppointmentModel> createAppointment({
    required int serviceId,
    required String startAt,
    String? notes,
  }) async {
    try {
      final res = await _dio.post('/appointments', data: {
        'service_id': serviceId,
        'start_at': startAt,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      return AppointmentModel.fromJson(
          Map<String, dynamic>.from(res.data['data'] as Map));
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<List<AppointmentModel>> getAppointments({String? scope}) async {
    try {
      final res = await _dio.get('/appointments', queryParameters: {
        if (scope != null) 'scope': scope,
      });
      final list = res.data['data'] as List;
      return list
          .map((e) => AppointmentModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<AppointmentModel> getAppointment(int id) async {
    try {
      final res = await _dio.get('/appointments/$id');
      return AppointmentModel.fromJson(
          Map<String, dynamic>.from(res.data['data'] as Map));
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<AppointmentModel> cancel(int id) async {
    try {
      final res = await _dio.patch('/appointments/$id/cancel');
      return AppointmentModel.fromJson(
          Map<String, dynamic>.from(res.data['data'] as Map));
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}