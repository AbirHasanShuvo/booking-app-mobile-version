import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/widgets/placeholder_screen.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/bookings/presentation/booking_details_screen.dart';
import 'features/bookings/presentation/my_bookings_screen.dart';
import 'features/bookings/data/appointment_model.dart';
import 'features/bookings/presentation/booking_confirmation_screen.dart';
import 'features/bookings/presentation/booking_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/services/presentation/home_screen.dart';
import 'features/services/presentation/service_details_screen.dart';
import 'features/shell/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final loc = state.matchedLocation;
      final onAuthPage = loc == '/login' || loc == '/register';

      if (status == AuthStatus.unknown) return loc == '/splash' ? null : '/splash';
      if (status == AuthStatus.unauthenticated) return onAuthPage ? null : '/login';
      if (onAuthPage || loc == '/splash') return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) =>
        const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      GoRoute(
        path: '/service/:id',
        builder: (_, state) => ServiceDetailsScreen(
          serviceId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/service/:id/book',
        builder: (_, state) => BookingScreen(
          serviceId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/booking/confirmation',
        redirect: (_, state) => state.extra is AppointmentModel ? null : '/home',
        builder: (_, state) =>
            BookingConfirmationScreen(appointment: state.extra as AppointmentModel),
      ),
      GoRoute(
        path: '/appointment/:id',
        builder: (_, state) => BookingDetailsScreen(
          appointmentId: int.parse(state.pathParameters['id']!),
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/bookings', builder: (_, __) => const MyBookingsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/assistant',
              builder: (_, __) =>
              const PlaceholderScreen(title: 'Assistant', icon: Icons.smart_toy),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});