import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestay_booking/core/theme/app_theme.dart';
import 'package:homestay_booking/features/auth/presentation/login_screen.dart';
import 'package:homestay_booking/features/bookings/presentation/booking_detail_screen.dart';
import 'package:homestay_booking/features/bookings/presentation/booking_list_screen.dart';
import 'package:homestay_booking/features/bookings/presentation/create_booking_screen.dart';
import 'package:homestay_booking/features/bookings/presentation/edit_booking_screen.dart';
import 'package:homestay_booking/features/dashboard/presentation/dashboard_screen.dart';
import 'package:homestay_booking/features/rooms/presentation/room_list_screen.dart';
import 'package:homestay_booking/shared/providers/auth_provider.dart';
import 'package:homestay_booking/shared/widgets/app_scaffold.dart';

// Navigation keys for ShellRoute
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration with auth redirect and bottom navigation.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/bookings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookingListScreen(),
            ),
          ),
          GoRoute(
            path: '/rooms',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RoomListScreen(),
            ),
          ),
        ],
      ),
      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/bookings/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateBookingScreen(),
      ),
      GoRoute(
        path: '/bookings/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BookingDetailScreen(
          bookingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/bookings/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => EditBookingScreen(
          bookingId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});

/// Root application widget.
class HomestayApp extends ConsumerWidget {
  const HomestayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Homestay Booking',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
