import 'package:adm_seller/core/navigation/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key, required this.navigationShell});

  final Widget navigationShell;

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
