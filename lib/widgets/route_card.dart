import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../models/jeep_route.dart';
import '../theme/app_theme.dart';

class RouteCard extends StatelessWidget {
  const RouteCard({
    super.key,
    required this.route,
    required this.onTap,
  });

  final JeepRoute route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: GlassCard(
        // `minimal` fires no custom shader, which keeps a long list smooth.
        quality: GlassQuality.minimal,
        settings: AppGlass.card,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    route.routeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),
                ),
                const SizedBox(width: 10),
                _Pill(
                  label: route.vehicleTypeLabel,
                  color: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              route.corridor,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                _FareTag(
                  label: 'REGULAR',
                  value: route.regularFareLabel,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 10),
                _FareTag(
                  label: 'DISCOUNTED',
                  value: route.discountedFareLabel,
                  color: AppColors.success,
                ),
                const Spacer(),
                if (!route.isActive)
                  const _Pill(
                    label: 'Inactive',
                    color: AppColors.warning,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _FareTag extends StatelessWidget {
  const _FareTag({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTextStyles.fareValue.copyWith(color: color),
        ),
      ],
    );
  }
}
