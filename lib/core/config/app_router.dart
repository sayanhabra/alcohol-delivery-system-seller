// // core/navigation/app_router.dart

// import 'package:adm_seller/core/navigation/main_navigation_shell.dart';
// import 'package:adm_seller/core/navigation/navigation_config.dart';
// import 'package:adm_seller/modules/auth/models/verification_status_enum.dart';
// import 'package:adm_seller/modules/auth/providers/auth_provider.dart';
// import 'package:adm_seller/modules/dashboard/screens/home_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../modules/auth/screens/login_screen.dart';
// import '../../modules/auth/screens/splash_screen.dart';
// import '../../modules/auth/screens/profile_setup_screen.dart';
// import '../../modules/auth/screens/verification_submission_screen.dart';
// import '../../modules/auth/screens/under_review_screen.dart';
// import '../../modules/auth/screens/rejected_retry_screen.dart';
// import '../../modules/auth/screens/blocked_screen.dart';
// import '../../modules/dashboard/screens/dashboard_screen.dart';

// class AppRoutes {
//   static const String splash = '/splash';
//   static const String login = '/login';
//   static const String profileSetup = '/auth/profile-setup';
//   static const String verificationSubmission = '/auth/verification-submission';
//   static const String underReview = '/auth/under-review';
//   static const String rejectedRetry = '/auth/rejected';
//   static const String blocked = '/auth/blocked';
//   static const String dashboard = '/dashboard';
//   static const String home = '/home';
//   static const String orders = '/orders';
//   static const String allCategory = '/allcategory';
//   static const String vendorDashboard = '/vendor/dashboard';
//   static const String vendorOrders = '/vendor/orders';
//   static const String vendorProducts = '/vendor/products';
//   static const String riderDashboard = '/rider/dashboard';
//   static const String riderDeliveries = '/rider/deliveries';
//   static const String riderEarnings = '/rider/earnings';
//   static const String profile = '/profile';
// }

// final rootNavigatorKey = GlobalKey<NavigatorState>();
// final shellNavigatorKey = GlobalKey<NavigatorState>();

// class _RouterRefresh extends ChangeNotifier {
//   _RouterRefresh(this.ref) {
//     ref.listen(authNotifierProvider, (_, __) => notifyListeners());
//   }
//   final Ref ref;
// }

// final appRouterProvider = Provider<GoRouter>((ref) {
//   return GoRouter(
//     navigatorKey: rootNavigatorKey,
//     initialLocation: AppRoutes.splash,
//     debugLogDiagnostics: true,
//     refreshListenable: _RouterRefresh(ref),

//     redirect: (context, state) {
//       final authAsync = ref.read(authNotifierProvider);
//       final currentPath = state.matchedLocation;

//       // ─── LOGIN SCREEN IS SACRED ───
//       // Never redirect away from /login. LoginScreen handles mobile→name→otp
//       // internally with its own loading overlay and AnimatedSwitcher.
//       if (currentPath == AppRoutes.login) return null;

//       // ─── SPLASH ───
//       // Splash always shows first. When it finishes, it calls context.go(/login).
//       // Until then, stay on splash.
//       if (currentPath == AppRoutes.splash) return null;

//       // ─── LOADING (app init / auto-login check) ───
//       if (authAsync.isLoading) {
//         return AppRoutes.splash;
//       }

//       final authState = authAsync.asData?.value;

//       // ─── NOT AUTHENTICATED ───
//       // Any non-auth route besides splash/login → kick to login
//       if (authState is! AuthAuthenticated) {
//         return AppRoutes.login;
//       }

//       // ─── AUTHENTICATED ───
//       // Map verification status to the correct screen
//       final status = authState.user.verificationStatus;

//       final String targetRoute = switch (status) {
//         VerificationStatus.pendingProfile => AppRoutes.profileSetup,
//         VerificationStatus.pendingVerification =>
//           AppRoutes.verificationSubmission,
//         VerificationStatus.underReview => AppRoutes.underReview,
//         VerificationStatus.rejected => AppRoutes.rejectedRetry,
//         VerificationStatus.blocked => AppRoutes.blocked,
//         VerificationStatus.verified => AppRoutes.dashboard,
//         _ => AppRoutes.dashboard,
//       };

//       if (currentPath == targetRoute) return null;
//       return targetRoute;
//     },

