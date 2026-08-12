import 'package:adm_seller/core/config/app_theme.dart';
import 'package:adm_seller/core/shared/styles/app_colors.dart';
import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/core/shared/widgets/buttons.dart';
import 'package:adm_seller/modules/auth/screens/auth_status_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RejectedRetryScreen extends ConsumerWidget {
  const RejectedRetryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;

    return AuthStatusScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_outlined,
              size: 48,
              color: ColorName.primaryBrandRed,
            ),
          ),
          const SizedBox(height: AppStyle.spaceXXLarge),
          Text(
            'Verification Rejected',
            textAlign: TextAlign.center,
            style: AppStyle.heading3.copyWith(
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: AppStyle.spaceMedium),
          Text(
            'Your verification was rejected due to unclear documents. Please re-upload clear and valid documents to continue.',
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
              color: isDark ? Colors.redAccent.withValues(alpha: 0.08) : Colors.red.withValues(alpha: 0.04),
              border: Border.all(
                color: isDark ? Colors.redAccent.withValues(alpha: 0.4) : Colors.red.withValues(alpha: 0.2),
                width: 1.5,
              ),
              borderRadius: AppStyle.borderRadiusMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason:',
                  style: AppStyle.titleSmall.copyWith(
                    color: ColorName.primaryBrandRed,
                  ),
                ),
                const SizedBox(height: AppStyle.spaceSmall),
                Text(
                  '• GST certificate image was blurry\n• Store photo did not match address',
                  style: AppStyle.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyle.spaceXXLarge),
          SecondaryButton(
            text: 'Re-upload Documents',
            horizontalMargin: 0,
            height: 56,
            state: ButtonState.enabled,
            onPressed: () {
              context.go('/auth/verification-submission');
            },
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          TextButton(
            onPressed: () {
              // TODO: Contact support
            },
            child: Text(
              'Contact Support',
              style: AppStyle.label.copyWith(
                color: ColorName.primaryBrandRed,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

