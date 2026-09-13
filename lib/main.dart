import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'screens/connect_screen.dart';
import 'theme/app_theme.dart';

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

class PasaHeroApp extends StatelessWidget {
  const PasaHeroApp({super.key});

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
