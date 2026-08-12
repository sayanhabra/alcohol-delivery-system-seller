// modules/auth/screens/auth_loading_screen.dart

import 'package:adm_seller/core/config/app_theme.dart';
import 'package:adm_seller/core/shared/styles/app_colors.dart';
import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:flutter/material.dart';

class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? ColorName.primaryBackgroundDark : Colors.white,
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
                valueColor: AlwaysStoppedAnimation(ColorName.primaryBrandRed),
              ),
            ),
            const SizedBox(height: AppStyle.spaceLarge),
            Text(
              'Please wait...',
              style: AppStyle.bodyMedium.copyWith(
                color: isDark ? Colors.white70 : ColorName.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

