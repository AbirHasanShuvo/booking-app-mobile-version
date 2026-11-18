import 'package:intl/intl.dart';

String formatApiDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
String formatLongDate(DateTime d) => DateFormat('EEE, d MMM yyyy').format(d);
String formatTime(DateTime d) => DateFormat('h:mm a').format(d);

/// "14:30" -> "2:30 PM"
String formatHm(String hhmm) {
  final parts = hhmm.split(':');
  final h = int.parse(parts[0]);
  final suffix = h >= 12 ? 'PM' : 'AM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${parts[1]} $suffix';
}