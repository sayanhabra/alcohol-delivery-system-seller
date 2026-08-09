// modules/dashboard/screens/profile_screen.dart

import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/core/shared/widgets/buttons.dart';
import 'package:adm_seller/modules/auth/models/user_model.dart';
import 'package:adm_seller/modules/auth/models/verification_status_enum.dart';
import 'package:adm_seller/modules/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final status = user?.verificationStatus ?? VerificationStatus.unknown;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyle.spaceLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Status Banner ───
              _StatusBanner(status: status),
              const SizedBox(height: AppStyle.spaceXLarge),

              // ─── Profile Header ───
              _ProfileHeader(user: user),
              const SizedBox(height: AppStyle.spaceXLarge),

              // ─── Store / Account Info ───
              _InfoCard(
                title: 'Account Info',
                items: [
                  _InfoRow(label: 'Name', value: user?.name ?? '-'),
                  _InfoRow(label: 'Phone', value: user?.phone ?? '-'),
                  _InfoRow(label: 'Role', value: user?.role ?? '-'),
                ],
              ),
              const SizedBox(height: AppStyle.spaceLarge),

              // ─── Verification Status Detail ───
              _InfoCard(
                title: 'Verification Status',
                items: [
                  _InfoRow(
                    label: 'Status',
                    value: status.value,
                    valueColor: _statusColor(status),
                  ),
                ],
              ),
              const SizedBox(height: AppStyle.spaceXXLarge),

              // ─── Logout ───
              SecondaryButton(
                text: 'Logout',
                horizontalMargin: 0,
                height: 52,
                state: ButtonState.enabled,
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(VerificationStatus status) {
    return switch (status) {
      VerificationStatus.verified => Colors.green,
      VerificationStatus.pendingVerification => Colors.orange,
      VerificationStatus.underReview => Colors.orange,
      VerificationStatus.rejected => const Color(0xFF98001F),
      VerificationStatus.blocked => Colors.grey,
      _ => Colors.black54,
    };
  }
}

// ==================== STATUS BANNER ====================

class _StatusBanner extends StatelessWidget {
  final VerificationStatus status;

  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    // VERIFIED → no banner needed
    if (status.isVerified) return const SizedBox.shrink();

    final config = _bannerConfig(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppStyle.spaceLarge),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: AppStyle.borderRadiusMedium,
        border: Border.all(color: config.borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: config.iconColor, size: 28),
              const SizedBox(width: AppStyle.spaceMedium),
              Expanded(
                child: Text(
                  config.title,
                  style: AppStyle.titleMedium.copyWith(
                    color: config.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (config.subtitle != null) ...[
            const SizedBox(height: AppStyle.spaceSmall),
            Text(
              config.subtitle!,
              style: AppStyle.bodySmall.copyWith(color: config.subtitleColor),
            ),
          ],
          if (config.actionLabel != null) ...[
            const SizedBox(height: AppStyle.spaceMedium),
            TextButton(
              onPressed: config.onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                config.actionLabel!,
                style: AppStyle.label.copyWith(
                  color: const Color(0xFF98001F),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _BannerConfig _bannerConfig(VerificationStatus status) {
    return switch (status) {
      VerificationStatus.pendingVerification => _BannerConfig(
        title: 'Documents Pending Verification',
        subtitle:
            'Your documents have been submitted and are being verified. This usually takes 24-48 hours.',
        icon: Icons.hourglass_top_rounded,
        bgColor: Colors.orange.withValues(alpha: 0.08),
        borderColor: Colors.orange.withValues(alpha: 0.3),
        iconColor: Colors.orange,
        textColor: Colors.orange.shade900,
        subtitleColor: Colors.orange.shade700,
      ),
      VerificationStatus.underReview => _BannerConfig(
        title: 'Account Under Review',
        subtitle:
            'Our team is reviewing your application. You will be notified once the review is complete.',
        icon: Icons.visibility_rounded,
        bgColor: Colors.orange.withValues(alpha: 0.08),
        borderColor: Colors.orange.withValues(alpha: 0.3),
        iconColor: Colors.orange,
        textColor: Colors.orange.shade900,
        subtitleColor: Colors.orange.shade700,
      ),
      VerificationStatus.rejected => _BannerConfig(
        title: 'Verification Rejected',
        subtitle:
            'Your verification was rejected. Please check the reason and re-submit your documents.',
        icon: Icons.cancel_outlined,
        bgColor: const Color(0xFF98001F).withValues(alpha: 0.06),
        borderColor: const Color(0xFF98001F).withValues(alpha: 0.2),
        iconColor: const Color(0xFF98001F),
        textColor: const Color(0xFF98001F),
        subtitleColor: Colors.red.shade700,
        actionLabel: 'Re-upload Documents →',
        onAction: () {
          // Navigate to verification submission
          // context.push('/auth/verification-submission');
        },
      ),
      VerificationStatus.blocked => _BannerConfig(
        title: 'Account Blocked',
        subtitle:
            'Your account has been blocked. Please contact support for assistance.',
        icon: Icons.block_flipped,
        bgColor: Colors.grey.withValues(alpha: 0.08),
        borderColor: Colors.grey.withValues(alpha: 0.3),
        iconColor: Colors.grey.shade700,
        textColor: Colors.grey.shade800,
        subtitleColor: Colors.grey.shade600,
        actionLabel: 'Contact Support',
        onAction: () {
          /* open support */
        },
      ),
      _ => _BannerConfig(
        title: 'Unknown Status',
        icon: Icons.help_outline,
        bgColor: Colors.grey.withValues(alpha: 0.08),
        borderColor: Colors.grey.withValues(alpha: 0.3),
        iconColor: Colors.grey,
        textColor: Colors.black87,
        subtitleColor: Colors.grey,
      ),
    };
  }
}

class _BannerConfig {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color subtitleColor;

  _BannerConfig({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.subtitleColor,
  });
}

// ==================== PROFILE HEADER ====================

class _ProfileHeader extends StatelessWidget {
  final UserModel? user;

  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF98001F).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: user?.profileImage != null
                ? ClipOval(
                    child: Image.network(
                      user!.profileImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.storefront,
                    size: 40,
                    color: Color(0xFF98001F),
                  ),
          ),
          const SizedBox(height: AppStyle.spaceMedium),
          Text(
            user?.name ?? 'Seller',
            style: AppStyle.heading4.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '+91 ${user?.phone ?? ''}',
            style: AppStyle.bodyMedium.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ==================== INFO CARD ====================

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _InfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppStyle.spaceLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyle.borderRadiusMedium,
        border: Border.all(color: AppStyle.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyle.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppStyle.spaceMedium),
          const Divider(height: 1),
          const SizedBox(height: AppStyle.spaceMedium),
          ...items,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyle.spaceSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyle.bodyMedium.copyWith(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: AppStyle.bodyMedium.copyWith(
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
