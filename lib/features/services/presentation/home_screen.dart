import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/auth_controller.dart';
import 'services_providers.dart';
import 'widgets/service_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {}); // refreshes the clear button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(serviceFilterProvider.notifier).setSearch(value.trim());
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    ref.read(serviceFilterProvider.notifier).setSearch('');
    setState(() {});
  }

  void _reloadAll() {
    ref.invalidate(servicesProvider);
    ref.invalidate(featuredServicesProvider);
    ref.invalidate(categoriesProvider);
  }

  Future<void> _onRefresh() async {
    _reloadAll();
    try {
      await ref.read(servicesProvider.future);
    } catch (_) {
      // the error state is shown by the list itself
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).user;
    final filter = ref.watch(serviceFilterProvider);
    final services = ref.watch(servicesProvider);
    final categories = ref.watch(categoriesProvider);
    final featured = ref.watch(featuredServicesProvider);
    final firstName = (user?.name ?? '').split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(firstName.isEmpty ? 'Hello' : 'Hi, $firstName',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey.shade600)),
                      Text('Find your service',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              // Search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search services',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      ),
                    ),
                  ),
                ),
              ),

              // Category chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: categories.maybeWhen(
                    data: (list) => ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: filter.categoryId == null,
                            onSelected: (_) =>
                                ref.read(serviceFilterProvider.notifier).setCategory(null),
                          ),
                        ),
                        for (final c in list)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(c.name),
                              selected: filter.categoryId == c.id,
                              onSelected: (_) => ref
                                  .read(serviceFilterProvider.notifier)
                                  .setCategory(filter.categoryId == c.id ? null : c.id),
                            ),
                          ),
                      ],
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ),
              ),

              // Featured (hidden while searching or filtering)
              if (!filter.isActive)
                SliverToBoxAdapter(
                  child: featured.maybeWhen(
                    data: (list) => list.isEmpty
                        ? const SizedBox.shrink()
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                          child: Text('Popular services',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          height: 214,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (_, i) => FeaturedServiceCard(
                              service: list[i],
                              onTap: () => context.push('/service/${list[i].id}'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ),

              // List title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(filter.isActive ? 'Results' : 'All services',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),

              // Main list with loading, error and empty states
              services.when(
                loading: () => const SliverToBoxAdapter(child: LoadingView()),
                error: (e, _) => SliverToBoxAdapter(
                  child: ErrorView(message: e.toString(), onRetry: _reloadAll),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: EmptyView(
                        title: 'No services found',
                        message: 'Try a different search or category.',
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => ServiceCard(
                        service: list[i],
                        onTap: () => context.push('/service/${list[i].id}'),
                      ),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}