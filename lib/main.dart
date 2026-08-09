import 'package:adm_seller/core/config/app_router.dart';
import 'package:adm_seller/core/config/app_theme.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Optional: Set initial user type for testing
    // ref.read(userTypeProvider.notifier).state = USER_TYPE_USER;
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // GoRouter
      routerConfig: router, // Use the appRouter from app_router.dart
      // BotToast
      builder: (context, child) {
        return BotToastInit()(context, child);
      },
    );
  }
}
