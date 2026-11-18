import '../../services/data/service_model.dart';

class AppointmentModel {
  final int id;
  final int serviceId;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final String? notes;
  final double priceSnapshot;
  final ServiceModel? service;

  const AppointmentModel({
    required this.id,
    required this.serviceId,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.notes,
    required this.priceSnapshot,
    this.service,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => AppointmentModel(
    id: json['id'] as int,
    serviceId: json['service_id'] as int,
    startAt: DateTime.parse(json['start_at'] as String),
    endAt: DateTime.parse(json['end_at'] as String),
    status: json['status'] as String,
    notes: json['notes'] as String?,
    priceSnapshot: double.parse(json['price_snapshot'].toString()),
    service: json['service'] is Map
        ? ServiceModel.fromJson(Map<String, dynamic>.from(json['service'] as Map))
        : null,
  );

  bool get canCancel => status == 'pending';
}