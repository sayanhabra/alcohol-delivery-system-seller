// core/navigation/app_router.dart

import 'package:adm_seller/core/navigation/main_navigation_shell.dart';
import 'package:adm_seller/core/navigation/navigation_config.dart';
import 'package:adm_seller/core/shared/const/keys.dart';
import 'package:adm_seller/modules/auth/screens/login_screen.dart';
import 'package:adm_seller/modules/auth/screens/register_screen.dart';
// import 'package:adm_seller/modules/auth/screens/register_screen.dart';
import 'package:adm_seller/modules/auth/screens/splash_screen.dart';
import 'package:adm_seller/modules/dashboard/screens/dashboard_screen.dart';
import 'package:adm_seller/modules/dashboard/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

// ============================================================
// AUTH PROVIDER
// ============================================================

final authStateProvider = StateProvider<AuthState>((ref) {
  return AuthState.unauthenticated();
});

class AuthState {
  final String? userType;
  final bool isAuthenticated;

  const AuthState._({this.userType, required this.isAuthenticated});

  factory AuthState.authenticated(String userType) {
    return AuthState._(userType: userType, isAuthenticated: true);
  }

  factory AuthState.unauthenticated() {
    return AuthState._(userType: null, isAuthenticated: false);
  }

  T when<T>({
    required T Function(String userType) authenticated,
    required T Function() unauthenticated,
  }) {
    if (isAuthenticated && userType != null) {
      return authenticated(userType!);
    }
    return unauthenticated();
  }
}

// ============================================================
// ROUTE CONSTANTS
// ============================================================

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String home = '/home';

  // User Routes
  static const String fevorite = '/fevorite';
  static const String orders = '/orders';
  static const String allcategory = '/allcategory';

  // Vendor Routes
  static const String vendorDashboard = '/vendor/dashboard';
  static const String vendorOrders = '/vendor/orders';
  static const String vendorProducts = '/vendor/products';

  // Rider Routes
  static const String riderDashboard = '/rider/dashboard';
  static const String riderDeliveries = '/rider/deliveries';
  static const String riderEarnings = '/rider/earnings';

  // Common Routes
  static const String profile = '/profile';
}

// ============================================================
// NAVIGATION KEYS
// ============================================================

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

// ============================================================
// GO ROUTER CONFIGURATION
// ============================================================

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',

  // ✅ Enable debug logging
  debugLogDiagnostics: true,

  // ============================================================
  // REDIRECT LOGIC - FIXED
  // ============================================================
  redirect: (context, state) {
    // ✅ Get actual auth state from provider
    final authState = ProviderScope.containerOf(
      context,
    ).read(authStateProvider);

    final isAuthenticated = authState.isAuthenticated;
    // final userType = authState.userType;
    final userType = Keys.USER_TYPE;

    debugPrint('🔀 Redirect check:');
    debugPrint('  - isAuthenticated: $isAuthenticated');
    debugPrint('  - userType: $userType');
    debugPrint('  - current location: ${state.matchedLocation}');

    final isSplash = state.matchedLocation == AppRoutes.splash;
    final isLogin = state.matchedLocation == AppRoutes.login;
    final isRegister = state.matchedLocation == AppRoutes.register;
    final isDashboard = state.matchedLocation == AppRoutes.dashboard;

    // If not authenticated and trying to access protected routes
    if (!isAuthenticated && !isSplash && !isLogin && !isRegister) {
      debugPrint('🔀 Redirecting to login (not authenticated)');
      return AppRoutes.login;
    }

    // If authenticated and on splash or login, go to dashboard
    if (isAuthenticated && (isSplash || isLogin || isRegister)) {
      debugPrint('🔀 Redirecting to dashboard (authenticated)');
      return AppRoutes.dashboard;
    }

    // If authenticated and trying to access dashboard directly, allow it
    if (isAuthenticated && isDashboard) {
      debugPrint('✅ Allowing access to dashboard');
      return null;
    }

    // If authenticated and trying to access a route not allowed for their type
    if (isAuthenticated) {
      final items = NavigationConfig.getItemsForUser(userType);
      final allowedRoutes = items.map((item) => item.route).toList();
      allowedRoutes.add(AppRoutes.profile);
      allowedRoutes.add(AppRoutes.dashboard);

      if (!allowedRoutes.contains(state.matchedLocation)) {
        debugPrint('🔀 Redirecting to dashboard (unauthorized route)');
        return AppRoutes.dashboard;
      }
    }

    // Allow navigation
    return null;
  },

  routes: [
    // ============================================================
    // SPLASH ROUTE
    // ============================================================
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        debugPrint('📍 SplashScreen');
        return const SplashScreen();
      },
    ),

    // ============================================================
    // LOGIN ROUTE
    // ============================================================
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        debugPrint('📍 LoginScreen');
        return const LoginScreen();
      },
    ),

    // ============================================================
    // REGISTER ROUTE
    // ============================================================
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        debugPrint('📍 RegisterScreen');
        return const RegisterScreen();
      },
    ),

    // ============================================================
    // DASHBOARD ROUTE
    // ============================================================
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        debugPrint('📍 DashboardScreen');
        return const DashboardScreen();
      },
    ),

    // ============================================================
    // MAIN SHELL WITH BOTTOM NAVIGATION
    // ============================================================
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return MainNavigationShell(navigationShell: child);
      },
      routes: [
        // ============================================================
        // USER ROUTES
        // ============================================================
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.fevorite,
          name: 'fevorite',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return const FevoriteScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.orders,
          name: 'orders',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return const OrdersScreen();
          },
        ),

        GoRoute(
          path: AppRoutes.allcategory,
          name: 'all',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return const AllCategoryScreen();
          },
        ),

        // ============================================================
        // VENDOR ROUTES
        // ============================================================
        GoRoute(
          path: AppRoutes.vendorDashboard,
          name: 'vendor_dashboard',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return const VendorDashboardScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.vendorOrders,
          name: 'vendor_orders',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return const VendorOrdersScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.vendorProducts,
          name: 'vendor_products',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return const VendorProductsScreen();
          },
        ),

        // ============================================================
        // RIDER ROUTES
        // ============================================================
        GoRoute(
          path: AppRoutes.riderDashboard,
          name: 'rider_dashboard',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return const RiderDashboardScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.riderDeliveries,
          name: 'rider_deliveries',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return const RiderDeliveriesScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.riderEarnings,
          name: 'rider_earnings',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return const RiderEarningsScreen();
          },
        ),

        // ============================================================
        // PROFILE ROUTE (Common for all)
        // ============================================================
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return const ProfileScreen();
          },
        ),
      ],
    ),
  ],

  // ============================================================
  // ERROR HANDLER
  // ============================================================
  errorBuilder: (context, state) {
    debugPrint('❌ Error: ${state.error}');
    debugPrint('❌ Error location: ${state.matchedLocation}');

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Page not found',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Route: ${state.matchedLocation}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.splash);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF98001F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Go Home', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
