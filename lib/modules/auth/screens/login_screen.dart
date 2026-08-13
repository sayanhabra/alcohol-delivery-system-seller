// import 'package:adm_seller/core/config/app_router.dart';
// import 'package:adm_seller/core/shared/const/keys.dart';
// import 'package:adm_seller/core/shared/styles/app_style.dart';
// import 'package:adm_seller/core/shared/widgets/buttons.dart';
// import 'package:adm_seller/modules/auth/providers/auth_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final TextEditingController _mobileController = TextEditingController();

//   final List<TextEditingController> _otpControllers = List.generate(
//     4,
//     (_) => TextEditingController(),
//   );

//   final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

//   bool _showOtpScreen = false;
//   bool _isSendingOtp = false;

//   bool get _isMobileValid => _mobileController.text.length == 10;
//   bool get _isOtpComplete =>
//       _otpControllers.every((controller) => controller.text.isNotEmpty);

//   @override
//   void dispose() {
//     _mobileController.dispose();
//     for (final controller in _otpControllers) {
//       controller.dispose();
//     }
//     for (final focusNode in _otpFocusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }

//   // ============================================================
//   // SEND OTP
//   // ============================================================

//   Future<void> _sendOtp() async {
//     if (!_isMobileValid || _isSendingOtp) return;

//     FocusScope.of(context).unfocus();

//     setState(() {
//       _isSendingOtp = true;
//     });

//     try {
//       // TODO: Call your Send OTP API here
//       await Future.delayed(const Duration(seconds: 2));

//       if (!mounted) return;

//       setState(() {
//         _showOtpScreen = true;
//       });
//     } catch (e) {
//       debugPrint('Send OTP Error: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSendingOtp = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // VERIFY OTP
//   // ============================================================

//   void _verifyOtp() {
//     if (!_isOtpComplete) return;

//     final otp = _otpControllers.map((e) => e.text).join();

//     debugPrint('Mobile: ${_mobileController.text}');
//     debugPrint('OTP: $otp');

//     // TODO: Call verify OTP API here.
//     // For demo, we'll just login as USER
//     _loginUser(Keys.USER_TYPE);
//   }

//   // ============================================================
//   // LOGIN USER
//   // ============================================================

//   void _loginUser(String userType) {
//     debugPrint('🔐 Logging in user with type: $userType');

//     ref.read(authStateProvider.notifier).state = AuthState.authenticated(
//       userType,
//     );
//     context.go(AppRoutes.dashboard);
//   }

//   // ============================================================
//   // UI
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               // ==================================================
//               // BANNER WITH GRADIENT OVERLAY
//               // ==================================================
//               Stack(
//                 children: [
//                   SizedBox(
//                     width: double.infinity,
//                     height: MediaQuery.sizeOf(context).height * 0.40,
//                     child: Image.asset(
//                       'assets/png/logobanner.png',
//                       fit: BoxFit.cover,
//                       alignment: Alignment.topCenter,
//                     ),
//                   ),
//                   Container(
//                     width: double.infinity,
//                     height: MediaQuery.sizeOf(context).height * 0.40,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Colors.white.withValues(alpha: 0.1),
//                           Colors.white.withValues(alpha: 0.6),
//                           Colors.white,
//                         ],
//                         stops: const [0.0, 0.5, 0.8, 1.0],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               // ==================================================
//               // FORM SECTION
//               // ==================================================
//               Transform.translate(
//                 offset: const Offset(0, -25),
//                 child: Container(
//                   width: double.infinity,
//                   constraints: BoxConstraints(
//                     minHeight: MediaQuery.sizeOf(context).height * 0.60,
//                   ),
//                   padding: const EdgeInsets.fromLTRB(
//                     AppStyle.spaceXLarge,
//                     0,
//                     AppStyle.spaceXLarge,
//                     AppStyle.spaceXLarge,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.surface,
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(AppStyle.radiusXLarge),
//                     ),
//                   ),
//                   child: AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 400),
//                     switchInCurve: Curves.easeOutCubic,
//                     switchOutCurve: Curves.easeInCubic,
//                     child: _showOtpScreen
//                         ? _buildOtpSection()
//                         : _buildMobileSection(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // COMMON HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Column(
//       children: [
//         Text(
//           'Start party on your home',
//           textAlign: TextAlign.center,
//           style: AppStyle.heading3.copyWith(
//             color: Theme.of(context).textTheme.displayLarge?.color,
//           ),
//         ),
//         const SizedBox(height: AppStyle.spaceSmall),
//         Text(
//           'Log In or Sign Up',
//           style: AppStyle.bodyMedium.copyWith(
//             color: Theme.of(context).textTheme.bodyMedium?.color,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // MOBILE LOGIN
//   // ============================================================

