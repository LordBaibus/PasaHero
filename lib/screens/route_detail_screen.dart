import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/api_result.dart';
import '../models/jeep_route.dart';
import '../services/route_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/detail_row.dart';
import 'route_form_screen.dart';

/// Full view of a single route, and the home of the DELETE operation.
///
/// Pops with `true` when the record was changed or removed, so the home screen
/// reloads its list.
class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({super.key, required this.route});

  final JeepRoute route;

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late JeepRoute _route = widget.route;

  /// Tracks whether anything changed, so we know what to pop with.
  bool _hasChanges = false;

  /// True while the delete request is in flight.
  bool _isDeleting = false;

  /// Opens Member D's form in edit mode, then refreshes from the server.
  Future<void> _handleEdit() async {
    if (_isDeleting) {
      return;
    }

    final bool? changed = await Navigator.of(context).push<bool>(
      appPageRoute<bool>(RouteFormScreen(existing: _route)),
    );

    if (changed != true || !mounted) {
      return;
    }

    _hasChanges = true;

    // Re-read the record so what we show is what MySQL actually stored.
    try {
      final JeepRoute refreshed =
      await RouteService.instance.fetchRouteById(_route.id);

      if (!mounted) {
        return;
      }

      setState(() => _route = refreshed);
    } on ApiException {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  /// DELETE — asks first, then removes the record from the database.
  Future<void> _handleDelete() async {
    if (_isDeleting) {
      return;
    }

    final bool confirmed = await AppDialogs.showConfirm(
      context,
      title: 'Delete Route',
      message:
      'This will permanently remove "${_route.routeName}" from the '
          'database. This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
    );

    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _isDeleting = true);

    try {
      final String message =
      await RouteService.instance.deleteRoute(_route.id);

      if (!mounted) {
        return;
      }

      setState(() => _isDeleting = false);

      await AppDialogs.showSuccess(
        context,
        title: 'Route Deleted',
        message: message,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() => _isDeleting = false);

      await AppDialogs.showError(
        context,
        title: 'Delete Failed',
        message: e.message,
      );
    }
  }

  void _close() {
    if (!_isDeleting) {
      Navigator.of(context).pop(_hasChanges);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: const AppBackground(),
      statusBarStyle: GlassStatusBarStyle.light,
      appBar: GlassAppBar(
        title: const Text('Route Details', style: AppTextStyles.title),
        actions: <Widget>[
          GlassIconButton(
            icon: const Icon(CupertinoIcons.xmark),
            onPressed: _close,
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
              _HeroPanel(route: _route),
              const SizedBox(height: 14),

              GlassCard(
                quality: GlassQuality.minimal,
                settings: AppGlass.card,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    DetailRow(
                      icon: CupertinoIcons.location,
                      label: 'Origin',
                      value: _route.origin,
                    ),
                    DetailRow(
                      icon: CupertinoIcons.location_solid,
                      label: 'Destination',
                      value: _route.destination,
                    ),
                    // Peso character instead of CupertinoIcons.money_dollar,
                    // which is a dollar sign.
                    DetailRow(
                      prefix: const PesoSign(),
                      label: 'Regular Fare',
                      value: _route.regularFareLabel,
                    ),
                    DetailRow(
                      icon: CupertinoIcons.tag,
                      label: 'Discounted Fare',
                      value: _route.discountedFareLabel,
                    ),
                    DetailRow(
                      icon: CupertinoIcons.clock,
                      label: 'Operating Hours',
                      value: _route.operatingHours.isEmpty
                          ? 'Not specified'
                          : _route.operatingHours,
                    ),
                    DetailRow(
                      icon: CupertinoIcons.doc_text,
                      label: 'Notes',
                      value: _route.notes.isEmpty ? 'No notes' : _route.notes,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // Edit and Delete side by side instead of stacked.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _ActionButton(
                    icon: CupertinoIcons.pencil,
                    label: 'Edit',
                    width: 128,
                    color: AppColors.accent,
                    onTap: _handleEdit,
                  ),
                  const SizedBox(width: 14),
                  _ActionButton(
                    icon: _isDeleting
                        ? CupertinoIcons.arrow_2_circlepath
                        : CupertinoIcons.trash,
                    label: _isDeleting ? 'Deleting' : 'Delete',
                    width: 138,
                    color: AppColors.danger,
                    onTap: _handleDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route name and status at the top of the screen.
class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.route});

  final JeepRoute route;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      // Fixed, non-scrolling surface, so premium quality is safe here.
      quality: GlassQuality.premium,
      settings: AppGlass.hero,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            route.routeName,
            style: AppTextStyles.display.copyWith(
              fontSize: 23,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(
                route.isActive
                    ? CupertinoIcons.checkmark_seal_fill
                    : CupertinoIcons.pause_circle_fill,
                size: 15,
                color: route.isActive ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 7),
              Text(
                '${route.vehicleTypeLabel}  \u00B7  '
                    '${route.isActive ? "Active" : "Inactive"}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Action button with a visible icon and label.
///
/// GlassButton.custom is required here. The default GlassButton constructor
/// only paints an icon — its `label` argument is a semantic label for screen
/// readers and never appears on screen.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.width,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;

  /// GlassButton.custom does not measure its child, so the width is explicit.
  final double width;

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassButton.custom(
      onTap: onTap,
      width: width,
      height: 50,
      shape: const LiquidRoundedRectangle(borderRadius: 25),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}