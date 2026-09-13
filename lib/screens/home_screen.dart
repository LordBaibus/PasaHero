import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/api_config.dart';
import '../core/api_result.dart';
import '../core/server_session.dart';
import '../models/jeep_route.dart';
import '../services/route_service.dart';
import '../theme/app_theme.dart';
import '../widgets/route_card.dart';
import 'route_detail_screen.dart';
import 'route_form_screen.dart';

/// Main interface, reachable only after the server address has been verified.
///
/// Demonstrates the READ operation and is the launch point for Create (the
/// add button), Update and Delete (through the detail screen).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<JeepRoute> _routes = const <JeepRoute>[];
  String? _vehicleFilter;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// READ — pulls the current list from routes_read.php.
  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<JeepRoute> routes = await RouteService.instance.fetchRoutes(
        search: _searchController.text,
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
  Future<void> _openForm({JeepRoute? existing}) async {
    final bool? changed = await Navigator.of(context).push<bool>(
      appPageRoute<bool>(RouteFormScreen(existing: existing)),
    );

    if (changed == true) {
      await _loadRoutes();
    }
  }

  /// Opens the detail screen, which hosts Update and Delete.
  Future<void> _openDetail(JeepRoute route) async {
    final bool? changed = await Navigator.of(context).push<bool>(
      appPageRoute<bool>(RouteDetailScreen(route: route)),
    );

    if (changed == true) {
      await _loadRoutes();
    }
  }

  void _applyFilter(String? vehicleType) {
    setState(() => _vehicleFilter = vehicleType);
    _loadRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: const AppBackground(),
      statusBarStyle: GlassStatusBarStyle.light,
      appBar: GlassAppBar(
        title: const Text('PasaHero', style: AppTextStyles.title),
        actions: <Widget>[
          GlassIconButton(
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            onPressed: _loadRoutes,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            const _ConnectionBanner(),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassTextField.search(
                controller: _searchController,
                placeholder: 'Search route, origin or destination',
                useOwnLayer: true,
                settings: AppGlass.input,
                textStyle: AppTextStyles.body,
                placeholderStyle: AppTextStyles.placeholder,
                prefixIcon: const Icon(
                  CupertinoIcons.search,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onSubmitted: (_) => _loadRoutes(),
              ),
            ),

            const SizedBox(height: 14),
            _FilterRow(
              selected: _vehicleFilter,
              onSelected: _applyFilter,
            ),
            const SizedBox(height: 16),

            Expanded(child: _buildBody()),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: Center(
                child: GlassButton(
                  icon: const Icon(CupertinoIcons.add),
                  label: 'Add New Route',
                  onTap: () => _openForm(),
                ),
              ),
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
                label: 'Try Again',
                onTap: _loadRoutes,
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
            'No routes found.\nTap "Add New Route" to create the first record.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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

/// Shows which server the app is currently talking to.
class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ValueListenableBuilder<String>(
        valueListenable: ServerSession.instance.hostLabel,
        builder: (BuildContext context, String host, Widget? child) {
          return Row(
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
              Expanded(
                child: Text(
                  host.isEmpty ? 'Connected' : 'Connected to $host',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Horizontal row of vehicle-type filters.
class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: <Widget>[
          _FilterButton(
            label: 'All',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final String type in VehicleTypes.all) ...<Widget>[
            const SizedBox(width: 9),
            _FilterButton(
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

/// One filter option. Selection is shown by the icon, not by colour alone.
class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      icon: Icon(
        isSelected
            ? CupertinoIcons.checkmark_circle_fill
            : CupertinoIcons.circle,
        size: 15,
      ),
      label: label,
      onTap: onTap,
    );
  }
}
