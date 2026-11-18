import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/appointment_model.dart';
import '../data/bookings_repository.dart';

final bookingsRepositoryProvider =
Provider<BookingsRepository>((ref) => BookingsRepository(ref.read(dioProvider)));

// These watch the logged-in user's id, so they reload when someone else logs in.
// Without this, user B could briefly see user A's cached bookings.
final upcomingBookingsProvider = FutureProvider<List<AppointmentModel>>((ref) {
  ref.watch(authControllerProvider.select((s) => s.user?.id));
  return ref.read(bookingsRepositoryProvider).getAppointments(scope: 'upcoming');
});

final pastBookingsProvider = FutureProvider<List<AppointmentModel>>((ref) {
  ref.watch(authControllerProvider.select((s) => s.user?.id));
  return ref.read(bookingsRepositoryProvider).getAppointments(scope: 'past');
});

final bookingDetailProvider =
FutureProvider.autoDispose.family<AppointmentModel, int>(
      (ref, id) => ref.read(bookingsRepositoryProvider).getAppointment(id),
);