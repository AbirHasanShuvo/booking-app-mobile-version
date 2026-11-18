import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  MaterialColor get _color => switch (status) {
    'confirmed' => Colors.green,
    'cancelled' => Colors.red,
    'completed' => Colors.blue,
    _ => Colors.orange, // pending
  };

  @override
  Widget build(BuildContext context) {
    final label = status.isEmpty ? '' : status[0].toUpperCase() + status.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: _color.shade800, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}