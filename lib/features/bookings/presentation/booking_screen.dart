import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../bookings/presentation/bookings_providers.dart';
import '../../services/data/service_model.dart';
import '../../services/data/slot_model.dart';
import '../../services/presentation/services_providers.dart';
import '../../services/presentation/widgets/service_card.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final int serviceId;
  const BookingScreen({super.key, required this.serviceId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late final List<DateTime> _days;
  late DateTime _date;
  SlotModel? _slot;
  bool _submitting = false;
  final _notes = TextEditingController();

  AvailabilityKey get _key =>
      (serviceId: widget.serviceId, date: formatApiDate(_date));

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _days = List.generate(14, (i) => DateTime(n.year, n.month, n.day + i));
    _date = _days.first;
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final slot = _slot;
    if (slot == null) return;

    setState(() => _submitting = true);
    try {
      final appointment =
      await ref.read(bookingsRepositoryProvider).createAppointment(
        serviceId: widget.serviceId,
        startAt: slot.startAt,
        notes: _notes.text.trim(),
      );
      ref.invalidate(upcomingBookingsProvider);
      ref.invalidate(pastBookingsProvider);
      if (!mounted) return;
      context.pushReplacement('/booking/confirmation', extra: appointment);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 409) {
        // Someone took the slot first: refresh and make the user pick again.
        setState(() => _slot = null);
        ref.invalidate(availabilityProvider(_key));
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.displayMessage)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final service = ref.watch(serviceDetailProvider(widget.serviceId));
    final slots = ref.watch(availabilityProvider(_key));

    return Scaffold(
      appBar: AppBar(title: const Text('Book appointment')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          service.maybeWhen(
            data: (s) => _ServiceSummary(service: s),
            orElse: () => const SizedBox.shrink(),
          ),
          const _SectionTitle('Select date'),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final d = _days[i];
                final selected = d == _date;
                final fg = selected ? Colors.white : Colors.grey.shade700;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() {
                    _date = d;
                    _slot = null;
                  }),
                  child: Container(
                    width: 62,
                    decoration: BoxDecoration(
                      color: selected ? primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: selected ? primary : Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('EEE').format(d),
                            style: theme.textTheme.labelMedium?.copyWith(color: fg)),
                        Text('${d.day}',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: fg, fontWeight: FontWeight.bold)),
                        Text(DateFormat('MMM').format(d),
                            style: theme.textTheme.labelSmall?.copyWith(color: fg)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const _SectionTitle('Select time'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: slots.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(availabilityProvider(_key)),
              ),
              data: (list) {
                if (!list.any((s) => s.available)) {
                  return const EmptyView(
                    icon: Icons.event_busy,
                    title: 'No slots available',
                    message: 'Everything is booked or past for this day. Try another date.',
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in list)
                      ChoiceChip(
                        label: Text(
                          formatHm(s.start),
                          style: TextStyle(
                            decoration:
                            s.available ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        selected: _slot?.startAt == s.startAt,
                        onSelected:
                        s.available ? (_) => setState(() => _slot = s) : null,
                      ),
                  ],
                );
              },
            ),
          ),
          const _SectionTitle('Notes (optional)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _notes,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Anything the provider should know?',
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_slot != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(Icons.event_available, size: 18, color: primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${formatLongDate(_date)} · ${formatHm(_slot!.start)} – ${formatHm(_slot!.end)}',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                AppButton(
                  label: 'Confirm booking',
                  onPressed: _slot == null ? null : _confirm,
                  loading: _submitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
    child: Text(text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold)),
  );
}

class _ServiceSummary extends StatelessWidget {
  final ServiceModel service;
  const _ServiceSummary({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            ServiceImage(url: service.imageUrl, width: 56, height: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text('${service.priceLabel} · ${service.durationLabel}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}