import 'package:adm_seller/core/api/api_service.dart';
import 'package:adm_seller/core/config/app_theme.dart';
import 'package:adm_seller/core/shared/styles/app_colors.dart';
import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/core/shared/widgets/buttons.dart';

// import 'package:adm_seller/features/auth/providers/auth_provider.dart';
import 'package:adm_seller/modules/auth/providers/auth_provider.dart';
import 'package:adm_seller/modules/auth/screens/auth_status_scaffold.dart';
import 'package:adm_seller/modules/auth/screens/location_picker_screen.dart';
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

  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  bool _isLoading = false;
  String? _errorText;

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

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<LocationPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLatitude: double.tryParse(_latitude.text),
          initialLongitude: double.tryParse(_longitude.text),
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      // Coordinates
      _latitude.text = result.latitude.toString();
      _longitude.text = result.longitude.toString();

      // Address
      _addressLine1.text = result.addressLine1;

      // City
      _city.text = result.city;

      // State
      _state.text = result.state;

      // Pincode
      _pincode.text = result.pincode;
    });

    debugPrint('========== LOCATION PICKED ==========');
    debugPrint('Latitude: ${result.latitude}');
    debugPrint('Longitude: ${result.longitude}');
    debugPrint('Address: ${result.addressLine1}');
    debugPrint('City: ${result.city}');
    debugPrint('State: ${result.state}');
    debugPrint('Pincode: ${result.pincode}');
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
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final hasCoordinates =
        double.tryParse(_latitude.text.trim()) != null &&
        double.tryParse(_longitude.text.trim()) != null;

    if (!isFormValid || !hasCoordinates) {
      setState(() {
        if (!hasCoordinates) {
          _errorText = 'Please pick a store location on the map';
        } else {
          _errorText = 'Please correct the errors in the form';
        }
      });
      return;
    }

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
      final newStatus = profile.status;

      await ref
          .read(authNotifierProvider.notifier)
          .updateUserVerificationStatus(newStatus);
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      setState(() {
        _errorText = errorMessage;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Helpers ───
  void _clearError() {
    setState(() {
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AuthStatusScaffold(
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
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
                    style: AppStyle.heading3.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: AppStyle.spaceSmall),
                  Text(
                    'Complete your profile to start selling',
                    textAlign: TextAlign.center,
                    style: AppStyle.bodyMedium.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^[a-zA-Z\s\.]+$'), // Letters, spaces, and dots
                ),
              ],
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Store name is required';
                }
                if (val.trim().length < 2) {
                  return 'Store name must be at least 2 characters';
                }
                return null;
              },
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
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'License number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppStyle.spaceLarge),
            _buildField(
              controller: _licenseHolderName,
              keyboardType: TextInputType.name,
              label: 'License Holder Name *',
              hint: 'Royal Liquors Pvt Ltd',
              onChanged: (_) => _clearError(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^[a-zA-Z\s\.]+$'), // Letters, spaces, and dots
                ),
              ],
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'License holder name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppStyle.spaceLarge),
            _buildField(
              controller: _licenseType,
              label: 'License Type *',
              hint: 'FL-1',
              onChanged: (_) => _clearError(),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'License type is required';
                }
                return null;
              },
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
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Expiry date is required';
                      }
                      return null;
                    },
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
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'GSTIN is required';
                }
                if (val.trim().length != 15) {
                  return 'GSTIN must be exactly 15 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppStyle.spaceLarge),
            _buildField(
              controller: _panNumber,
              label: 'PAN Number *',
              hint: 'ABCDE1234F',
              maxLength: 10,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => _clearError(),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'PAN number is required';
                }
                if (val.trim().length != 10) {
                  return 'PAN number must be exactly 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppStyle.spaceXLarge),

            // ═══════════════════════════════════════════════════════
            // ADDRESS
            // ═══════════════════════════════════════════════════════
            _sectionTitle('Address'),
            const SizedBox(height: AppStyle.spaceMedium),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _openLocationPicker,
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Pick Location on Map'),
              ),
            ),
            const SizedBox(height: AppStyle.spaceLarge),
            _buildField(
              controller: _addressLine1,
              label: 'Address Line 1 *',
              hint: 'Shop No. 12, Main MG Road',
              onChanged: (_) => _clearError(),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Address Line 1 is required';
                }
                return null;
              },
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
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'City is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppStyle.spaceMedium),
                Expanded(
                  child: _buildField(
                    controller: _state,
                    label: 'State *',
                    hint: 'Karnataka',
                    onChanged: (_) => _clearError(),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'State is required';
                      }
                      return null;
                    },
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
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Pincode is required';
                }
                if (val.trim().length != 6) {
                  return 'Pincode must be exactly 6 digits';
                }
                return null;
              },
            ),
            // const SizedBox(height: AppStyle.spaceLarge),

            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildField(
            //         controller: _latitude,
            //         label: 'Latitude *',
            //         hint: '12.9715987',
            //         keyboardType: const TextInputType.numberWithOptions(
            //           decimal: true,
            //         ),
            //         onChanged: (_) => _clearError(),
            //       ),
            //     ),
            //     const SizedBox(width: AppStyle.spaceMedium),
            //     Expanded(
            //       child: _buildField(
            //         controller: _longitude,
            //         label: 'Longitude *',
            //         hint: '77.5945627',
            //         keyboardType: const TextInputType.numberWithOptions(
            //           decimal: true,
            //         ),
            //         onChanged: (_) => _clearError(),
            //       ),
            //     ),
            //   ],
            // ),
            //           Row(
            //   children: [
            //     Expanded(
            //       child: BuildTextField(
            //         label: 'Latitude',
            //         controller: _latitude,
            //         keyboardType:
            //             const TextInputType.numberWithOptions(
            //           decimal: true,
            //           signed: true,
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: BuildTextField(
            //         label: 'Longitude',
            //         controller: _longitude,
            //         keyboardType:
            //             const TextInputType.numberWithOptions(
            //           decimal: true,
            //           signed: true,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
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
                  style: AppStyle.bodySmall.copyWith(
                    color: isDark ? Colors.redAccent : Colors.red.shade700,
                  ),
                ),
              ),

            // ═══════════════════════════════════════════════════════
            // SUBMIT
            // ═══════════════════════════════════════════════════════
            SecondaryButton(
              text: 'Save & Continue',
              horizontalMargin: 0,
              height: 56,
              state: _isLoading ? ButtonState.loading : ButtonState.enabled,
              onPressed: _submitProfile,
            ),
            const SizedBox(height: AppStyle.spaceXLarge),
          ],
        ),
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
        color: ColorName.primaryBrandRed,
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
    String? Function(String?)? validator,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          onChanged: onChanged,
          validator: validator,
          style: TextStyle(
            color: context.isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: _inputDecoration(context, hint: hint),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
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
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _pickDate(controller),
          validator: validator,
          style: TextStyle(
            color: context.isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: _inputDecoration(context, hint: hint).copyWith(
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: ColorName.primaryBrandRed,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
  }) {
    final isDark = context.isDarkMode;
    return InputDecoration(
      hintText: hint,
      hintStyle: AppStyle.bodyMedium.copyWith(color: ColorName.lightGreyBorder),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppStyle.spaceLarge,
        vertical: AppStyle.spaceLarge,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppStyle.borderRadiusMedium,
        borderSide: BorderSide(color: context.customColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppStyle.borderRadiusMedium,
        borderSide: BorderSide(
          color: isDark ? ColorName.secondary : ColorName.primaryBrandRed,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppStyle.borderRadiusMedium,
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppStyle.borderRadiusMedium,
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      errorStyle: TextStyle(
        color: isDark ? Colors.redAccent : Colors.red.shade700,
        fontSize: 12,
      ),
      counterText: '',
    );
  }
}
