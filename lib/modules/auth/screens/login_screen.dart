import 'package:adm_seller/core/config/app_router.dart';
import 'package:adm_seller/core/shared/const/keys.dart';
import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/core/shared/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();

  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  bool _showOtpScreen = false;
  bool _isSendingOtp = false;

  bool get _isMobileValid => _mobileController.text.length == 10;
  bool get _isOtpComplete =>
      _otpControllers.every((controller) => controller.text.isNotEmpty);

  @override
  void dispose() {
    _mobileController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // ============================================================
  // SEND OTP
  // ============================================================

  Future<void> _sendOtp() async {
    if (!_isMobileValid || _isSendingOtp) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSendingOtp = true;
    });

    try {
      // TODO: Call your Send OTP API here
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _showOtpScreen = true;
      });
    } catch (e) {
      debugPrint('Send OTP Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
        });
      }
    }
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  void _verifyOtp() {
    if (!_isOtpComplete) return;

    final otp = _otpControllers.map((e) => e.text).join();

    debugPrint('Mobile: ${_mobileController.text}');
    debugPrint('OTP: $otp');

    // TODO: Call verify OTP API here.
    // For demo, we'll just login as USER
    _loginUser(Keys.USER_TYPE);
  }

  // ============================================================
  // LOGIN USER
  // ============================================================

  void _loginUser(String userType) {
    debugPrint('🔐 Logging in user with type: $userType');

    ref.read(authStateProvider.notifier).state = AuthState.authenticated(
      userType,
    );
    context.go(AppRoutes.dashboard);
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ==================================================
              // BANNER WITH GRADIENT OVERLAY
              // ==================================================
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * 0.40,
                    child: Image.asset(
                      'assets/png/logobanner.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * 0.40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.6),
                          Colors.white,
                        ],
                        stops: const [0.0, 0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),

              // ==================================================
              // FORM SECTION
              // ==================================================
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
                    child: _showOtpScreen
                        ? _buildOtpSection()
                        : _buildMobileSection(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMMON HEADER
  // ============================================================

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Start party on your home',
          textAlign: TextAlign.center,
          style: AppStyle.heading3.copyWith(
            color: Theme.of(context).textTheme.displayLarge?.color,
          ),
        ),
        const SizedBox(height: AppStyle.spaceSmall),
        Text(
          'Log In or Sign Up',
          style: AppStyle.bodyMedium.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE LOGIN
  // ============================================================

  Widget _buildMobileSection() {
    return Column(
      key: const ValueKey('mobile'),
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHeader(),
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
                border: Border.all(color: AppStyle.borderColor, width: 1.5),
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
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Enter mobile number',
                  prefixText: '+91  ',
                  prefixStyle: AppStyle.titleMedium.copyWith(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  hintStyle: AppStyle.bodyMedium.copyWith(
                    color: const Color(0xFFBBBBBB),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppStyle.spaceLarge,
                    vertical: AppStyle.spaceLarge,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppStyle.borderRadiusMedium,
                    borderSide: const BorderSide(
                      color: AppStyle.borderColor,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppStyle.borderRadiusMedium,
                    borderSide: const BorderSide(
                      color: Color(0xFF98001F),
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
          text: 'Login',
          horizontalMargin: 0,
          height: 56,
          state: _isSendingOtp
              ? ButtonState.loading
              : _isMobileValid
              ? ButtonState.enabled
              : ButtonState.disabled,
          onPressed: _sendOtp,
        ),
        const SizedBox(height: AppStyle.spaceMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "you don't have account?",
              style: AppStyle.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/register');
              },
              child: Text(
                'Sign up',
                style: AppStyle.label.copyWith(
                  color: const Color(0xFF1565C0), // Use a link color
                ),
              ),
            ),
          ],
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
        _buildHeader(),
        const SizedBox(height: AppStyle.spaceXXLarge),
        Text(
          'Enter OTP',
          style: AppStyle.heading4.copyWith(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: AppStyle.spaceSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'OTP sent to ',
              style: AppStyle.bodySmall.copyWith(color: AppStyle.textSecondary),
            ),
            Text(
              '+91 ${_mobileController.text}',
              style: AppStyle.titleSmall.copyWith(
                color: Theme.of(context).textTheme.titleSmall?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyle.spaceXLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) => _buildOtpField(index)),
        ),
        const SizedBox(height: AppStyle.spaceXLarge),
        SecondaryButton(
          text: 'Verify OTP',
          horizontalMargin: 0,
          height: 56,
          state: _isOtpComplete ? ButtonState.enabled : ButtonState.disabled,
          onPressed: _verifyOtp,
        ),
        const SizedBox(height: AppStyle.spaceLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _showOtpScreen = false;
                  for (final controller in _otpControllers) {
                    controller.clear();
                  }
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyle.spaceLarge,
                  vertical: AppStyle.spaceSmall,
                ),
              ),
              child: Text(
                'Change mobile number',
                style: AppStyle.label.copyWith(
                  color: const Color(0xFF98001F),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // OTP FIELD
  // ============================================================

  Widget _buildOtpField(int index) {
    return Container(
      width: 56,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: AppStyle.spaceXS),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: AppStyle.heading3.copyWith(
          color: Theme.of(context).textTheme.displayLarge?.color,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
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
            borderSide: const BorderSide(
              color: AppStyle.borderColor,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppStyle.borderRadiusMedium,
            borderSide: const BorderSide(color: Color(0xFF98001F), width: 2.5),
          ),
        ),
      ),
    );
  }
}
