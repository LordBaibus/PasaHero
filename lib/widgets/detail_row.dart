import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';

/// One icon-plus-caption-plus-value row inside the route detail card.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    this.icon,
    this.prefix,
    required this.label,
    required this.value,
    this.isLast = false,
  }) : assert(
  icon != null || prefix != null,
  'DetailRow needs either an icon or a prefix widget.',
  );

  /// Simple icon shown at the left of the row.
  final IconData? icon;

  /// Custom widget shown at the left of the row.
  ///
  /// Takes priority over [icon]. Used for the peso sign on the fare row, since
  /// neither icon font has a peso glyph.
  final Widget? prefix;

  /// Small uppercase caption, e.g. "ORIGIN".
  final String label;

  /// The value itself. Pass a placeholder like "Not specified" rather than an
  /// empty string so the row never collapses.
  final String value;

  /// Drops the bottom spacing on the final row.
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    // A fixed box keeps every row's text aligned, whether the leading widget
    // is an icon or a text character.
    final Widget leading = SizedBox(
      width: 18,
      child: Center(
        child: prefix ??
            Icon(icon, size: 17, color: AppColors.textMuted),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: leading,
          ),
          const SizedBox(width: 14),
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

/// Peso character used in place of an icon.
///
/// Neither CupertinoIcons nor Material's icon font has a peso glyph, so this
/// draws the character itself.
class PesoSign extends StatelessWidget {
  const PesoSign({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '\u20B1',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
      ),
    );
  }
}
