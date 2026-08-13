import 'package:adm_seller/core/navigation/main_navigation_shell.dart';
import 'package:adm_seller/core/navigation/navigation_config.dart';
import 'package:adm_seller/modules/auth/providers/auth_provider.dart';
import 'package:adm_seller/modules/auth/screens/startup_screen.dart';
import 'package:adm_seller/modules/dashboard/screens/home_screen.dart';
import 'package:adm_seller/modules/dashboard/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../modules/auth/screens/blocked_screen.dart';
import '../../modules/auth/screens/login_screen.dart';
import '../../modules/auth/screens/profile_setup_screen.dart';
import '../../modules/auth/screens/rejected_retry_screen.dart';
import '../../modules/auth/screens/splash_screen.dart';
import '../../modules/auth/screens/under_review_screen.dart';
import '../../modules/auth/screens/verification_submission_screen.dart';
import '../../modules/dashboard/screens/dashboard_screen.dart';

class AppRoutes {
  static const String startup = '/startup';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String profileSetup = '/auth/profile-setup';
  static const String verificationSubmission = '/auth/verification-submission';
  static const String underReview = '/auth/under-review';
  static const String rejectedRetry = '/auth/rejected';
  static const String blocked = '/auth/blocked';
  static const String dashboard = '/dashboard';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String allCategory = '/allcategory';
  static const String sellerDashboard = '/seller/dashboard';
  static const String sellerOrders = '/seller/orders';
  static const String riderDashboard = '/rider/dashboard';
  static const String riderDeliveries = '/rider/deliveries';
  static const String riderEarnings = '/rider/earnings';
  static const String profile = '/profile';
  static const String products = '/products';
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this.ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}

bool _isAppRoute(String path) {
  return path == AppRoutes.dashboard ||
      path == AppRoutes.orders ||
      path == AppRoutes.products ||
      path == AppRoutes.profile;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.startup,
    debugLogDiagnostics: true,
    refreshListenable: _RouterRefresh(ref),

    redirect: (context, state) {
      final authAsync = ref.read(authNotifierProvider);
      final currentPath = state.matchedLocation;

      print('========== GO ROUTER REDIRECT ==========');
      print('Current path: $currentPath');
      print('Auth Async: $authAsync');
      print('Is Loading: ${authAsync.isLoading}');
      print('Has Previous Value: ${authAsync.value != null}');
      print('Auth State: ${authAsync.value?.runtimeType}');

      if (authAsync.isLoading && authAsync.value == null) {
        if (currentPath == AppRoutes.startup) {
          return null;
        }

        return AppRoutes.startup;
      }

      final authState = authAsync.value;

      // ============================================================
      // AUTHENTICATED
      // ============================================================

      if (authState is AuthAuthenticated) {
        final status = authState.user.verificationStatus;

        print('USER STATUS: ${status.value}');
        print('AUTO VERIFIED: ${status.isAutoVerified}');
        print('VERIFIED: ${status.isVerified}');

        // ----------------------------------------------------------
        // DRAFT
        // ----------------------------------------------------------

        if (status.isDraft) {
          return currentPath == AppRoutes.profileSetup
              ? null
              : AppRoutes.profileSetup;
        }

        // ----------------------------------------------------------
        // AUTO VERIFIED / VERIFIED
        // FULL ACCESS
        // ----------------------------------------------------------

        if (status.isAutoVerified || status.isVerified) {
          print('FULL ACCESS');

          // Dashboard / Orders / Products / Profile
          if (_isAppRoute(currentPath)) {
            return null;
          }

          // Login / Splash / Loading
          // After authentication → Dashboard
          return AppRoutes.dashboard;
        }

        // ----------------------------------------------------------
        // ALL OTHER STATUSES
        // PROFILE ONLY
        // ----------------------------------------------------------

        print('PROFILE ONLY');

        if (currentPath == AppRoutes.profile) {
          return null;
        }

        return AppRoutes.profile;
      }

      // ============================================================
      // OTP / LOGIN FLOW
      // ============================================================

      if (authState is AuthPhoneChecked || authState is AuthOtpSent) {
        print('LOGIN / OTP FLOW');

        // Stay inside LoginScreen.
        //
        // LoginScreen internally changes:
        //
        // mobile → name → OTP
        //
        // so GoRouter should NOT interfere.
        return currentPath == AppRoutes.login ? null : AppRoutes.login;
      }

      // ============================================================
      // UNAUTHENTICATED
      // ============================================================

      if (authState is AuthUnauthenticated || authState == null) {
        if (currentPath == AppRoutes.login || currentPath == AppRoutes.splash) {
          return null;
        }

        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      // Pre-auth routes
      GoRoute(
        path: AppRoutes.startup,
        builder: (_, __) => const StartupScreen(),
      ),
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),

      // Post-auth status screens
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, __) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.verificationSubmission,
        builder: (_, __) => const VerificationSubmissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.underReview,
        builder: (_, __) => const UnderReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.rejectedRetry,
        builder: (_, __) => const RejectedRetryScreen(),
      ),
      GoRoute(
        path: AppRoutes.blocked,
        builder: (_, __) => const BlockedScreen(),
      ),

      // Main app shell
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return MainNavigationShell(navigationShell: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: AppRoutes.orders,
            builder: (_, __) => const OrdersScreen(),
          ),
          GoRoute(
            path: AppRoutes.allCategory,
            builder: (_, __) => const AllCategoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.sellerDashboard,
            builder: (_, __) => const SellerDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.sellerOrders,
            builder: (_, __) => const SellerOrdersScreen(),
          ),
          GoRoute(
            path: AppRoutes.products,
            builder: (_, __) => const SellerProductsScreen(),
          ),
          // GoRoute(
          //   path: AppRoutes.riderDashboard,
          //   builder: (_, __) => const RiderDashboardScreen(),
          // ),
          // GoRoute(
          //   path: AppRoutes.riderDeliveries,
          //   builder: (_, __) => const RiderDeliveriesScreen(),
          // ),
          // GoRoute(
          //   path: AppRoutes.riderEarnings,
          //   builder: (_, __) => const RiderEarningsScreen(),
          // ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
