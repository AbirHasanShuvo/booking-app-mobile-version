import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../services/presentation/widgets/service_card.dart';
import '../data/appointment_model.dart';
import 'bookings_providers.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final int appointmentId;
  const BookingDetailsScreen({super.key, required this.appointmentId});

  @override
  ConsumerState<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: const Text('This cannot be undone. The time slot will be released.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      await ref.read(bookingsRepositoryProvider).cancel(widget.appointmentId);
      ref.invalidate(bookingDetailProvider(widget.appointmentId));
      ref.invalidate(upcomingBookingsProvider);
      ref.invalidate(pastBookingsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Booking cancelled')));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.displayMessage)));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(bookingDetailProvider(widget.appointmentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Booking details')),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(
          child: SingleChildScrollView(
            child: ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(bookingDetailProvider(widget.appointmentId)),
            ),
          ),
        ),
        data: (a) => _Content(appointment: a),
      ),
      bottomNavigationBar: async.maybeWhen<Widget?>(
        data: (a) => a.canCancel
            ? Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _cancelling ? null : _cancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _cancelling
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel booking'),
                ),
              ),
            ),
          ),
        )
            : null,
        orElse: () => null,
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final AppointmentModel appointment;
  const _Content({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = appointment;
    final s = a.service;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              ServiceImage(url: s?.imageUrl, width: 72, height: 72),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s?.name ?? 'Service #${a.serviceId}',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    StatusChip(status: a.status),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _Row('Booking #', '${a.id}'),
              _Row('Date', formatLongDate(a.startAt)),
              _Row('Time', '${formatTime(a.startAt)} – ${formatTime(a.endAt)}'),
              if (s != null) _Row('Duration', s.durationLabel),
              _Row('Price', '\$${a.priceSnapshot.toStringAsFixed(2)}'),
              if (a.notes != null && a.notes!.isNotEmpty) _Row('Notes', a.notes!),
            ],
          ),
        ),
        if (a.status == 'pending') ...[
          const SizedBox(height: 16),
          Text('Waiting for confirmation. You can cancel while the booking is pending.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}