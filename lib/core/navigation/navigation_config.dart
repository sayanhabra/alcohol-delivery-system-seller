// core/config/navigation_config.dart

import 'package:adm_seller/core/config/app_icons.dart';
import 'package:adm_seller/core/config/app_router.dart';
import 'package:adm_seller/modules/dashboard/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// ============================================================
// USER TYPES
// ============================================================

const String USER_TYPE_USER = 'user';
const String USER_TYPE_VENDOR = 'vendor';
const String USER_TYPE_RIDER = 'rider';

// ============================================================
// SCREENS
// ============================================================

class FevoriteScreen extends StatelessWidget {
  const FevoriteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Fevorite Screen'));
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Orders Screen'));
  }
}

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Vendor Dashboard'));
  }
}

class VendorOrdersScreen extends StatelessWidget {
  const VendorOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Vendor Orders'));
  }
}

class VendorProductsScreen extends StatelessWidget {
  const VendorProductsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Vendor Products'));
  }
}

class RiderDashboardScreen extends StatelessWidget {
  const RiderDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Rider Dashboard'));
  }
}

class RiderDeliveriesScreen extends StatelessWidget {
  const RiderDeliveriesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Rider Deliveries'));
  }
}

class RiderEarningsScreen extends StatelessWidget {
  const RiderEarningsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Rider Earnings'));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Screen'));
  }
}

class AllCategoryScreen extends StatelessWidget {
  const AllCategoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('All category Screen'));
  }
}
// ============================================================
// NAVIGATION ITEM MODEL
// ============================================================

class NavigationItem {
  final String label;
  final String iconPath; // Changed from IconData to String
  final String activeIconPath; // Changed from IconData to String
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
  // Get user type name for display
  static String getUserTypeName(String? userType) {
    switch (userType) {
      case USER_TYPE_USER:
        return 'User';
      case USER_TYPE_VENDOR:
        return 'Vendor';
      case USER_TYPE_RIDER:
        return 'Rider';
      default:
        return 'User';
    }
  }

  // ============================================================
  // ALL NAVIGATION ITEMS BY USER TYPE
  // ============================================================

  // User Items (Customer)
  static final List<NavigationItem> userItems = [
    NavigationItem(
      label: 'Home',
      iconPath: AppIcons.home, // SVG path
      activeIconPath: AppIcons.home, // Same SVG with different color
      route: AppRoutes.home,
      screen: const HomeScreen(),
      allowedUserTypes: [USER_TYPE_USER],
    ),
    NavigationItem(
      label: 'Favorite',
      iconPath: AppIcons.fav, // SVG path
      activeIconPath: AppIcons.fav, // Same SVG with different color
      route: '/fevorite',
      screen: const FevoriteScreen(),
      allowedUserTypes: [USER_TYPE_USER],
    ),
    NavigationItem(
      label: 'All',
      iconPath: AppIcons.all, // SVG path
      activeIconPath: AppIcons.all, // Same SVG with different color
      route: '/allcategory',
      screen: const AllCategoryScreen(),
      allowedUserTypes: [USER_TYPE_USER],
    ),
    NavigationItem(
      label: 'Orders',
      iconPath: AppIcons.cart, // SVG path
      activeIconPath: AppIcons.cart, // Same SVG with different color
      route: '/orders',
      screen: const OrdersScreen(),
      allowedUserTypes: [USER_TYPE_USER],
    ),
    NavigationItem(
      label: 'Profile',
      iconPath: AppIcons.profile, // SVG path
      activeIconPath: AppIcons.profile, // Same SVG with different color
      route: '/profile',
      screen: const ProfileScreen(),
      allowedUserTypes: [USER_TYPE_USER],
    ),
  ];

