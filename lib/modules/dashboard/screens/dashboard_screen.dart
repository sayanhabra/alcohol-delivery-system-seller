// modules/dashboard/screens/dashboard_screen.dart

import 'package:adm_seller/core/config/app_icons.dart';
import 'package:adm_seller/core/shared/helpers/location_helper.dart';
// import 'package:adm_seller/features/auth/providers/auth_provider.dart';
import 'package:adm_seller/modules/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';

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

  Future<void> _checkLocationPermission() async {
    try {
      final serviceEnabled = await _locationHelper.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(
          () => _locationError =
              'Location service is disabled. Please enable it.',
        );
        return;
      }

      LocationPermission permission = await _locationHelper.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await _locationHelper.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() => _locationError = 'Location permission was denied.');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(
          () => _locationError =
              'Location permission permanently denied. Enable from settings.',
        );
        return;
      }

      setState(() => _isLocationReady = true);
    } catch (e) {
      setState(() => _locationError = 'Unable to check location: $e');
    }
  }

  Future<void> _openSettings() async {
    await _locationHelper.openAppSettings();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _checkLocationPermission();
    });
  }

  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    // Router redirect will automatically send to /login
  }

  @override
  Widget build(BuildContext context) {
    if (_locationError != null) {
      return _buildErrorState();
    }

    if (!_isLocationReady) {
      return Center(
        child: Lottie.asset(AppIcons.loading, height: 200, width: 200),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Color(0xFF98001F)),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(
        child: Text('Dashboard Content', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
}
