import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/api_config.dart';
import '../models/jeep_route.dart';
import '../theme/app_theme.dart';

/// Lets the user pick which kind of vehicle serves this route.
///
/// The values come from [VehicleTypes.all], which matches the `vehicle_type`
/// ENUM column exactly, so an invalid value can never be sent.
class VehicleTypeSelector extends StatelessWidget {
  const VehicleTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final String selected;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 11),
            child: Text('VEHICLE TYPE', style: AppTextStyles.label),
          ),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: <Widget>[
              for (final String type in VehicleTypes.all)
                GlassButton(
                  icon: Icon(
                    selected == type
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.circle,
                    size: 15,
                  ),
                  label: JeepRoute.vehicleLabel(type),
                  onTap: () {
                    if (enabled) {
                      onChanged(type);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Marks a route as currently operating or temporarily suspended.
class ActiveStatusSelector extends StatelessWidget {
  const ActiveStatusSelector({
    super.key,
    required this.isActive,
    required this.onChanged,
    this.enabled = true,
  });

  final bool isActive;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 11),
            child: Text('STATUS', style: AppTextStyles.label),
          ),
          Row(
            children: <Widget>[
              GlassButton(
                icon: Icon(
                  isActive
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.circle,
                  size: 15,
                ),
                label: 'Active',
                onTap: () {
                  if (enabled) {
                    onChanged(true);
                  }
                },
              ),
              const SizedBox(width: 9),
              GlassButton(
                icon: Icon(
                  isActive
                      ? CupertinoIcons.circle
                      : CupertinoIcons.checkmark_circle_fill,
                  size: 15,
                ),
                label: 'Inactive',
                onTap: () {
                  if (enabled) {
                    onChanged(false);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