  // Vendor Items
  static final List<NavigationItem> vendorItems = [
    // NavigationItem(
    //   label: 'Dashboard',
    //   icon: Icons.dashboard_outlined,
    //   activeIcon: Icons.dashboard,
    //   route: '/vendor/dashboard',
    //   screen: const VendorDashboardScreen(),
    //   allowedUserTypes: [USER_TYPE_VENDOR],
    // ),
    // NavigationItem(
    //   label: 'Orders',
    //   icon: Icons.receipt_outlined,
    //   activeIcon: Icons.receipt,
    //   route: '/vendor/orders',
    //   screen: const VendorOrdersScreen(),
    //   allowedUserTypes: [USER_TYPE_VENDOR],
    // ),
    // NavigationItem(
    //   label: 'Products',
    //   icon: Icons.inventory_2_outlined,
    //   activeIcon: Icons.inventory_2,
    //   route: '/vendor/products',
    //   screen: const VendorProductsScreen(),
    //   allowedUserTypes: [USER_TYPE_VENDOR],
    // ),
    // NavigationItem(
    //   label: 'Profile',
    //   icon: Icons.person_outline,
    //   activeIcon: Icons.person,
    //   route: '/profile',
    //   screen: const ProfileScreen(),
    //   allowedUserTypes: [USER_TYPE_VENDOR],
    // ),
  ];

  // Rider Items
  static final List<NavigationItem> riderItems = [
    // NavigationItem(
    //   label: 'Dashboard',
    //   icon: Icons.dashboard_outlined,
    //   activeIcon: Icons.dashboard,
    //   route: '/rider/dashboard',
    //   screen: const RiderDashboardScreen(),
    //   allowedUserTypes: [USER_TYPE_RIDER],
    // ),
    // NavigationItem(
    //   label: 'Deliveries',
    //   icon: Icons.delivery_dining_outlined,
    //   activeIcon: Icons.delivery_dining,
    //   route: '/rider/deliveries',
    //   screen: const RiderDeliveriesScreen(),
    //   allowedUserTypes: [USER_TYPE_RIDER],
    // ),
    // NavigationItem(
    //   label: 'Earnings',
    //   icon: Icons.payments_outlined,
    //   activeIcon: Icons.payments,
    //   route: '/rider/earnings',
    //   screen: const RiderEarningsScreen(),
    //   allowedUserTypes: [USER_TYPE_RIDER],
    // ),
    // NavigationItem(
    //   label: 'Profile',
    //   icon: Icons.person_outline,
    //   activeIcon: Icons.person,
    //   route: '/profile',
    //   screen: const ProfileScreen(),
    //   allowedUserTypes: [USER_TYPE_RIDER],
    // ),
  ];

  // ============================================================
  // GET ITEMS BY USER TYPE
  // ============================================================

  static List<NavigationItem> getItemsForUser(String? userType) {
    debugPrint('🔍 Getting navigation items for user type: $userType');

    switch (userType) {
      case USER_TYPE_VENDOR:
        return vendorItems;
      case USER_TYPE_RIDER:
        return riderItems;
      case USER_TYPE_USER:
      default:
        return userItems;
    }
  }

  // Get default route for user type
  static String getDefaultRoute(String? userType) {
    final items = getItemsForUser(userType);
    return items.isNotEmpty ? items.first.route : '/home';
  }

  // Get initial index for user type (usually 0)
  static int getInitialIndex(String? userType) {
    return 0;
  }
}

// ============================================================
// RIVERPOD PROVIDERS
// ============================================================

// Provider for user type (replace with your actual user type provider)
final userTypeProvider = StateProvider<String?>((ref) => null);

// Provider for navigation items based on user type
final navigationItemsProvider = Provider<List<NavigationItem>>((ref) {
  final userType = ref.watch(userTypeProvider);
  return NavigationConfig.getItemsForUser(userType);
});

// Provider for current selected index
final selectedIndexProvider = StateProvider<int>((ref) {
  final userType = ref.watch(userTypeProvider);
  return NavigationConfig.getInitialIndex(userType);
});

// Provider for current navigation item
final currentNavigationItemProvider = Provider<NavigationItem>((ref) {
  final items = ref.watch(navigationItemsProvider);
  final index = ref.watch(selectedIndexProvider);
  return items[index];
});
