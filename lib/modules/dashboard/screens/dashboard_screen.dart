// modules/dashboard/screens/dashboard_screen.dart

import 'package:adm_seller/core/navigation/bottom_nav_bar.dart';
import 'package:adm_seller/core/navigation/navigation_config.dart';
import 'package:adm_seller/core/shared/helpers/location_helper.dart';
// import 'package:adm_seller/core/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final LocationHelper _locationHelper = LocationHelper.instance;
  bool _isLocationReady = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // ============================================================
  // CHECK LOCATION PERMISSION
  // ============================================================

  Future<void> _checkLocationPermission() async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await _locationHelper.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location service is disabled. Please enable it.';
        });
        return;
      }

      // Check permission
      LocationPermission permission = await _locationHelper.checkPermission();

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await _locationHelper.requestPermission();
      }

      // Handle permission states
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError =
              'Location permission was denied. Please grant permission.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError =
              'Location permission is permanently denied. Please enable it from settings.';
        });
        return;
      }

      // Permission granted
      setState(() {
        _isLocationReady = true;
        _locationError = null;
      });

      debugPrint('✅ Location permission granted in Dashboard');
    } catch (e) {
      setState(() {
        _locationError = 'Unable to check location permission: $e';
      });
      debugPrint('❌ Location permission error: $e');
    }
  }

  // ============================================================
  // OPEN SETTINGS
  // ============================================================

  Future<void> _openSettings() async {
    await _locationHelper.openAppSettings();
    // Check again after returning from settings
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkLocationPermission();
      }
    });
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildBody() {
    // If location error, show error screen
    if (_locationError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 80, color: Colors.red.shade300),
              const SizedBox(height: 24),
              Text(
                'Location Required',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _locationError!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _openSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _checkLocationPermission,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // If location is ready, show the navigation shell
    if (_isLocationReady) {
      return const _DashboardShell();
    }

    // Loading state
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Checking location permission...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DASHBOARD SHELL
// ============================================================

class _DashboardShell extends ConsumerStatefulWidget {
  const _DashboardShell();

  @override
  ConsumerState<_DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<_DashboardShell> {
  @override
  Widget build(BuildContext context) {
    final items = ref.watch(navigationItemsProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);

    if (items.isEmpty) {
      return const Center(child: Text('No navigation items found'));
    }

    return IndexedStack(
      index: selectedIndex,
      children: items.map((item) => item.screen).toList(),
    );
  }
}
