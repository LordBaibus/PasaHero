import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/api_config.dart';
import '../models/jeep_route.dart';
import '../theme/app_theme.dart';
import 'vehicle_filter_bar.dart' show VehicleIcons;

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
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Two tiles per row, 12px apart.
              final double tileWidth = (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  for (final String type in VehicleTypes.all)
                    SelectableTile(
                      icon: VehicleIcons.forType(type),
                      label: JeepRoute.vehicleLabel(type),
                      width: tileWidth,
                      isSelected: selected == type,
                      activeColor: AppColors.accent,
                      onTap: () {
                        if (enabled) {
                          onChanged(type);
                        }
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

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
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double tileWidth = (constraints.maxWidth - 12) / 2;

              return Row(
                children: <Widget>[
                  SelectableTile(
                    icon: CupertinoIcons.checkmark_seal_fill,
                    label: 'Active',
                    width: tileWidth,
                    isSelected: isActive,
                    activeColor: AppColors.success,
                    onTap: () {
                      if (enabled) {
                        onChanged(true);
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  SelectableTile(
                    icon: CupertinoIcons.pause_circle_fill,
                    label: 'Inactive',
                    width: tileWidth,
                    isSelected: !isActive,
                    activeColor: AppColors.warning,
                    onTap: () {
                      if (enabled) {
                        onChanged(false);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class SelectableTile extends StatelessWidget {
  const SelectableTile({
    super.key,
    required this.icon,
    required this.label,
    required this.width,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;

  final double width;

  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? activeColor : AppColors.textMuted;

    return GlassButton.custom(
      onTap: onTap,
      width: width,
      height: 54,
      shape: const LiquidRoundedRectangle(borderRadius: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            if (isSelected) ...<Widget>[
              const SizedBox(width: 7),
              Icon(
                CupertinoIcons.checkmark_alt,
                size: 14,
                color: activeColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
