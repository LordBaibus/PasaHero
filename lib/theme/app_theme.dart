import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Colour tokens for the whole application.
class AppColors {
  const AppColors._();

  static const Color backdropTop = Color(0xFF0A1020);
  static const Color backdropBottom = Color(0xFF151C2E);

  static const Color blobBlue = Color(0xFF3D7BFF);
  static const Color blobTeal = Color(0xFF12C2A0);
  static const Color blobViolet = Color(0xFF8B5CF6);

  static const Color accent = Color(0xFF5C9BFF);
  static const Color success = Color(0xFF2ED8A7);
  static const Color warning = Color(0xFFFFB13D);
  static const Color danger = Color(0xFFFF6B73);

  static const Color textPrimary = Color(0xFFF3F6FC);
  static const Color textSecondary = Color(0xFFBAC4D8);
  static const Color textMuted = Color(0xFF838FA8);
}

/// Reusable [LiquidGlassSettings] presets.
///
/// Kept as `static final` rather than `static const` so the file keeps
/// compiling if the package changes the constructor in a future release.
class AppGlass {
  const AppGlass._();

  /// Standard surface used for list cards and panels.
  static final LiquidGlassSettings card = LiquidGlassSettings(
    thickness: 26,
    blur: 8,
  );

  /// Slightly thicker, crisper glass for text inputs.
  static final LiquidGlassSettings input = LiquidGlassSettings(
    thickness: 32,
    blur: 10,
    specularSharpness: GlassSpecularSharpness.sharp,
  );

  /// Heaviest glass, for hero panels that do not scroll.
  static final LiquidGlassSettings hero = LiquidGlassSettings(
    thickness: 42,
    blur: 14,
  );
}

/// Text styles used across every screen.
class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle display = TextStyle(
    fontSize: 33,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16.5,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13.5,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static const TextStyle placeholder = TextStyle(
    fontSize: 15,
    color: AppColors.textMuted,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.5,
    height: 1.4,
    color: AppColors.textMuted,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.3,
    color: AppColors.textMuted,
  );

  static const TextStyle fareValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}

/// Slow-moving aurora backdrop.
///
/// Passed to `GlassScaffold(background: const AppBackground())` on every
/// screen. The drifting blobs are what the glass surfaces refract, which is
/// what makes them read as liquid rather than as flat translucent boxes.
class AppBackground extends StatefulWidget {
  const AppBackground({super.key});

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[AppColors.backdropTop, AppColors.backdropBottom],
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              final double t = _controller.value * 2 * math.pi;

              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _blob(
                    constraints,
                    AppColors.blobBlue,
                    0.18 + 0.10 * math.sin(t),
                    0.10 + 0.06 * math.cos(t),
                    320,
                  ),
                  _blob(
                    constraints,
                    AppColors.blobTeal,
                    0.78 + 0.08 * math.cos(t * 0.8),
                    0.34 + 0.08 * math.sin(t * 1.1),
                    280,
                  ),
                  _blob(
                    constraints,
                    AppColors.blobViolet,
                    0.24 + 0.12 * math.sin(t * 1.3),
                    0.74 + 0.05 * math.cos(t * 0.9),
                    340,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _blob(
      BoxConstraints constraints,
      Color color,
      double xFactor,
      double yFactor,
      double size,
      ) {
    return Positioned(
      left: constraints.maxWidth * xFactor - size / 2,
      top: constraints.maxHeight * yFactor - size / 2,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[
                color.withValues(alpha: 0.50),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared page transition, so navigation matches the soft feel of the glass.
///
/// Deliberately not `CupertinoPageRoute` or `MaterialPageRoute` — the activity
/// asks us to lean on glass rather than on the stock design systems.
PageRouteBuilder<T> appPageRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) {
      final CurvedAnimation curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.045),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
