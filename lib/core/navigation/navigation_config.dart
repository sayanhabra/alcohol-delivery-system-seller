// core/config/navigation_config.dart

import 'package:adm_seller/core/config/app_icons.dart';
import 'package:adm_seller/core/config/app_router.dart';
// import 'package:adm_seller/features/auth/providers/auth_provider.dart';
import 'package:adm_seller/modules/auth/providers/auth_provider.dart';
import 'package:adm_seller/modules/dashboard/screens/dashboard_screen.dart';
import 'package:adm_seller/modules/dashboard/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================
// USER TYPE CONSTANTS
// ============================================================

const String USER_TYPE_USER = 'user';
const String USER_TYPE_VENDOR = 'vendor';
const String USER_TYPE_RIDER = 'rider';

// ============================================================
// SCREEN PLACEHOLDERS (move to own files later)
// ============================================================

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Orders Screen'));
}

class SellerProductsScreen extends StatelessWidget {
  const SellerProductsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Products Screen'));
}

class AllCategoryScreen extends StatelessWidget {
  const AllCategoryScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Profile Screen'));
}

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Profile Screen'));
}

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Profile Screen'));
}

class RiderDashboardScreen extends StatelessWidget {
  const RiderDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Profile Screen'));
}

class RiderDeliveriesScreen extends StatelessWidget {
  const RiderDeliveriesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Profile Screen'));
}

class RiderEarningsScreen extends StatelessWidget {
  const RiderEarningsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Profile Screen'));
}
// ============================================================
// NAVIGATION ITEM MODEL
// ============================================================

class NavigationItem {
  final String label;
  final String iconPath;
  final String activeIconPath;
  final String route;
  final Widget screen;
  final List<String> allowedUserTypes;

  NavigationItem({
    required this.label,
    required this.iconPath,
    required this.activeIconPath,
    required this.route,
    required this.screen,
    required this.allowedUserTypes,
  });
}

// ============================================================
// NAVIGATION CONFIG
// ============================================================

class NavigationConfig {
  static String getUserTypeName(String? userType) {
    switch (userType) {
      case USER_TYPE_VENDOR:
        return 'Seller';
      case USER_TYPE_RIDER:
        return 'Rider';
      case USER_TYPE_USER:
      default:
        return 'User';
    }
  }

  // Seller navigation items
  static final List<NavigationItem> sellerItems = [
    NavigationItem(
      label: 'Home',
      iconPath: AppIcons.home,
      activeIconPath: AppIcons.home,
      route: AppRoutes.dashboard,
      screen: const DashboardScreen(),
      allowedUserTypes: [USER_TYPE_VENDOR],
    ),
    NavigationItem(
      label: 'Orders',
      iconPath: AppIcons.cart,
      activeIconPath: AppIcons.cart,
      route: AppRoutes.orders,
      screen: const OrdersScreen(),
      allowedUserTypes: [USER_TYPE_VENDOR],
    ),
    NavigationItem(
      label: 'Products',
      iconPath: AppIcons.all,
      activeIconPath: AppIcons.all,
      route: AppRoutes.products,
      screen: const SellerProductsScreen(),
      allowedUserTypes: [USER_TYPE_VENDOR],
    ),
    NavigationItem(
      label: 'Profile',
      iconPath: AppIcons.profile,
      activeIconPath: AppIcons.profile,
      route: AppRoutes.profile,
      screen: const ProfileScreen(),
      allowedUserTypes: [USER_TYPE_VENDOR],
    ),
  ];

  static List<NavigationItem> getItemsForUser(String? userType) {
    switch (userType) {
      case USER_TYPE_VENDOR:
        return sellerItems;
      case USER_TYPE_RIDER:
        return []; // Add rider items when needed
      case USER_TYPE_USER:
      default:
        return sellerItems; // Default to seller for this app
    }
  }
}

// ============================================================
// RIVERPOD PROVIDERS
// ============================================================

/// Derives user type from auth state so navigation updates automatically after login
final userTypeProvider = Provider<String?>((ref) {
  final auth = ref.watch(authNotifierProvider);
  final state = auth.asData?.value;
  if (state is AuthAuthenticated) {
    final role = state.user.role.toLowerCase();
    if (role == 'seller') return USER_TYPE_VENDOR;
    if (role == 'rider') return USER_TYPE_RIDER;
    return USER_TYPE_USER;
  }
  return null;
});

final navigationItemsProvider = Provider<List<NavigationItem>>((ref) {
  final userType = ref.watch(userTypeProvider);
  return NavigationConfig.getItemsForUser(userType);
});
