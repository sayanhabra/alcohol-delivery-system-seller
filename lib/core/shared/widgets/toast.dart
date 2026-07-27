import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppToastType { success, error, warning, info, plain }

class AppToast {
  AppToast._();

  // ============================================================
  // SUCCESS TOAST
  // ============================================================

  static CancelFunc success({
    required String title,
    String? message,
    Widget? icon,
    Duration? duration,
  }) {
    return _show(
      title: title,
      message: message,
      type: AppToastType.success,
      icon: icon,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  // ============================================================
  // ERROR TOAST
  // ============================================================

  static CancelFunc error({
    required String title,
    String? message,
    Widget? icon,
    Duration? duration,
  }) {
    return _show(
      title: title,
      message: message,
      type: AppToastType.error,
      icon: icon,
      duration: duration ?? Duration(seconds: kDebugMode ? 10 : 5),
    );
  }

  // ============================================================
  // WARNING TOAST
  // ============================================================

  static CancelFunc warning({
    required String title,
    String? message,
    Widget? icon,
    Duration? duration,
  }) {
    return _show(
      title: title,
      message: message,
      type: AppToastType.warning,
      icon: icon,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  // ============================================================
  // INFO TOAST
  // ============================================================

  static CancelFunc info({
    required String title,
    String? message,
    Widget? icon,
    Duration? duration,
  }) {
    return _show(
      title: title,
      message: message,
      type: AppToastType.info,
      icon: icon,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  // ============================================================
  // PLAIN TOAST
  // ============================================================

  static CancelFunc plain({
    required String title,
    String? message,
    Widget? icon,
    Duration? duration,
  }) {
    return _show(
      title: title,
      message: message,
      type: AppToastType.plain,
      icon: icon,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  // ============================================================
  // COMMON TOAST BUILDER
  // ============================================================

  static CancelFunc _show({
    required String title,
    String? message,
    required AppToastType type,
    Widget? icon,
    required Duration duration,
  }) {
    // Avoid showing empty toast.
    if (title.trim().isEmpty) {
      return () {};
    }

    final config = _getConfig(type);

    return BotToast.showCustomNotification(
      duration: duration,

      toastBuilder: (cancelFunc) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: config.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: config.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------
                // ICON
                // --------------------------------------------
                icon ??
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: config.iconColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        config.icon,
                        color: config.iconColor,
                        size: 21,
                      ),
                    ),

                const SizedBox(width: 12),

                // --------------------------------------------
                // CONTENT
                // --------------------------------------------
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: config.textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (message != null && message.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),

                        Text(
                          message,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: config.textColor.withOpacity(0.75),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // --------------------------------------------
                // CLOSE BUTTON
                // --------------------------------------------
                InkWell(
                  onTap: cancelFunc,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: config.textColor.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // TOAST CONFIG
  // ============================================================

  static _ToastConfig _getConfig(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return const _ToastConfig(
          backgroundColor: Color(0xFFEAF8EE),
          borderColor: Color(0xFFB7E4C2),
          iconColor: Color(0xFF2E9B4F),
          textColor: Color(0xFF1E432A),
          icon: Icons.check_circle_rounded,
        );

      case AppToastType.error:
        return const _ToastConfig(
          backgroundColor: Color(0xFFFFEDE8),
          borderColor: Color(0xFFFFC4B3),
          iconColor: Color(0xFFE53935),
          textColor: Color(0xFF5A211F),
          icon: Icons.error_rounded,
        );

      case AppToastType.warning:
        return const _ToastConfig(
          backgroundColor: Color(0xFFFFF7E0),
          borderColor: Color(0xFFFFD978),
          iconColor: Color(0xFFF9A825),
          textColor: Color(0xFF5C4612),
          icon: Icons.warning_amber_rounded,
        );

      case AppToastType.info:
        return const _ToastConfig(
          backgroundColor: Color(0xFFEAF4FF),
          borderColor: Color(0xFFB7D8F7),
          iconColor: Color(0xFF1976D2),
          textColor: Color(0xFF173F63),
          icon: Icons.info_rounded,
        );

      case AppToastType.plain:
        return const _ToastConfig(
          backgroundColor: Colors.white,
          borderColor: Color(0xFFE5E5E5),
          iconColor: Color(0xFF5E6162),
          textColor: Color(0xFF222222),
          icon: Icons.notifications_rounded,
        );
    }
  }

  // ============================================================
  // CLOSE ALL TOASTS
  // ============================================================

  static void closeAll() {
    BotToast.cleanAll();
  }
}

// ============================================================
// INTERNAL CONFIG MODEL
// ============================================================

class _ToastConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  const _ToastConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}