//     routes: [
//       GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
//       GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
//       GoRoute(
//         path: AppRoutes.profileSetup,
//         builder: (_, __) => const ProfileSetupScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.verificationSubmission,
//         builder: (_, __) => const VerificationSubmissionScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.underReview,
//         builder: (_, __) => const UnderReviewScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.rejectedRetry,
//         builder: (_, __) => const RejectedRetryScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.blocked,
//         builder: (_, __) => const BlockedScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.dashboard,
//         builder: (_, __) => const DashboardScreen(),
//       ),
//       ShellRoute(
//         navigatorKey: shellNavigatorKey,
//         builder: (context, state, child) {
//           return MainNavigationShell(navigationShell: child);
//         },
//         routes: [
//           GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
//           GoRoute(
//             path: AppRoutes.orders,
//             builder: (_, __) => const OrdersScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.allCategory,
//             builder: (_, __) => const AllCategoryScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.vendorDashboard,
//             builder: (_, __) => const VendorDashboardScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.vendorOrders,
//             builder: (_, __) => const VendorOrdersScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.vendorProducts,
//             builder: (_, __) => const VendorProductsScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.riderDashboard,
//             builder: (_, __) => const RiderDashboardScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.riderDeliveries,
//             builder: (_, __) => const RiderDeliveriesScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.riderEarnings,
//             builder: (_, __) => const RiderEarningsScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.profile,
//             builder: (_, __) => const ProfileScreen(),
//           ),
//         ],
//       ),
//     ],

//     errorBuilder: (context, state) => Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline, size: 60, color: Colors.red),
//             const SizedBox(height: 16),
//             Text('Page not found: ${state.matchedLocation}'),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => context.go(AppRoutes.splash),
//               child: const Text('Go Home'),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// });

// core/navigation/app_router.dart

import 'package:adm_seller/core/navigation/main_navigation_shell.dart';
import 'package:adm_seller/core/navigation/navigation_config.dart';
import 'package:adm_seller/modules/auth/models/verification_status_enum.dart';
import 'package:adm_seller/modules/auth/providers/auth_provider.dart';
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
  static const String splash = '/splash';
  static const String login = '/login';
  static const String profileSetup = '/auth/profile-setup';
  static const String verificationSubmission = '/auth/verification-submission';
  static const String underReview = '/auth/under-review';
  static const String rejectedRetry = '/auth/rejected';
  static const String blocked = '/auth/blocked';

  // Main app shell routes
  static const String dashboard = '/dashboard';
  static const String orders = '/orders';
  static const String products = '/products';
  static const String profile = '/profile';
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this.ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: _RouterRefresh(ref),

    redirect: (context, state) {
      final authAsync = ref.read(authNotifierProvider);
      final currentPath = state.matchedLocation;

      // ─── LOADING ───
      // If user is on login or splash, stay there. LoginScreen has its own spinner.
      if (authAsync.isLoading) {
        if (currentPath == AppRoutes.login || currentPath == AppRoutes.splash) {
          return null;
        }
        return AppRoutes.splash;
      }

      final authState = authAsync.asData?.value;

      // ─── AUTHENTICATED ───
      if (authState is AuthAuthenticated) {
        final status = authState.user.verificationStatus;

        final String targetRoute = switch (status) {
          VerificationStatus.pendingProfile => AppRoutes.profileSetup,
          VerificationStatus.pendingVerification =>
            AppRoutes.verificationSubmission,
          VerificationStatus.underReview => AppRoutes.underReview,
          VerificationStatus.rejected => AppRoutes.rejectedRetry,
          VerificationStatus.blocked => AppRoutes.blocked,
          VerificationStatus.verified => AppRoutes.dashboard,
          _ => AppRoutes.dashboard,
        };

        // If on login or splash, redirect to where they should be
        if (currentPath == AppRoutes.login || currentPath == AppRoutes.splash) {
          return targetRoute;
        }

        // If on a status screen and status changed, redirect
        final statusRoutes = [
          AppRoutes.profileSetup,
          AppRoutes.verificationSubmission,
          AppRoutes.underReview,
          AppRoutes.rejectedRetry,
          AppRoutes.blocked,
        ];
        if (statusRoutes.contains(targetRoute) && currentPath != targetRoute) {
          return targetRoute;
        }

        return null;
      }

      // ─── NOT AUTHENTICATED ───
      // Allow splash and login. Everything else → login.
      if (currentPath == AppRoutes.login || currentPath == AppRoutes.splash) {
        return null;
      }
      return AppRoutes.login;
    },
    routes: [
      // Pre-auth routes
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),

      // Post-auth status screens (no bottom nav)
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

      // Main app shell with bottom navigation
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
          GoRoute(
            path: AppRoutes.orders,
            builder: (_, __) => const OrdersScreen(),
          ),
          GoRoute(
            path: AppRoutes.products,
            builder: (_, __) => const VendorProductsScreen(),
          ),
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
