import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'core/server_session.dart';
import 'screens/connect_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_dialogs.dart';


final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-warms the liquid glass shaders so the first screen renders correctly
  // on frame one instead of flashing.
  await LiquidGlassWidgets.initialize();

  runApp(
    LiquidGlassWidgets.wrap(
      child: const PasaHeroApp(),
    ),
  );
}

class PasaHeroApp extends StatefulWidget {
  const PasaHeroApp({super.key});

  @override
  State<PasaHeroApp> createState() => _PasaHeroAppState();
}

class _PasaHeroAppState extends State<PasaHeroApp> {
  /// Guards against stacking two disconnection dialogs on top of each other.
  bool _isDialogVisible = false;

  @override
  void initState() {
    super.initState();
    ServerSession.instance.isConnected.addListener(_handleConnectionChange);
  }

  @override
  void dispose() {
    ServerSession.instance.isConnected.removeListener(_handleConnectionChange);
    super.dispose();
  }

  /// Fires whenever the heartbeat decides the PHP server is no longer
  /// reachable while the application is running.
  void _handleConnectionChange() {
    // Only react to the transition into the disconnected state.
    if (ServerSession.instance.isConnected.value) {
      return;
    }

    if (_isDialogVisible) {
      return;
    }

    final NavigatorState? navigator = appNavigatorKey.currentState;

    if (navigator == null || !navigator.mounted) {
      return;
    }

    _isDialogVisible = true;

    AppDialogs.showServerDisconnected(
      navigator.context,
      host: ServerSession.instance.hostLabel.value,
      onClose: _returnToConnectScreen,
    ).then((_) => _isDialogVisible = false);
  }

  /// Forgets the server and sends the user back to the gate screen.
  void _returnToConnectScreen() {
    ServerSession.instance.reset();

    appNavigatorKey.currentState?.pushAndRemoveUntil<void>(
      appPageRoute<void>(const ConnectScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'PasaHero',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.accent,
        scaffoldBackgroundColor: AppColors.backdropTop,
      ),
      // The connect screen is the gate. Nothing else is reachable until a
      // server address has been verified.
      home: const ConnectScreen(),
    );
  }
}
