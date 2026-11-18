class SlotModel {
  final String startAt; // "2026-11-18 10:00", sent back to the API when booking
  final String start; // "10:00"
  final String end; // "10:45"
  final bool available;

  const SlotModel({
    required this.startAt,
    required this.start,
    required this.end,
    required this.available,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) => SlotModel(
    startAt: json['start_at'] as String,
    start: json['start'] as String,
    end: json['end'] as String,
    available: json['available'] == true,
  );
}