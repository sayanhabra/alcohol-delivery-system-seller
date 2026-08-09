// modules/auth/screens/under_review_screen.dart

import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/modules/auth/screens/auth_status_scaffold.dart';
import 'package:flutter/material.dart';

class UnderReviewScreen extends StatelessWidget {
  const UnderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthStatusScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 48,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: AppStyle.spaceXXLarge),
          Text(
            'Under Review',
            textAlign: TextAlign.center,
            style: AppStyle.heading3.copyWith(
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: AppStyle.spaceMedium),
          Text(
            'Your documents have been submitted successfully. Our team is reviewing your application. This usually takes 24-48 hours.',
            textAlign: TextAlign.center,
            style: AppStyle.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppStyle.spaceXLarge),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyle.spaceLarge,
              vertical: AppStyle.spaceMedium,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: AppStyle.borderRadiusMedium,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: AppStyle.spaceSmall),
                Text(
                  'You will be notified once approved',
                  style: AppStyle.bodySmall.copyWith(
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyle.spaceXXLarge),
          TextButton(
            onPressed: () {
              // TODO: Refresh status or logout
            },
            child: Text(
              'Check Status',
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
}
