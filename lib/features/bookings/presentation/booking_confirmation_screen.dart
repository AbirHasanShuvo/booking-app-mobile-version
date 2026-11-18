import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/status_chip.dart';
import '../../bookings/data/appointment_model.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final AppointmentModel appointment;
  const BookingConfirmationScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = appointment;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.green.shade50,
                    child: Icon(Icons.check_circle, size: 48, color: Colors.green.shade600),
                  ),
                  const SizedBox(height: 16),
                  Text('Booking submitted!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Your appointment is waiting for confirmation.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey.shade600)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _Row('Service', a.service?.name ?? 'Service #${a.serviceId}'),
                        _Row('Date', formatLongDate(a.startAt)),
                        _Row('Time', '${formatTime(a.startAt)} – ${formatTime(a.endAt)}'),
                        if (a.service != null) _Row('Duration', a.service!.durationLabel),
                        _Row('Price', '\$${a.priceSnapshot.toStringAsFixed(2)}'),
                        _Row('Booking #', '${a.id}'),
                        _Row('Status', '', trailing: StatusChip(status: a.status)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go('/bookings'),
                    child: const Text('View my bookings'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Back to home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  const _Row(this.label, this.value, {this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(width: 16),
          Flexible(
            child: trailing ??
                Text(value,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}