// modules/auth/screens/profile_setup_screen.dart

// import 'package:adm_seller/api/api_service.dart';
import 'package:adm_seller/core/api/api_service.dart';
import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/core/shared/widgets/buttons.dart';
import 'package:adm_seller/modules/auth/models/verification_status_enum.dart';
// import 'package:adm_seller/features/auth/providers/auth_provider.dart';
import 'package:adm_seller/modules/auth/providers/auth_provider.dart';
import 'package:adm_seller/modules/auth/screens/auth_status_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  // ─── Controllers ───
  final _storeName = TextEditingController();
  final _storeDescription = TextEditingController();
  final _licenseNumber = TextEditingController();
  final _licenseHolderName = TextEditingController();
  final _licenseType = TextEditingController();
  final _licenseIssueDate = TextEditingController();
  final _licenseExpiryDate = TextEditingController();
  final _gstin = TextEditingController();
  final _panNumber = TextEditingController();
  final _addressLine1 = TextEditingController();
  final _addressLine2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _bankAccountNumber = TextEditingController();
  final _ifscCode = TextEditingController();
  final _upiId = TextEditingController();

  bool _isLoading = false;
  String? _errorText;

  // ─── Validation ───
  bool get _isFormValid {
    return _storeName.text.trim().length >= 2 &&
        // _licenseNumber.text.trim().isNotEmpty &&
        // _licenseHolderName.text.trim().isNotEmpty &&
        // _licenseType.text.trim().isNotEmpty &&
        // _licenseExpiryDate.text.trim().isNotEmpty &&
        // _gstin.text.trim().length == 15 &&
        // _panNumber.text.trim().length == 10 &&
        // _addressLine1.text.trim().isNotEmpty &&
        // _city.text.trim().isNotEmpty &&
        // _state.text.trim().isNotEmpty &&
        // _pincode.text.trim().length == 6 &&
        // double.tryParse(_latitude.text.trim()) != null &&
        double.tryParse(_longitude.text.trim()) != null;
  }

  @override
  void dispose() {
    _storeName.dispose();
    _storeDescription.dispose();
    _licenseNumber.dispose();
    _licenseHolderName.dispose();
    _licenseType.dispose();
    _licenseIssueDate.dispose();
    _licenseExpiryDate.dispose();
    _gstin.dispose();
    _panNumber.dispose();
    _addressLine1.dispose();
    _addressLine2.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _bankAccountNumber.dispose();
    _ifscCode.dispose();
    _upiId.dispose();
    super.dispose();
  }

  // ─── Date Picker ───
  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF98001F)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  // ─── Submit ───

  Future<void> _submitProfile() async {
    if (!_isFormValid) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final data = {
        'storeName': _storeName.text.trim(),
        if (_storeDescription.text.trim().isNotEmpty)
          'storeDescription': _storeDescription.text.trim(),
        'licenseNumber': _licenseNumber.text.trim(),
        'licenseHolderName': _licenseHolderName.text.trim(),
        'licenseType': _licenseType.text.trim(),
        if (_licenseIssueDate.text.trim().isNotEmpty)
          'licenseIssueDate': _licenseIssueDate.text.trim(),
        'licenseExpiryDate': _licenseExpiryDate.text.trim(),
        'gstin': _gstin.text.trim(),
        'panNumber': _panNumber.text.trim(),
        'addressLine1': _addressLine1.text.trim(),
        if (_addressLine2.text.trim().isNotEmpty)
          'addressLine2': _addressLine2.text.trim(),
        'city': _city.text.trim(),
        'state': _state.text.trim(),
        'pincode': _pincode.text.trim(),
        'latitude': double.parse(_latitude.text.trim()),
        'longitude': double.parse(_longitude.text.trim()),
        if (_bankAccountNumber.text.trim().isNotEmpty)
          'bankAccountNumber': _bankAccountNumber.text.trim(),
        if (_ifscCode.text.trim().isNotEmpty) 'ifscCode': _ifscCode.text.trim(),
        if (_upiId.text.trim().isNotEmpty) 'upiId': _upiId.text.trim(),
      };

      // modules/auth/screens/profile_setup_screen.dart — replace the broken block

      final response = await ref.read(apiServiceProvider).updateProfile(data);
      final profile = response.response;

      // Map seller status to verification status for router navigation
      final VerificationStatus newStatus;
      if (profile.status.isActive) {
        newStatus = VerificationStatus.verified;
      } else if (profile.status.isManualReviewRequired) {
        newStatus = VerificationStatus.underReview;
      } else {
        newStatus = VerificationStatus.pendingVerification;
      }

      // Update auth state via notifier method
      await ref
          .read(authNotifierProvider.notifier)
          .updateUserVerificationStatus(newStatus);

      // Update auth state directly to trigger router redirect
      // final currentAuth = ref.read(authNotifierProvider).asData?.value;
      // if (currentAuth is AuthAuthenticated) {
      //   state = AsyncValue.data(
      //     AuthAuthenticated(
      //       accessToken: currentAuth.accessToken,
      //       user: currentAuth.user.copyWith(verificationStatus: newStatus),
      //     ),
      //   );
      // }
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Helpers ───
  void _clearError() {
    if (_errorText != null) setState(() => _errorText = null);
  }

  @override
  Widget build(BuildContext context) {
    return AuthStatusScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════
          // HEADER
          // ═══════════════════════════════════════════════════════
          Center(
            child: Column(
              children: [
                Text(
                  'Setup Your Store',
                  textAlign: TextAlign.center,
                  style: AppStyle.heading3.copyWith(color: Colors.black87),
                ),
                const SizedBox(height: AppStyle.spaceSmall),
                Text(
                  'Complete your profile to start selling',
                  textAlign: TextAlign.center,
                  style: AppStyle.bodyMedium.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyle.spaceXXLarge),

          // ═══════════════════════════════════════════════════════
          // STORE INFO
          // ═══════════════════════════════════════════════════════
          _sectionTitle('Store Information'),
          const SizedBox(height: AppStyle.spaceMedium),
          _buildField(
            controller: _storeName,
            label: 'Store Name *',
            hint: 'Royal Liquor Palace',
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          _buildField(
            controller: _storeDescription,
            label: 'Store Description',
            hint: 'Premium wines and spirits shop',
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceXLarge),

          // ═══════════════════════════════════════════════════════
          // LICENSE DETAILS
          // ═══════════════════════════════════════════════════════
          _sectionTitle('License Details'),
          const SizedBox(height: AppStyle.spaceMedium),
          _buildField(
            controller: _licenseNumber,
            label: 'License Number *',
            hint: 'EXCISE/KA/2026/99812',
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          _buildField(
            controller: _licenseHolderName,
            label: 'License Holder Name *',
            hint: 'Royal Liquors Pvt Ltd',
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          _buildField(
            controller: _licenseType,
            label: 'License Type *',
            hint: 'FL-1',
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  controller: _licenseIssueDate,
                  label: 'Issue Date',
                  hint: '2024-01-01',
                ),
              ),
              const SizedBox(width: AppStyle.spaceMedium),
              Expanded(
                child: _buildDateField(
                  controller: _licenseExpiryDate,
                  label: 'Expiry Date *',
                  hint: '2027-12-31',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.spaceXLarge),

          // ═══════════════════════════════════════════════════════
          // TAX DETAILS
          // ═══════════════════════════════════════════════════════
          _sectionTitle('Tax Details'),
          const SizedBox(height: AppStyle.spaceMedium),
          _buildField(
            controller: _gstin,
            label: 'GSTIN *',
            hint: '29ABCDE1234F1Z5',
            maxLength: 15,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          _buildField(
            controller: _panNumber,
            label: 'PAN Number *',
            hint: 'ABCDE1234F',
            maxLength: 10,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceXLarge),

          // ═══════════════════════════════════════════════════════
          // ADDRESS
          // ═══════════════════════════════════════════════════════
          _sectionTitle('Address'),
          const SizedBox(height: AppStyle.spaceMedium),
          _buildField(
            controller: _addressLine1,
            label: 'Address Line 1 *',
            hint: 'Shop No. 12, Main MG Road',
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          _buildField(
            controller: _addressLine2,
            label: 'Address Line 2',
            hint: 'Near Trinity Metro Station',
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  controller: _city,
                  label: 'City *',
                  hint: 'Bengaluru',
                  onChanged: (_) => _clearError(),
                ),
              ),
              const SizedBox(width: AppStyle.spaceMedium),
              Expanded(
                child: _buildField(
                  controller: _state,
                  label: 'State *',
                  hint: 'Karnataka',
                  onChanged: (_) => _clearError(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          _buildField(
            controller: _pincode,
            label: 'Pincode *',
            hint: '560001',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  controller: _latitude,
                  label: 'Latitude *',
                  hint: '12.9715987',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => _clearError(),
                ),
              ),
              const SizedBox(width: AppStyle.spaceMedium),
              Expanded(
                child: _buildField(
                  controller: _longitude,
                  label: 'Longitude *',
                  hint: '77.5945627',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => _clearError(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.spaceXLarge),

          // ═══════════════════════════════════════════════════════
          // BANK DETAILS (Optional)
          // ═══════════════════════════════════════════════════════
          _sectionTitle('Bank Details (Optional)'),
          const SizedBox(height: AppStyle.spaceMedium),
          _buildField(
            controller: _bankAccountNumber,
            label: 'Account Number',
            hint: '987654321012',
            keyboardType: TextInputType.number,
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          _buildField(
            controller: _ifscCode,
            label: 'IFSC Code',
            hint: 'SBIN0001234',
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceLarge),
          _buildField(
            controller: _upiId,
            label: 'UPI ID',
            hint: 'royalliquor@upi',
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: AppStyle.spaceXXLarge),

          // ═══════════════════════════════════════════════════════
          // ERROR
          // ═══════════════════════════════════════════════════════
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppStyle.spaceMedium),
              child: Text(
                _errorText!,
                textAlign: TextAlign.center,
                style: AppStyle.bodySmall.copyWith(color: Colors.red.shade700),
              ),
            ),

          // ═══════════════════════════════════════════════════════
          // SUBMIT
          // ═══════════════════════════════════════════════════════
          SecondaryButton(
            text: 'Save & Continue',
            horizontalMargin: 0,
            height: 56,
            state: _isLoading
                ? ButtonState.loading
                : _isFormValid
                ? ButtonState.enabled
                : ButtonState.disabled,
            onPressed: _submitProfile,
          ),
          const SizedBox(height: AppStyle.spaceXLarge),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGET HELPERS
  // ============================================================

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: AppStyle.titleLarge.copyWith(
        color: const Color(0xFF98001F),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyle.titleMedium.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: AppStyle.spaceSmall),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          onChanged: onChanged,
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyle.titleMedium.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: AppStyle.spaceSmall),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _pickDate(controller),
          decoration: _inputDecoration(hint: hint).copyWith(
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF98001F),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppStyle.bodyMedium.copyWith(color: const Color(0xFFBBBBBB)),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppStyle.spaceLarge,
        vertical: AppStyle.spaceLarge,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppStyle.borderRadiusMedium,
        borderSide: const BorderSide(color: AppStyle.borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppStyle.borderRadiusMedium,
        borderSide: const BorderSide(color: Color(0xFF98001F), width: 2),
      ),
      counterText: '',
    );
  }
}
