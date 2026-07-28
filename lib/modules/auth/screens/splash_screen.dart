import 'package:adm_seller/core/config/app_router.dart';
import 'package:adm_seller/core/shared/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  void _onNext() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _onSkip() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    color: const Color(0xFFE57373),
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
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
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
                        ? const Color(0xFF98001F)
                        : Colors.grey.shade300,
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
