import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/state_views.dart';
import '../data/service_model.dart';
import 'services_providers.dart';
import 'widgets/service_card.dart';

class ServiceDetailsScreen extends ConsumerWidget {
  final int serviceId;
  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(serviceDetailProvider(serviceId));
    final theme = Theme.of(context);

    return Scaffold(
      body: async.when(
        loading: () => const _MessageShell(child: LoadingView()),
        error: (e, _) => _MessageShell(
          child: ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(serviceDetailProvider(serviceId)),
          ),
        ),
        data: (s) => CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 260,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.white70,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: ServiceImage(
                  url: s.imageUrl,
                  height: 260,
                  width: double.infinity,
                  radius: 0,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (s.category != null)
                      Text(s.category!.name,
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: theme.colorScheme.primary)),
                    const SizedBox(height: 4),
                    Text(s.name,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _InfoTile(
                                icon: Icons.sell_outlined,
                                label: 'Price',
                                value: s.priceLabel)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _InfoTile(
                                icon: Icons.schedule,
                                label: 'Duration',
                                value: s.durationLabel)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('About this service',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(s.description,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(height: 1.5, color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: async.maybeWhen<Widget?>(
        data: (s) => _BookBar(service: s),
        orElse: () => null,
      ),
    );
  }
}

class _MessageShell extends StatelessWidget {
  final Widget child;
  const _MessageShell({required this.child});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Align(alignment: Alignment.centerLeft, child: BackButton()),
        Expanded(child: Center(child: SingleChildScrollView(child: child))),
      ],
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey.shade600)),
              Text(value,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookBar extends StatelessWidget {
  final ServiceModel service;
  const _BookBar({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: FilledButton(
            onPressed: () => context.push('/service/${service.id}/book'),
            child: Text('Book now · ${service.priceLabel}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}