import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/state_views.dart';
import 'bookings_providers.dart';
import 'widgets/booking_card.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My bookings'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Upcoming'), Tab(text: 'Past')],
          ),
        ),
        body: const TabBarView(
          children: [
            _BookingsList(upcoming: true),
            _BookingsList(upcoming: false),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends ConsumerWidget {
  final bool upcoming;
  const _BookingsList({required this.upcoming});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = upcoming ? upcomingBookingsProvider : pastBookingsProvider;
    final async = ref.watch(provider);

    Future<void> refresh() async {
      ref.invalidate(provider);
      try {
        await ref.read(provider.future);
      } catch (_) {}
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: async.when(
        loading: () => ListView(children: const [LoadingView()]),
        error: (e, _) => ListView(
          children: [
            ErrorView(message: e.toString(), onRetry: () => ref.invalidate(provider)),
          ],
        ),
        data: (list) {
          if (list.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                EmptyView(
                  icon: Icons.event_busy,
                  title: upcoming ? 'No upcoming bookings' : 'No past bookings',
                  message: upcoming
                      ? 'Book a service and it will show up here.'
                      : 'Completed and cancelled bookings appear here.',
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => BookingCard(
              appointment: list[i],
              onTap: () => context.push('/appointment/${list[i].id}'),
            ),
          );
        },
      ),
    );
  }
}