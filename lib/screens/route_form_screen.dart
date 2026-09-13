import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/api_result.dart';
import '../core/route_validator.dart';
import '../models/jeep_route.dart';
import '../services/route_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/form_field_group.dart';
import '../widgets/vehicle_type_selector.dart';

/// Discounted fares are a fixed 80% of the regular fare.
///
/// Change this single value if the student and senior discount ever changes.
const double kDiscountRate = 0.80;

/// Handles both the CREATE and the UPDATE operation.
///
/// Pass [existing] to edit a route; leave it null to add a new one. Pops with
/// `true` when something was saved so the home screen knows to reload.
class RouteFormScreen extends StatefulWidget {
  const RouteFormScreen({super.key, this.existing});

  final JeepRoute? existing;

  @override
  State<RouteFormScreen> createState() => _RouteFormScreenState();
}

class _RouteFormScreenState extends State<RouteFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _originController;
  late final TextEditingController _destinationController;
  late final TextEditingController _regularFareController;
  late final TextEditingController _discountedFareController;
  late final TextEditingController _hoursController;
  late final TextEditingController _notesController;

  late String _vehicleType;
  late bool _isActive;

  /// True while a request is in flight. Blocks a second submission.
  bool _isSaving = false;

  /// Guard so the two fare fields do not keep rewriting each other.
  bool _syncingFares = false;

  /// Last validation or API problem, shown under the form.
  String? _errorMessage;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();

    final JeepRoute source = widget.existing ?? JeepRoute.blank;
    final bool isNew = widget.existing == null;

    _nameController = TextEditingController(text: source.routeName);
    _originController = TextEditingController(text: source.origin);
    _destinationController = TextEditingController(text: source.destination);
    _hoursController = TextEditingController(text: source.operatingHours);
    _notesController = TextEditingController(text: source.notes);

    // Leave the fare boxes empty for a new route instead of showing 0.00.
    _regularFareController = TextEditingController(
      text: isNew ? '' : source.regularFare.toStringAsFixed(2),
    );
    _discountedFareController = TextEditingController(
      text: isNew ? '' : source.discountedFare.toStringAsFixed(2),
    );

    _vehicleType = source.vehicleType;
    _isActive = source.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _regularFareController.dispose();
    _discountedFareController.dispose();
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Clears the inline error as soon as the user starts fixing things.
  void _clearError(String _) {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  /// Regular fare was typed, so recalculate the discounted fare.
  void _onRegularFareChanged(String value) {
    _clearError(value);

    if (_syncingFares) {
      return;
    }

    _syncingFares = true;

    final double? regular = RouteValidator.parseFare(value);

    if (regular == null) {
      // Emptying the regular fare empties the discounted one too, so the form
      // never shows a leftover amount that no longer means anything.
      if (value.trim().isEmpty) {
        _discountedFareController.text = '';
      }
    } else {
      _discountedFareController.text =
          (regular * kDiscountRate).toStringAsFixed(2);
    }

    _syncingFares = false;
  }

  /// Discounted fare was typed, so work backwards to the regular fare.
  void _onDiscountedFareChanged(String value) {
    _clearError(value);

    if (_syncingFares) {
      return;
    }

    _syncingFares = true;

    final double? discounted = RouteValidator.parseFare(value);

    if (discounted == null) {
      if (value.trim().isEmpty) {
        _regularFareController.text = '';
      }
    } else {
      _regularFareController.text =
          (discounted / kDiscountRate).toStringAsFixed(2);
    }

    _syncingFares = false;
  }

  /// Collects the current field values into a route object.
  JeepRoute _buildPayload() {
    return JeepRoute(
      id: widget.existing?.id ?? 0,
      routeName: _nameController.text.trim(),
      origin: _originController.text.trim(),
      destination: _destinationController.text.trim(),
      vehicleType: _vehicleType,
      regularFare:
      RouteValidator.parseFare(_regularFareController.text) ?? 0,
      discountedFare:
      RouteValidator.parseFare(_discountedFareController.text) ?? 0,
      operatingHours: _hoursController.text.trim(),
      notes: _notesController.text.trim(),
      isActive: _isActive,
    );
  }

  /// Validates, then performs CREATE or UPDATE depending on the mode.
  Future<void> _handleSave() async {
    if (_isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();

    // 1. Local checks first, so a typo never leaves the phone.
    final String? validationError = RouteValidator.validate(
      routeName: _nameController.text,
      origin: _originController.text,
      destination: _destinationController.text,
      regularFareText: _regularFareController.text,
      discountedFareText: _discountedFareController.text,
    );

    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });

    // 2. Send it.
    try {
      final JeepRoute payload = _buildPayload();

      final JeepRoute saved = _isEditing
          ? await RouteService.instance.updateRoute(payload)
          : await RouteService.instance.createRoute(payload);

      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);

      await AppDialogs.showSuccess(
        context,
        title: _isEditing ? 'Route Updated' : 'Route Created',
        message: '"${saved.routeName}" has been saved successfully.',
      );

      if (!mounted) {
        return;
      }

      // `true` tells the home screen to reload the list.
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage = e.message;
      });

      await AppDialogs.showError(
        context,
        title: _isEditing ? 'Update Failed' : 'Create Failed',
        message: e.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: const AppBackground(),
      statusBarStyle: GlassStatusBarStyle.light,
      appBar: GlassAppBar(
        title: Text(
          _isEditing ? 'Edit Route' : 'New Route',
          style: AppTextStyles.title,
        ),
        actions: <Widget>[
          GlassIconButton(
            icon: const Icon(CupertinoIcons.xmark),
            onPressed: () {
              if (!_isSaving) {
                Navigator.of(context).pop(false);
              }
            },
          ),
        ],
      ),
      // SafeArea handles the status bar and the gesture bar. The 74px of top
      // padding clears the app bar, which GlassScaffold floats OVER the body.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 74, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FormFieldGroup(
                label: 'Route Name',
                controller: _nameController,
                placeholder: 'Angeles - Dau Terminal',
                icon: CupertinoIcons.map,
                enabled: !_isSaving,
                onChanged: _clearError,
              ),
              FormFieldGroup(
                label: 'Origin',
                controller: _originController,
                placeholder: 'Nepo Mart, Angeles City',
                icon: CupertinoIcons.location,
                enabled: !_isSaving,
                onChanged: _clearError,
              ),
              FormFieldGroup(
                label: 'Destination',
                controller: _destinationController,
                placeholder: 'Dau Bus Terminal',
                icon: CupertinoIcons.location_solid,
                enabled: !_isSaving,
                onChanged: _clearError,
              ),

              VehicleTypeSelector(
                selected: _vehicleType,
                enabled: !_isSaving,
                onChanged: (String type) =>
                    setState(() => _vehicleType = type),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: FormFieldGroup(
                      label: 'Regular Fare',
                      controller: _regularFareController,
                      placeholder: '15.00',
                      prefix: const _PesoSign(),
                      enabled: !_isSaving,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: _onRegularFareChanged,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FormFieldGroup(
                      label: 'Discounted Fare',
                      controller: _discountedFareController,
                      placeholder: '12.00',
                      prefix: const _PesoSign(),
                      enabled: !_isSaving,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: _onDiscountedFareChanged,
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.only(left: 6, bottom: 20),
                child: Text(
                  'The discounted fare is 80% of the regular fare. Editing '
                      'either one updates the other.',
                  style: AppTextStyles.caption,
                ),
              ),

              FormFieldGroup(
                label: 'Operating Hours',
                controller: _hoursController,
                placeholder: '4:30 AM - 10:00 PM',
                icon: CupertinoIcons.clock,
                enabled: !_isSaving,
                onChanged: _clearError,
              ),
              FormFieldGroup(
                label: 'Notes',
                controller: _notesController,
                placeholder: 'Optional remarks about this route',
                icon: CupertinoIcons.doc_text,
                maxLines: 3,
                enabled: !_isSaving,
                onChanged: _clearError,
              ),

              ActiveStatusSelector(
                isActive: _isActive,
                enabled: !_isSaving,
                onChanged: (bool value) => setState(() => _isActive = value),
              ),

              if (_errorMessage != null) ...<Widget>[
                _FormError(message: _errorMessage!),
                const SizedBox(height: 18),
              ],

              const SizedBox(height: 4),
              Center(
                child: _SaveButton(
                  isSaving: _isSaving,
                  isEditing: _isEditing,
                  onTap: _handleSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Peso character used in place of an icon on the fare fields.
///
/// Neither CupertinoIcons nor Material's icon font has a peso glyph, so this
/// draws the character itself.
class _PesoSign extends StatelessWidget {
  const _PesoSign();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 2),
      child: Text(
        '\u20B1',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

/// Save button with a visible label.
class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.isSaving,
    required this.isEditing,
    required this.onTap,
  });

  final bool isSaving;
  final bool isEditing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String label = isSaving
        ? 'Saving'
        : (isEditing ? 'Save Changes' : 'Create Route');

    return GlassButton.custom(
      onTap: onTap,
      width: 200,
      height: 54,
      shape: const LiquidRoundedRectangle(borderRadius: 27),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            isSaving
                ? CupertinoIcons.arrow_2_circlepath
                : CupertinoIcons.checkmark_alt,
            size: 18,
            color: AppColors.accent,
          ),
          const SizedBox(width: 9),
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline banner showing why the form could not be saved.
class _FormError extends StatelessWidget {
  const _FormError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      quality: GlassQuality.minimal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              size: 16,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}
