import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../data/service_model.dart';
import '../data/services_repository.dart';
import '../data/slot_model.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>(
  (ref) => ServicesRepository(ref.read(dioProvider)),
);

class ServiceFilter {
  final String search;
  final int? categoryId;

  const ServiceFilter({this.search = '', this.categoryId});

  bool get isActive => search.isNotEmpty || categoryId != null;
}

class ServiceFilterNotifier extends Notifier<ServiceFilter> {
  @override
  ServiceFilter build() => const ServiceFilter();

  void setSearch(String value) =>
      state = ServiceFilter(search: value, categoryId: state.categoryId);

  void setCategory(int? id) =>
      state = ServiceFilter(search: state.search, categoryId: id);
}

final serviceFilterProvider =
    NotifierProvider<ServiceFilterNotifier, ServiceFilter>(
      ServiceFilterNotifier.new,
    );

final servicesProvider = FutureProvider<List<ServiceModel>>((ref) {
  final filter = ref.watch(serviceFilterProvider);
  return ref
      .read(servicesRepositoryProvider)
      .getServices(search: filter.search, categoryId: filter.categoryId);
});

final featuredServicesProvider = FutureProvider<List<ServiceModel>>(
  (ref) => ref.read(servicesRepositoryProvider).getServices(featured: true),
);

final categoriesProvider = FutureProvider<List<CategoryModel>>(
  (ref) => ref.read(servicesRepositoryProvider).getCategories(),
);

final serviceDetailProvider = FutureProvider.autoDispose
    .family<ServiceModel, int>(
      (ref, id) => ref.read(servicesRepositoryProvider).getService(id),
    );

typedef AvailabilityKey = ({int serviceId, String date});

final availabilityProvider = FutureProvider.autoDispose
    .family<List<SlotModel>, AvailabilityKey>(
      (ref, key) => ref
          .read(servicesRepositoryProvider)
          .getAvailability(key.serviceId, key.date),
    );
