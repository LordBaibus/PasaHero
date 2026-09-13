import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/api_result.dart';
import '../core/server_session.dart';
import '../models/jeep_route.dart';
import '../services/route_service.dart';
import '../theme/app_theme.dart';
import '../widgets/route_card.dart';
import '../widgets/vehicle_filter_bar.dart';
import '../widgets/home_bottom_bar.dart';
import 'route_detail_screen.dart';
import 'route_form_screen.dart';

/// Main interface, reachable only after the server address has been verified.
///
/// Demonstrates the READ operation and is the launch point for Create, Update
/// and Delete.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

  List<JeepRoute> _routes = const <JeepRoute>[];
  String? _vehicleFilter;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    loadRoutes();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// READ — pulls the current list from routes_read.php.
  Future<void> loadRoutes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<JeepRoute> routes = await RouteService.instance.fetchRoutes(
        search: searchController.text,
        vehicleType: _vehicleFilter,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    }
  }

  /// Opens the form for Create (no argument) or Update (with a route).
  Future<void> openForm({JeepRoute? existing}) async {
    final bool? changed = await Navigator.of(context).push<bool>(
      appPageRoute<bool>(RouteFormScreen(existing: existing)),
    );

    if (changed == true) {
      await loadRoutes();
    }
  }

  /// Opens the detail screen, which hosts Update and Delete.
  Future<void> _openDetail(JeepRoute route) async {
    final bool? changed = await Navigator.of(context).push<bool>(
      appPageRoute<bool>(RouteDetailScreen(route: route)),
    );

    if (changed == true) {
      await loadRoutes();
    }
  }

  void _applyFilter(String? vehicleType) {
    setState(() => _vehicleFilter = vehicleType);
    loadRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: const AppBackground(),
      statusBarStyle: GlassStatusBarStyle.light,
      appBar: GlassAppBar(
        title: const _ConnectionTitle(),
        actions: <Widget>[
          GlassIconButton(
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            onPressed: loadRoutes,
          ),
        ],
      ),
      // Everything sits inside a SafeArea so nothing collides with the status
      // bar, the notch, or the gesture bar at the bottom.
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // SafeArea clears the status bar, but GlassScaffold floats the app
            // bar OVER the body, so this spacer clears the bar itself.
            const SizedBox(height: 58),
            VehicleFilterBar(
              selected: _vehicleFilter,
              onSelected: _applyFilter,
            ),
            const SizedBox(height: 14),
            Expanded(child: _buildBody()),
            HomeBottomBar(
              controller: searchController,
              onSearch: loadRoutes,
              onAdd: () => openForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Text('Loading routes...', style: AppTextStyles.caption),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 18),
              GlassButton(
                icon: const Icon(CupertinoIcons.refresh),
                label: 'Try again',
                onTap: loadRoutes,
              ),
            ],
          ),
        ),
      );
    }

    if (_routes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 44),
          child: Text(
            'No routes found.\nTap the plus button to create the first record.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      itemCount: _routes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final JeepRoute route = _routes[index];
        return RouteCard(
          route: route,
          onTap: () => _openDetail(route),
        );
      },
    );
  }
}

/// Replaces the old "PasaHero" title.
///
/// Shows a green dot and the host the app is currently talking to, which is
/// far more useful on screen during the demonstration than the app name.
class _ConnectionTitle extends StatelessWidget {
  const _ConnectionTitle();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ServerSession.instance.hostLabel,
      builder: (BuildContext context, String host, Widget? child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              host.isEmpty ? 'Connected' : host,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          ],
        );
      },
    );
  }
}
