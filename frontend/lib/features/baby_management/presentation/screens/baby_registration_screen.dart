import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../../authentication/presentation/widgets/moon_cloud_illustration.dart';

/// Baby Registration screen (SRS Section 10.3, 10.4).
///
/// Reuses the same pastel "calm, safe, caring" design system already
/// established by the Login and Register screens — the shared widgets in
/// `features/authentication/presentation/widgets/` are generic enough to
/// be reused here directly rather than duplicated, keeping every hero
/// screen visually identical without touching Login or Register.
///
/// Submission currently stores the entered details only in local widget
/// state and simulates the save round-trip; it will call into the Baby
/// Management data/domain layer once that integration lands, without
/// requiring any change to this screen's UI.
class BabyRegistrationScreen extends StatefulWidget {
  const BabyRegistrationScreen({super.key});

  @override
  State<BabyRegistrationScreen> createState() => _BabyRegistrationScreenState();
}

class _BabyRegistrationScreenState extends State<BabyRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _babyNameController = TextEditingController();
  final _twinNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _pediatricianController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _allergyController = TextEditingController();

  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  File? _babyPhoto;
  DateTime? _dateOfBirth;
  _Gender? _gender;
  String? _bloodGroup;
  bool _isTwin = false;
  bool _showDobError = false;
  bool _showGenderError = false;
  bool _isSubmitting = false;
  bool _isSkipping = false;
  String? _errorMessage;

  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Not sure yet'];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceFade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _babyNameController.dispose();
    _twinNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _pediatricianController.dispose();
    _hospitalController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  String? _validateBabyName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return "Enter your baby's name";
    if (name.length < 2) return 'Name is too short';
    final namePattern = RegExp(r"^[A-Za-z\s'\-]+$");
    if (!namePattern.hasMatch(name)) return 'Enter a valid name';
    return null;
  }

  String? _validateTwinName(String? value) {
    if (!_isTwin) return null;
    final name = value?.trim() ?? '';
    if (name.isEmpty) return "Enter your twin's name";
    if (name.length < 2) return 'Name is too short';
    return null;
  }

  String? _validateWeight(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return "Enter baby's weight";
    final weight = double.tryParse(text);
    if (weight == null) return 'Enter a valid number';
    if (weight <= 0 || weight > 50) return 'Enter a realistic weight';
    return null;
  }

  String? _validateHeight(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return "Enter baby's height";
    final height = double.tryParse(text);
    if (height == null) return 'Enter a valid number';
    if (height <= 0 || height > 150) return 'Enter a realistic height';
    return null;
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AuthPalette.softCoral,
              onPrimary: Colors.white,
              surface: AuthPalette.warmCream,
              onSurface: AuthPalette.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AuthPalette.softCoral),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      _dateOfBirth = picked;
      _showDobError = false;
    });
  }

  Future<void> _handlePhotoTap() async {
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PhotoOptionsSheet(hasPhoto: _babyPhoto != null),
    );
    if (action == null || !mounted) return;

    switch (action) {
      case _PhotoAction.camera:
        await _pickImage(ImageSource.camera);
      case _PhotoAction.gallery:
        await _pickImage(ImageSource.gallery);
      case _PhotoAction.remove:
        setState(() => _babyPhoto = null);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked == null || !mounted) return;
      setState(() => _babyPhoto = File(picked.path));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = "Couldn't access the camera or photo library.");
    }
  }

  Future<void> _handleSaveAndContinue() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    final missing = <String>[];
    if (_dateOfBirth == null) missing.add('date of birth');
    if (_gender == null) missing.add('gender');

    setState(() {
      _showDobError = _dateOfBirth == null;
      _showGenderError = _gender == null;
    });

    if (!isFormValid || missing.isNotEmpty) {
      setState(() {
        _errorMessage = missing.isNotEmpty
            ? "Please provide your baby's ${missing.join(' and ')}."
            : 'Please fix the highlighted fields.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Stores the entered details locally and simulates the save
      // round-trip pending the Baby Management data/domain layer
      // integration — mock/local state only, no backend or Firebase.
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      context.go(RoutePaths.dashboard);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleSkip() async {
    setState(() => _isSkipping = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.go(RoutePaths.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateOfBirth == null
        ? null
        : DateFormat('dd MMM yyyy').format(_dateOfBirth!);

    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: AuthFloatingDecor()),
          SafeArea(
            child: Column(
              children: [
                AuthBackButton(onPressed: context.canPop() ? () => context.pop() : null),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          children: [
                            Transform.scale(
                              scale: 0.72,
                              child: const MoonCloudIllustration(),
                            ),
                            Text(
                              'Tell us about your little one',
                              style: GoogleFonts.quicksand(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AuthPalette.textDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Every detail helps us care for your baby a little\nbetter — take your time, you can always update this later.",
                              style: GoogleFonts.nunito(
                                fontSize: 14.5,
                                height: 1.4,
                                color: AuthPalette.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 22),
                            FadeTransition(
                              opacity: _entranceFade,
                              child: SlideTransition(
                                position: _entranceSlide,
                                child: AuthCard(
                                  child: Form(
                                    key: _formKey,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        if (_errorMessage != null) ...[
                                          AuthErrorBanner(message: _errorMessage!),
                                          const SizedBox(height: 16),
                                        ],
                                        Center(
                                          child: _BabyPhotoPicker(
                                            photo: _babyPhoto,
                                            onTap: _handlePhotoTap,
                                          ),
                                        ),
                                        const SizedBox(height: 22),
                                        AuthTextField(
                                          controller: _babyNameController,
                                          label: "Baby's Name",
                                          hintText: 'e.g. Aanya',
                                          textCapitalization: TextCapitalization.words,
                                          prefixIcon: Icons.child_care_outlined,
                                          validator: _validateBabyName,
                                          enabled: !_isSubmitting,
                                        ),
                                        const SizedBox(height: 14),
                                        _PastelPickerField(
                                          label: 'Date of Birth',
                                          value: dateLabel,
                                          hint: 'Select a date',
                                          icon: Icons.cake_outlined,
                                          enabled: !_isSubmitting,
                                          hasError: _showDobError,
                                          onTap: _pickDateOfBirth,
                                        ),
                                        if (_showDobError)
                                          const _InlineError(text: 'Date of birth is required'),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Gender',
                                          style: GoogleFonts.nunito(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AuthPalette.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _GenderSelector(
                                          value: _gender,
                                          enabled: !_isSubmitting,
                                          onChanged: (value) {
                                            setState(() {
                                              _gender = value;
                                              _showGenderError = false;
                                            });
                                          },
                                        ),
                                        if (_showGenderError)
                                          const _InlineError(text: "Please select your baby's gender"),
                                        const SizedBox(height: 14),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: AuthTextField(
                                                controller: _weightController,
                                                label: 'Weight (kg)',
                                                hintText: 'e.g. 3.2',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                                prefixIcon: Icons.monitor_weight_outlined,
                                                validator: _validateWeight,
                                                enabled: !_isSubmitting,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: AuthTextField(
                                                controller: _heightController,
                                                label: 'Height (cm)',
                                                hintText: 'e.g. 50',
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                                prefixIcon: Icons.straighten_outlined,
                                                validator: _validateHeight,
                                                enabled: !_isSubmitting,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        DropdownButtonFormField<String>(
                                          initialValue: _bloodGroup,
                                          isExpanded: true,
                                          style: GoogleFonts.nunito(
                                            fontSize: 15,
                                            color: AuthPalette.textDark,
                                          ),
                                          dropdownColor: AuthPalette.warmCream,
                                          borderRadius: BorderRadius.circular(18),
                                          icon: const Icon(Icons.expand_more_rounded,
                                              color: AuthPalette.textMuted),
                                          decoration: authPastelDecoration(
                                            label: 'Blood Group',
                                            hint: 'Select if known',
                                            prefixIcon: Icons.bloodtype_outlined,
                                          ),
                                          items: _bloodGroups
                                              .map(
                                                (group) => DropdownMenuItem(
                                                  value: group,
                                                  child: Text(group),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: _isSubmitting
                                              ? null
                                              : (value) => setState(() => _bloodGroup = value),
                                        ),
                                        const SizedBox(height: 14),
                                        AuthTextField(
                                          controller: _pediatricianController,
                                          label: 'Pediatrician Name (optional)',
                                          hintText: 'e.g. Dr. Meera Nair',
                                          textCapitalization: TextCapitalization.words,
                                          prefixIcon: Icons.medical_services_outlined,
                                          validator: (_) => null,
                                          enabled: !_isSubmitting,
                                        ),
                                        const SizedBox(height: 14),
                                        AuthTextField(
                                          controller: _hospitalController,
                                          label: 'Hospital Name (optional)',
                                          hintText: 'e.g. Sunrise Children\'s Hospital',
                                          textCapitalization: TextCapitalization.words,
                                          prefixIcon: Icons.local_hospital_outlined,
                                          validator: (_) => null,
                                          enabled: !_isSubmitting,
                                        ),
                                        const SizedBox(height: 14),
                                        TextFormField(
                                          controller: _allergyController,
                                          enabled: !_isSubmitting,
                                          maxLines: 3,
                                          style: GoogleFonts.nunito(
                                            fontSize: 15,
                                            color: AuthPalette.textDark,
                                          ),
                                          cursorColor: AuthPalette.softCoral,
                                          decoration: authPastelDecoration(
                                            label: 'Allergy Notes (optional)',
                                            hint: 'Anything you\'d like caregivers to know',
                                            prefixIcon: Icons.health_and_safety_outlined,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _TwinToggleRow(
                                          value: _isTwin,
                                          enabled: !_isSubmitting,
                                          onChanged: (value) => setState(() => _isTwin = value),
                                        ),
                                        AnimatedSize(
                                          duration: const Duration(milliseconds: 280),
                                          curve: Curves.easeInOut,
                                          child: !_isTwin
                                              ? const SizedBox(width: double.infinity)
                                              : Padding(
                                                  padding: const EdgeInsets.only(top: 12),
                                                  child: AuthTextField(
                                                    controller: _twinNameController,
                                                    label: "Twin's Name",
                                                    hintText: 'e.g. Ishaan',
                                                    textCapitalization:
                                                        TextCapitalization.words,
                                                    prefixIcon: Icons.diversity_3_outlined,
                                                    validator: _validateTwinName,
                                                    enabled: !_isSubmitting,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: 22),
                                        AuthPrimaryButton(
                                          label: 'Save & Continue',
                                          isLoading: _isSubmitting,
                                          onPressed:
                                              _isSubmitting ? null : _handleSaveAndContinue,
                                        ),
                                        const SizedBox(height: 12),
                                        AuthOutlineButton(
                                          label: 'Skip for now',
                                          icon: Icons.arrow_forward_rounded,
                                          accent: AuthPalette.lavenderMist,
                                          isLoading: _isSkipping,
                                          onPressed:
                                              (_isSubmitting || _isSkipping) ? null : _handleSkip,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _Gender { girl, boy, unspecified }

enum _PhotoAction { camera, gallery, remove }

/// Circular baby-photo picker with a coral camera badge, matching the
/// pastel design language.
class _BabyPhotoPicker extends StatelessWidget {
  const _BabyPhotoPicker({required this.photo, required this.onTap});

  final File? photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: photo == null ? "Add your baby's photo" : "Change your baby's photo",
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AuthPalette.blushPink.withValues(alpha: 0.35),
                border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.8), width: 2),
                image: photo != null
                    ? DecorationImage(image: FileImage(photo!), fit: BoxFit.cover)
                    : null,
              ),
              child: photo == null
                  ? const Icon(Icons.child_friendly_rounded, size: 44, color: AuthPalette.softCoral)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 4,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AuthPalette.softCoral,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: const Icon(Icons.photo_camera_rounded, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with photo source options, styled to match the pastel card.
class _PhotoOptionsSheet extends StatelessWidget {
  const _PhotoOptionsSheet({required this.hasPhoto});

  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AuthPalette.warmCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AuthPalette.lavenderMist,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Add a Photo',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AuthPalette.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _PhotoOptionTile(
              icon: Icons.photo_camera_outlined,
              label: 'Take Photo',
              onTap: () => Navigator.of(context).pop(_PhotoAction.camera),
            ),
            _PhotoOptionTile(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () => Navigator.of(context).pop(_PhotoAction.gallery),
            ),
            if (hasPhoto)
              _PhotoOptionTile(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Photo',
                destructive: true,
                onTap: () => Navigator.of(context).pop(_PhotoAction.remove),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoOptionTile extends StatelessWidget {
  const _PhotoOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AuthPalette.error : AuthPalette.textDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tappable, pastel-styled field that opens a picker (used for Date of
/// Birth) rather than accepting keyboard input directly.
class _PastelPickerField extends StatelessWidget {
  const _PastelPickerField({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.enabled,
    required this.hasError,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String hint;
  final IconData icon;
  final bool enabled;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? AuthPalette.error
        : AuthPalette.lavenderMist.withValues(alpha: 0.7);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: enabled ? onTap : null,
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.nunito(color: AuthPalette.textMuted, fontSize: 14),
          hintStyle: GoogleFonts.nunito(color: AuthPalette.textMuted.withValues(alpha: 0.6), fontSize: 14),
          prefixIcon: Icon(icon, color: AuthPalette.textMuted),
          suffixIcon: const Icon(Icons.calendar_today_outlined, color: AuthPalette.textMuted, size: 18),
          filled: true,
          fillColor: AuthPalette.blushPink.withValues(alpha: 0.28),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
        ),
        child: Text(
          value ?? '',
          style: GoogleFonts.nunito(fontSize: 15, color: AuthPalette.textDark),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        text,
        style: GoogleFonts.nunito(fontSize: 11.5, color: AuthPalette.error, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Pastel chip selector for Girl / Boy / Prefer not to say.
class _GenderSelector extends StatelessWidget {
  const _GenderSelector({required this.value, required this.enabled, required this.onChanged});

  final _Gender? value;
  final bool enabled;
  final ValueChanged<_Gender> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderChip(
            label: 'Girl',
            icon: Icons.female_rounded,
            accent: AuthPalette.softCoral,
            selected: value == _Gender.girl,
            enabled: enabled,
            onTap: () => onChanged(_Gender.girl),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GenderChip(
            label: 'Boy',
            icon: Icons.male_rounded,
            accent: AuthPalette.powderBlue,
            selected: value == _Gender.boy,
            enabled: enabled,
            onTap: () => onChanged(_Gender.boy),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GenderChip(
            label: 'Prefer not\nto say',
            icon: Icons.help_outline_rounded,
            accent: AuthPalette.lavenderMist,
            selected: value == _Gender.unspecified,
            enabled: enabled,
            onTap: () => onChanged(_Gender.unspecified),
          ),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label.replaceAll('\n', ' '),
      child: AnimatedScale(
        scale: selected ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: enabled ? onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              decoration: BoxDecoration(
                color: selected ? accent.withValues(alpha: 0.22) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? accent : AuthPalette.lavenderMist.withValues(alpha: 0.5),
                  width: selected ? 2 : 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: selected ? accent : AuthPalette.textMuted, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? AuthPalette.textDark : AuthPalette.textMuted,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Twin-mode switch row.
class _TwinToggleRow extends StatelessWidget {
  const _TwinToggleRow({required this.value, required this.enabled, required this.onChanged});

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AuthPalette.mint.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AuthPalette.mint.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.diversity_3_outlined, color: AuthPalette.textDark, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Expecting or raising twins?',
              style: GoogleFonts.nunito(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AuthPalette.textDark,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: Colors.white,
            activeTrackColor: AuthPalette.softCoral,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AuthPalette.textMuted.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}
