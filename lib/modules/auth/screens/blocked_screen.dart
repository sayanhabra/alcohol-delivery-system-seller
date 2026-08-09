// modules/auth/screens/blocked_screen.dart

import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/core/shared/widgets/buttons.dart';
import 'package:adm_seller/modules/auth/providers/auth_provider.dart';
import 'package:adm_seller/modules/auth/screens/auth_status_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockedScreen extends ConsumerWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthStatusScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.block_flipped,
              size: 48,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: AppStyle.spaceXXLarge),
          Text(
            'Account Blocked',
            textAlign: TextAlign.center,
            style: AppStyle.heading3.copyWith(
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: AppStyle.spaceMedium),
          Text(
            'Your seller account has been blocked due to violation of our terms. Please contact support for more information.',
            textAlign: TextAlign.center,
            style: AppStyle.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppStyle.spaceXLarge),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppStyle.spaceLarge),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.04),
              borderRadius: AppStyle.borderRadiusMedium,
            ),
            child: Column(
              children: [
                _buildContactRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: 'support@fluup.online',
                ),
                const Divider(height: AppStyle.spaceXLarge),
                _buildContactRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: '+91 1800-123-4567',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyle.spaceXXLarge),
          SecondaryButton(
            text: 'Contact Support',
            horizontalMargin: 0,
            height: 56,
            state: ButtonState.enabled,
            onPressed: () {
              // TODO: Open email/phone intent
            },
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          TextButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
            child: Text(
              'Back to Login',
              style: AppStyle.label.copyWith(
                color: const Color(0xFF98001F),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppStyle.textSecondary),
        const SizedBox(width: AppStyle.spaceMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyle.bodySmall.copyWith(
                  color: AppStyle.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppStyle.titleSmall.copyWith(color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
