import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/api_result.dart';
import '../models/jeep_route.dart';
import '../services/route_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/form_field_group.dart';
import '../widgets/vehicle_type_selector.dart';

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

  /// Collects the current field values into a route object.
  JeepRoute _buildPayload() {
    return JeepRoute(
      id: widget.existing?.id ?? 0,
      routeName: _nameController.text.trim(),
      origin: _originController.text.trim(),
      destination: _destinationController.text.trim(),
      vehicleType: _vehicleType,
      regularFare: double.tryParse(_regularFareController.text.trim()) ?? 0,
      discountedFare:
      double.tryParse(_discountedFareController.text.trim()) ?? 0,
      operatingHours: _hoursController.text.trim(),
      notes: _notesController.text.trim(),
      isActive: _isActive,
    );
  }

  /// CREATE or UPDATE, depending on the mode.
  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    final JeepRoute payload = _buildPayload();

    try {
      if (_isEditing) {
        await RouteService.instance.updateRoute(payload);
      } else {
        await RouteService.instance.createRoute(payload);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

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
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FormFieldGroup(
                label: 'Route Name',
                controller: _nameController,
                placeholder: 'Angeles - Dau Terminal',
                icon: CupertinoIcons.map,
              ),
              FormFieldGroup(
                label: 'Origin',
                controller: _originController,
                placeholder: 'Nepo Mart, Angeles City',
                icon: CupertinoIcons.location,
              ),
              FormFieldGroup(
                label: 'Destination',
                controller: _destinationController,
                placeholder: 'Dau Bus Terminal',
                icon: CupertinoIcons.location_solid,
              ),

              VehicleTypeSelector(
                selected: _vehicleType,
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
                      icon: CupertinoIcons.money_dollar,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FormFieldGroup(
                      label: 'Discounted Fare',
                      controller: _discountedFareController,
                      placeholder: '12.00',
                      icon: CupertinoIcons.tag,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),

              FormFieldGroup(
                label: 'Operating Hours',
                controller: _hoursController,
                placeholder: '4:30 AM - 10:00 PM',
                icon: CupertinoIcons.clock,
              ),
              FormFieldGroup(
                label: 'Notes',
                controller: _notesController,
                placeholder: 'Optional remarks about this route',
                icon: CupertinoIcons.doc_text,
                maxLines: 3,
              ),

              ActiveStatusSelector(
                isActive: _isActive,
                onChanged: (bool value) => setState(() => _isActive = value),
              ),

              const SizedBox(height: 8),
              Center(
                child: GlassButton(
                  icon: const Icon(CupertinoIcons.checkmark_alt),
                  label: _isEditing ? 'Save Changes' : 'Create Route',
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