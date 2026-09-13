import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/api_config.dart';
import '../models/jeep_route.dart';
import '../theme/app_theme.dart';

/// Maps a vehicle type to a recognisable glyph.
///
/// Uses Material's icon font because CupertinoIcons has no tricycle or
/// shuttle-van glyph. This is IconData only — no Material widget is used.
class VehicleIcons {
  const VehicleIcons._();

  /// Icon for the "All" filter.
  static const IconData all = Icons.apps_rounded;

  static IconData forType(String type) {
    switch (type) {
      case VehicleTypes.tricycle:
        return Icons.electric_rickshaw_rounded;
      case VehicleTypes.bus:
        return Icons.directions_bus_rounded;
      case VehicleTypes.uvExpress:
        return Icons.airport_shuttle_rounded;
      case VehicleTypes.jeepney:
      default:
        return Icons.directions_bus_filled_rounded;
    }
  }
}

/// Horizontal row of vehicle-type filters.
///
/// Passing `null` to [onSelected] means "All".
class VehicleFilterBar extends StatelessWidget {
  const VehicleFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: <Widget>[
          _FilterPill(
            icon: VehicleIcons.all,
            label: 'All',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final String type in VehicleTypes.all) ...<Widget>[
            const SizedBox(width: 10),
            _FilterPill(
              icon: VehicleIcons.forType(type),
              label: JeepRoute.vehicleLabel(type),
              isSelected: selected == type,
              onTap: () => onSelected(type),
            ),
          ],
        ],
      ),
    );
  }
}

/// One filter option.
///
/// GlassButton.custom is required here — the default GlassButton constructor
/// only draws an icon, and its `label` argument is a semantic label that is
/// never painted on screen.
class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
    isSelected ? AppColors.accent : AppColors.textSecondary;

    // GlassButton.custom does not size itself to its child, so the width is
    // estimated from the label length. The values below fit all five labels.
    final double width = 54 + label.length * 8.0;

    return GlassButton.custom(
      onTap: onTap,
      width: width,
      height: 44,
      shape: const LiquidRoundedRectangle(borderRadius: 22),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
