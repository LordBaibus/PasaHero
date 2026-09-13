import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/api_result.dart';
import '../models/jeep_route.dart';
import '../services/route_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/detail_row.dart';
import 'route_form_screen.dart';

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({super.key, required this.route});

  final JeepRoute route;

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late JeepRoute _route = widget.route;

  bool _hasChanges = false;

  bool _isDeleting = false;

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
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
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
                    DetailRow(
                      icon: CupertinoIcons.money_dollar,
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

              const SizedBox(height: 24),
              Center(
                child: GlassButton(
                  icon: const Icon(CupertinoIcons.pencil),
                  label: 'Edit Route',
                  onTap: _handleEdit,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: GlassButton(
                  icon: Icon(
                    _isDeleting
                        ? CupertinoIcons.arrow_2_circlepath
                        : CupertinoIcons.trash,
                  ),
                  label: _isDeleting ? 'Deleting...' : 'Delete Route',
                  onTap: _handleDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          Text(route.routeName, style: AppTextStyles.display.copyWith(
            fontSize: 23,
            height: 1.25,
          )),
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
