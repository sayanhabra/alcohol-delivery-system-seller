// modules/auth/screens/auth_loading_screen.dart

import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:flutter/material.dart';

class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/png/logobanner.png', height: 100, width: 100),
            const SizedBox(height: AppStyle.spaceXLarge),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Color(0xFF98001F)),
              ),
            ),
            const SizedBox(height: AppStyle.spaceLarge),
            Text(
              'Please wait...',
              style: AppStyle.bodyMedium.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
