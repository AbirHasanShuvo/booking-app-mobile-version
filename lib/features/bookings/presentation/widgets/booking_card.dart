import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../services/presentation/widgets/service_card.dart';
import '../../data/appointment_model.dart';

class BookingCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.appointment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = appointment;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ServiceImage(url: a.service?.imageUrl, width: 72, height: 72),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.service?.name ?? 'Service #${a.serviceId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusChip(status: a.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(formatLongDate(a.startAt),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade700)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text('${formatTime(a.startAt)} – ${formatTime(a.endAt)}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade700)),
                        const Spacer(),
                        Text('\$${a.priceSnapshot.toStringAsFixed(2)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}