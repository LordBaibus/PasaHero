import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';

/// One icon-plus-caption-plus-value row inside the route detail card.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;

  /// Small uppercase caption, e.g. "ORIGIN".
  final String label;

  /// The value itself. Pass a placeholder like "Not specified" rather than an
  /// empty string so the row never collapses.
  final String value;

  /// Drops the bottom spacing on the final row.
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 17, color: AppColors.textMuted),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label.toUpperCase(), style: AppTextStyles.label),
                const SizedBox(height: 5),
                Text(value, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