//   Widget _buildMobileSection() {
//     return Column(
//       key: const ValueKey('mobile'),
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         _buildHeader(),
//         const SizedBox(height: AppStyle.spaceXXLarge),
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Text(
//             'Enter mobile number',
//             style: AppStyle.titleMedium.copyWith(
//               color: Theme.of(context).textTheme.titleMedium?.color,
//             ),
//           ),
//         ),
//         const SizedBox(height: AppStyle.spaceMedium),
//         Row(
//           children: [
//             Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppStyle.borderColor, width: 1.5),
//                 borderRadius: AppStyle.borderRadiusMedium,
//                 color: Theme.of(context).inputDecorationTheme.fillColor,
//               ),
//               alignment: Alignment.center,
//               child: Image.asset("assets/png/india.png", height: 60, width: 60),
//             ),
//             const SizedBox(width: AppStyle.spaceSmall),
//             Expanded(
//               child: TextField(
//                 controller: _mobileController,
//                 keyboardType: TextInputType.phone,
//                 textInputAction: TextInputAction.done,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(10),
//                 ],
//                 onChanged: (_) {
//                   setState(() {});
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Enter mobile number',
//                   prefixText: '+91  ',
//                   prefixStyle: AppStyle.titleMedium.copyWith(
//                     color: Theme.of(context).textTheme.titleMedium?.color,
//                   ),
//                   hintStyle: AppStyle.bodyMedium.copyWith(
//                     color: const Color(0xFFBBBBBB),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: AppStyle.spaceLarge,
//                     vertical: AppStyle.spaceLarge,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: AppStyle.borderRadiusMedium,
//                     borderSide: const BorderSide(
//                       color: AppStyle.borderColor,
//                       width: 1.5,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: AppStyle.borderRadiusMedium,
//                     borderSide: const BorderSide(
//                       color: Color(0xFF98001F),
//                       width: 2,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: AppStyle.spaceXXLarge),
//         SecondaryButton(
//           text: 'Login',
//           horizontalMargin: 0,
//           height: 56,
//           state: _isSendingOtp
//               ? ButtonState.loading
//               : _isMobileValid
//               ? ButtonState.enabled
//               : ButtonState.disabled,
//           onPressed: _sendOtp,
//         ),
//         const SizedBox(height: AppStyle.spaceMedium),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "you don't have account?",
//               style: AppStyle.bodyMedium.copyWith(
//                 color: Theme.of(context).textTheme.bodyMedium?.color,
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 context.push('/register');
//               },
//               child: Text(
//                 'Sign up',
//                 style: AppStyle.label.copyWith(
//                   color: const Color(0xFF1565C0), // Use a link color
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // OTP SECTION
//   // ============================================================

//   Widget _buildOtpSection() {
//     return Column(
//       key: const ValueKey('otp'),
//       children: [
//         _buildHeader(),
//         const SizedBox(height: AppStyle.spaceXXLarge),
//         Text(
//           'Enter OTP',
//           style: AppStyle.heading4.copyWith(
//             color: Theme.of(context).textTheme.titleLarge?.color,
//           ),
//         ),
//         const SizedBox(height: AppStyle.spaceSmall),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'OTP sent to ',
//               style: AppStyle.bodySmall.copyWith(color: AppStyle.textSecondary),
//             ),
//             Text(
//               '+91 ${_mobileController.text}',
//               style: AppStyle.titleSmall.copyWith(
//                 color: Theme.of(context).textTheme.titleSmall?.color,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: AppStyle.spaceXLarge),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(4, (index) => _buildOtpField(index)),
//         ),
//         const SizedBox(height: AppStyle.spaceXLarge),
//         SecondaryButton(
//           text: 'Verify OTP',
//           horizontalMargin: 0,
//           height: 56,
//           state: _isOtpComplete ? ButtonState.enabled : ButtonState.disabled,
//           onPressed: _verifyOtp,
//         ),
//         const SizedBox(height: AppStyle.spaceLarge),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _showOtpScreen = false;
//                   for (final controller in _otpControllers) {
//                     controller.clear();
//                   }
//                 });
//               },
//               style: TextButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppStyle.spaceLarge,
//                   vertical: AppStyle.spaceSmall,
//                 ),
//               ),
//               child: Text(
//                 'Change mobile number',
//                 style: AppStyle.label.copyWith(
//                   color: const Color(0xFF98001F),
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // OTP FIELD
//   // ============================================================

//   Widget _buildOtpField(int index) {
//     return Container(
//       width: 56,
//       height: 60,
//       margin: const EdgeInsets.symmetric(horizontal: AppStyle.spaceXS),
//       child: TextField(
//         controller: _otpControllers[index],
//         focusNode: _otpFocusNodes[index],
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         style: AppStyle.heading3.copyWith(
//           color: Theme.of(context).textTheme.displayLarge?.color,
//         ),
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//           LengthLimitingTextInputFormatter(1),
//         ],
//         onChanged: (value) {
//           if (value.isNotEmpty && index < 3) {
//             _otpFocusNodes[index + 1].requestFocus();
//           }
//           if (value.isEmpty && index > 0) {
//             _otpFocusNodes[index - 1].requestFocus();
//           }
//           setState(() {});
//         },
//         decoration: InputDecoration(
//           counterText: '',
//           contentPadding: EdgeInsets.zero,
//           enabledBorder: OutlineInputBorder(
//             borderRadius: AppStyle.borderRadiusMedium,
//             borderSide: const BorderSide(
//               color: AppStyle.borderColor,
//               width: 1.5,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: AppStyle.borderRadiusMedium,
//             borderSide: const BorderSide(color: Color(0xFF98001F), width: 2.5),
//           ),
//         ),
//       ),
//     );
//   }
// }

// modules/auth/screens/login_screen.dart

import 'dart:async';
import 'package:adm_seller/core/config/app_icons.dart';
import 'package:adm_seller/core/config/app_theme.dart';
import 'package:adm_seller/core/shared/styles/app_colors.dart';
import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/core/shared/widgets/buttons.dart';
import 'package:adm_seller/modules/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

enum _AuthStep { mobile, name, otp }

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ─── Controllers ───
  final _mobileController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // ─── Local Flow State ───
  _AuthStep _step = _AuthStep.mobile;
  String? _phone;
  String? _challengeToken;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  String? _errorText;

  // ─── Validation ───
  bool get _isMobileValid => _mobileController.text.trim().length == 10;
  bool get _isNameValid => _nameController.text.trim().length >= 2;
  bool get _isOtpComplete => _otpControllers.every((c) => c.text.isNotEmpty);

  @override
  void dispose() {
    _mobileController.dispose();
    _nameController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // ─── Cooldown Timer ───
  void _startCooldown(int seconds) {
    _cooldownSeconds = seconds;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) timer.cancel();
      });
    });
  }

  // ─── Clear Error ───
  void _clearError() {
    if (_errorText != null) setState(() => _errorText = null);
  }

  // ============================================================
  // API: CHECK PHONE
  // ============================================================

  // Future<void> _checkPhone() async {
  //   if (!_isMobileValid) return;
  //   _clearError();
  //   FocusScope.of(context).unfocus();

  //   final phone = '+91${_mobileController.text.trim()}';
  //   final notifier = ref.read(authNotifierProvider.notifier);

  //   await notifier.checkPhone(phone);

  //   if (!mounted) return;
  //   final state = ref.read(authNotifierProvider).asData?.value;

  //   if (state is AuthPhoneChecked) {
  //     _phone = phone;
  //     if (state.nextStep.isEnterName) {
  //       setState(() => _step = _AuthStep.name);
  //     } else if (state.nextStep.isOtpVerification) {
  //       await _sendOtp();
  //     }
  //   } else if (state is AuthUnauthenticated) {
  //     setState(() => _errorText = state.message ?? 'Something went wrong');
  //   }
  // }

  // // ============================================================
  // // API: SEND OTP
  // // ============================================================

  // Future<void> _sendOtp() async {
  //   if (_phone == null) return;
  //   _clearError();
  //   FocusScope.of(context).unfocus();

  //   final name = _step == _AuthStep.name ? _nameController.text.trim() : null;
  //   final notifier = ref.read(authNotifierProvider.notifier);

  //   await notifier.sendOtp(phone: _phone!, name: name);

  //   if (!mounted) return;
  //   final state = ref.read(authNotifierProvider).asData?.value;

  //   if (state is AuthOtpSent) {
  //     _challengeToken = state.challengeToken;
  //     _startCooldown(state.cooldownSeconds);
  //     setState(() => _step = _AuthStep.otp);
  //   } else if (state is AuthUnauthenticated) {
  //     setState(() => _errorText = state.message ?? 'Failed to send OTP');
  //   }
  // }

  // // ============================================================
  // // API: VERIFY OTP
  // // ============================================================

  // Future<void> _verifyOtp() async {
  //   if (!_isOtpComplete || _challengeToken == null || _phone == null) return;
  //   _clearError();
  //   FocusScope.of(context).unfocus();

  //   final otp = _otpControllers.map((c) => c.text).join();
  //   final name = _nameController.text.trim().isNotEmpty
  //       ? _nameController.text.trim()
  //       : null;

  //   final notifier = ref.read(authNotifierProvider.notifier);
  //   await notifier.verifyOtp(
  //     phone: _phone!,
  //     code: otp,
  //     name: name,
  //     challengeToken: _challengeToken!,
  //   );
  //   // Router auto-redirects on AuthAuthenticated based on verificationStatus
  // }

  Future<void> _checkPhone() async {
    if (!_isMobileValid) return;
    _clearError();
    FocusScope.of(context).unfocus();

    final phone = '+91${_mobileController.text.trim()}';
    final notifier = ref.read(authNotifierProvider.notifier);

    // Store the phone number before async operation
    final String phoneNumber = phone;

    await notifier.checkPhone(phoneNumber);

    // CRITICAL: Check mounted after async operation
    if (!mounted) {
      print('Widget unmounted, cannot update state');
      return;
    }

    final authState = ref.read(authNotifierProvider).asData?.value;
    print('AuthState after check: ${authState.runtimeType}'); // Add this debug

    if (authState is AuthPhoneChecked) {
      print("New user - showing name input");
      _phone = phoneNumber;
      setState(() => _step = _AuthStep.name);
    } else if (authState is AuthOtpSent) {
      print("Existing user - showing OTP input");
      _phone = phoneNumber;
      _challengeToken = authState.challengeToken;
      _startCooldown(authState.cooldownSeconds);
      setState(() => _step = _AuthStep.otp);
    } else if (authState is AuthUnauthenticated) {
      setState(() => _errorText = authState.message ?? 'Something went wrong');
    } else {
      // Handle any other state
      print('Unexpected auth state: ${authState.runtimeType}');
      setState(() => _errorText = 'Unexpected error occurred');
    }
  }

  Future<void> _sendOtp() async {
    // Only called for NEW users after name entry
    if (_phone == null) return;
    _clearError();
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final notifier = ref.read(authNotifierProvider.notifier);

    await notifier.sendOtp(phone: _phone!, name: name);

    if (!mounted) return;
    final authState = ref.read(authNotifierProvider).asData?.value;

    if (authState is AuthOtpSent) {
      _challengeToken = authState.challengeToken;
      _startCooldown(authState.cooldownSeconds);
      setState(() => _step = _AuthStep.otp);
    } else if (authState is AuthUnauthenticated) {
      setState(() => _errorText = authState.message ?? 'Failed to send OTP');
    }
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete || _challengeToken == null || _phone == null) return;
    _clearError();
    FocusScope.of(context).unfocus();

    final otp = _otpControllers.map((c) => c.text).join();
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : null;

    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.verifyOtp(
      phone: _phone!,
      code: otp,
      name: name,
      challengeToken: _challengeToken!,
    );
    // Router redirect handles navigation after AuthAuthenticated
  }
  // ============================================================
  // GO BACK
  // ============================================================

  void _goBack() {
    _clearError();
    if (_step == _AuthStep.otp) {
      setState(() {
        _step = _AuthStep.mobile;
        _challengeToken = null;
        for (final c in _otpControllers) c.clear();
      });
    } else if (_step == _AuthStep.name) {
      setState(() => _step = _AuthStep.mobile);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authNotifierProvider);
    final isLoading = authAsync.isLoading;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? ColorName.primaryBackgroundDark : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildBanner(),
                  Transform.translate(
                    offset: const Offset(0, -25),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height * 0.60,
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        AppStyle.spaceXLarge,
                        0,
                        AppStyle.spaceXLarge,
                        AppStyle.spaceXLarge,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppStyle.radiusXLarge),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _buildCurrentSection(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: (isDark ? ColorName.primaryBackgroundDark : Colors.white)
                    .withValues(alpha: 0.7),
                child: Center(
                  child: Lottie.asset(
                    AppIcons.loading,
                    height: 200,
                    width: 200,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BANNER
  // ============================================================

  Widget _buildBanner() {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.38,
          child: Image.asset(
            'assets/png/logobanner.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                surfaceColor.withValues(alpha: 0.1),
                surfaceColor.withValues(alpha: 0.6),
                surfaceColor,
              ],
              stops: const [0.0, 0.5, 0.8, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION SWITCHER
  // ============================================================

  Widget _buildCurrentSection() {
    return switch (_step) {
      _AuthStep.name => _buildNameSection(),
      _AuthStep.otp => _buildOtpSection(),
      _AuthStep.mobile => _buildMobileSection(),
    };
  }

  // ============================================================
  // COMMON HEADER
  // ============================================================

  Widget _buildHeader({required String title, String? subtitle}) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppStyle.heading3.copyWith(
            color: Theme.of(context).textTheme.displayLarge?.color,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppStyle.spaceSmall),
          Text(
            subtitle,
            style: AppStyle.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorText() {
    if (_errorText == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppStyle.spaceMedium),
      child: Text(
        _errorText!,
        textAlign: TextAlign.center,
        style: AppStyle.bodySmall.copyWith(color: Colors.red.shade700),
      ),
    );
  }

  // ============================================================
  // MOBILE SECTION
  // ============================================================

  Widget _buildMobileSection() {
    return Column(
      key: const ValueKey('mobile'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHeader(
          title: 'Start party on your home',
          subtitle: 'Log In or Sign Up',
        ),
        const SizedBox(height: AppStyle.spaceXXLarge),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Enter mobile number',
            style: AppStyle.titleMedium.copyWith(
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
        ),
        const SizedBox(height: AppStyle.spaceMedium),
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.customColors.border,
                  width: 1.5,
                ),
                borderRadius: AppStyle.borderRadiusMedium,
                color: Theme.of(context).inputDecorationTheme.fillColor,
              ),
              alignment: Alignment.center,
              child: Image.asset("assets/png/india.png", height: 60, width: 60),
            ),
            const SizedBox(width: AppStyle.spaceSmall),
            Expanded(
              child: TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (_) {
                  _clearError();
                  setState(() {});
                },
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter mobile number',
                  prefixText: '+91  ',
                  prefixStyle: AppStyle.titleMedium.copyWith(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  hintStyle: AppStyle.bodyMedium.copyWith(
                    color: ColorName.lightGreyBorder,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppStyle.spaceLarge,
                    vertical: AppStyle.spaceLarge,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppStyle.borderRadiusMedium,
                    borderSide: BorderSide(
                      color: context.customColors.border,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppStyle.borderRadiusMedium,
                    borderSide: BorderSide(
                      color: context.isDarkMode
                          ? ColorName.secondary
                          : ColorName.primaryBrandRed,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyle.spaceXXLarge),
        SecondaryButton(
          text: 'Continue',
          horizontalMargin: 0,
          height: 56,
          state: _isMobileValid ? ButtonState.enabled : ButtonState.disabled,
          onPressed: _checkPhone,
        ),
        _buildErrorText(),
      ],
    );
  }

  // ============================================================
  // NAME SECTION (New User)
  // ============================================================

  Widget _buildNameSection() {
    return Column(
      key: const ValueKey('name'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHeader(
          title: 'Welcome!',
          subtitle: 'Tell us your name to get started',
        ),
        const SizedBox(height: AppStyle.spaceXXLarge),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Full Name',
            style: AppStyle.titleMedium.copyWith(
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
        ),
        const SizedBox(height: AppStyle.spaceMedium),
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            _clearError();
            setState(() {});
          },
          style: TextStyle(
            color: context.isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            hintStyle: AppStyle.bodyMedium.copyWith(
              color: ColorName.lightGreyBorder,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppStyle.spaceLarge,
              vertical: AppStyle.spaceLarge,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppStyle.borderRadiusMedium,
              borderSide: BorderSide(
                color: context.customColors.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppStyle.borderRadiusMedium,
              borderSide: BorderSide(
                color: context.isDarkMode
                    ? ColorName.secondary
                    : ColorName.primaryBrandRed,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppStyle.spaceXXLarge),
        SecondaryButton(
          text: 'Continue',
          horizontalMargin: 0,
          height: 56,
          state: _isNameValid ? ButtonState.enabled : ButtonState.disabled,
          onPressed: _sendOtp,
        ),
        _buildErrorText(),
        const SizedBox(height: AppStyle.spaceLarge),
        TextButton(
          onPressed: _goBack,
          child: Text(
            'Change mobile number',
            style: AppStyle.label.copyWith(
              color: ColorName.primaryBrandRed,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OTP SECTION
  // ============================================================

  Widget _buildOtpSection() {
    return Column(
      key: const ValueKey('otp'),
      children: [
        _buildHeader(
          title: 'Verify OTP',
          subtitle: 'Enter the 6-digit code sent to your phone',
        ),
        const SizedBox(height: AppStyle.spaceLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sent to ',
              style: AppStyle.bodySmall.copyWith(color: AppStyle.textSecondary),
            ),
            Text(
              _phone ?? '',
              style: AppStyle.titleSmall.copyWith(
                color: Theme.of(context).textTheme.titleSmall?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyle.spaceXLarge),

        // ─── OTP FIELDS ───
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6, // horizontal gap
          children: List.generate(6, (index) => _buildOtpField(index)),
        ),

        const SizedBox(height: AppStyle.spaceXLarge),
        SecondaryButton(
          text: 'Verify OTP',
          horizontalMargin: 0,
          height: 56,
          state: _isOtpComplete ? ButtonState.enabled : ButtonState.disabled,
          onPressed: _verifyOtp,
        ),
        _buildErrorText(),
        const SizedBox(height: AppStyle.spaceLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _goBack,
              child: Text(
                'Change mobile number',
                style: AppStyle.label.copyWith(
                  color: ColorName.primaryBrandRed,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyle.spaceSmall),
        _buildResendButton(),
      ],
    );
  }

  // ─── FIXED OTP FIELD ───
  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: AppStyle.heading4.copyWith(
          color: Theme.of(context).textTheme.displayLarge?.color,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: (value) {
          _clearError();
          if (value.isNotEmpty && index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: AppStyle.borderRadiusMedium,
            borderSide: BorderSide(
              color: context.customColors.border,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppStyle.borderRadiusMedium,
            borderSide: BorderSide(
              color: context.isDarkMode
                  ? ColorName.secondary
                  : ColorName.primaryBrandRed,
              width: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    if (_cooldownSeconds > 0) {
      return Text(
        'Resend OTP in ${_cooldownSeconds}s',
        style: AppStyle.bodySmall.copyWith(color: AppStyle.textSecondary),
      );
    }
    return TextButton(
      onPressed: _sendOtp,
      child: Text(
        'Resend OTP',
        style: AppStyle.label.copyWith(
          color: ColorName.primaryBrandRed,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
