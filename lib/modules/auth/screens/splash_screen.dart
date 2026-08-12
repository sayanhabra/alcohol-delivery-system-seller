import 'package:adm_seller/core/config/app_router.dart';
import 'package:adm_seller/core/config/app_theme.dart';
import 'package:adm_seller/core/shared/styles/app_colors.dart';
import 'package:adm_seller/core/shared/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/png/banner1.png',
      'title': 'Move your store online',
      'subtitle': 'Grow your business fluently',
    },
    {
      'image': 'assets/png/banner2.png',
      'title': 'Manage your order on your control',
      'subtitle': '',
    },
    {
      'image': 'assets/png/banner3.png',
      'title': 'Get payment after delivered your order',
      'subtitle': '',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('onboarding_completed', true);

      if (!mounted) return;

      context.go(AppRoutes.login);
    }
  }

  Future<void> _onSkip() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;

    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? ColorName.primaryBackgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onSkip,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: ColorName.skipRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_onboardingData[index]['title']!.isNotEmpty)
                          Text(
                            _onboardingData[index]['title']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        // const SizedBox(height: 20),
                        Image.asset(
                          _onboardingData[index]['image']!,
                          height: 250,
                          width: 220,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        if (_onboardingData[index]['subtitle']!.isNotEmpty)
                          Text(
                            _onboardingData[index]['subtitle']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 8 : 6,
                  height: _currentPage == index ? 8 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? ColorName.primaryBrandRed
                        : (isDark ? Colors.white24 : Colors.grey.shade300),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Next / Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: SecondaryButton(
                text: _currentPage == _onboardingData.length - 1
                    ? 'Get Started'
                    : 'Next',
                horizontalMargin: 0,
                height: 56,
                onPressed: _onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
