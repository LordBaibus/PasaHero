import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/ip_validator.dart';
import '../core/server_session.dart';
import '../theme/app_theme.dart';
import '../widgets/app_dialogs.dart';
import 'home_screen.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _isConnecting = false;
  String? _inlineError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    if (_isConnecting) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _inlineError = null;
      _isConnecting = true;
    });

    final error = await ServerSession.instance.connect(_controller.text);

    if (!mounted) {
      return;
    }

    setState(() => _isConnecting = false);

    if (error != null) {
      setState(() => _inlineError = error);

      // Required by the activity: an error dialog on an invalid or
      // unreachable address.
      await AppDialogs.showError(
        context,
        title: 'Connection Failed',
        message: error,
      );
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      appPageRoute(const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = IpValidator.buildBaseUrl(_controller.text);

    return GlassScaffold(
      background: const AppBackground(),
      statusBarStyle: GlassStatusBarStyle.light,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _BrandHeader(),
                const SizedBox(height: 34),

                // Field label.
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 10),
                  child: Text('SERVER IP ADDRESS', style: AppTextStyles.label),
                ),

                // The glass input field required by the activity.
                GlassTextField(
                  controller: _controller,
                  placeholder: '192.168.1.14',
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.go,
                  enabled: !_isConnecting,
                  autofocus: true,
                  useOwnLayer: true,
                  settings: AppGlass.input,
                  shape: const LiquidRoundedRectangle(borderRadius: 16),
                  prefixIcon: const Icon(
                    CupertinoIcons.antenna_radiowaves_left_right,
                    size: 19,
                    color: AppColors.textMuted,
                  ),
                  textStyle: AppTextStyles.body,
                  placeholderStyle: AppTextStyles.placeholder,
                  onChanged: (_) {
                    if (_inlineError != null) {
                      setState(() => _inlineError = null);
                    } else {
                      setState(() {});
                    }
                  },
                  onSubmitted: (_) => _handleConnect(),
                ),

                const SizedBox(height: 10),
                _ResolvedUrlHint(url: resolvedUrl),

                if (_inlineError != null) ...<Widget>[
                  const SizedBox(height: 16),
                  _InlineError(message: _inlineError!),
                ],

                const SizedBox(height: 26),

                Center(
                  child: GlassButton(
                    icon: Icon(
                      _isConnecting
                          ? CupertinoIcons.arrow_2_circlepath
                          : CupertinoIcons.link,
                    ),
                    label: _isConnecting
                        ? 'Verifying connection...'
                        : 'Connect to Server',
                    onTap: _handleConnect,
                  ),
                ),

                const SizedBox(height: 30),
                const _SetupChecklist(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GlassCard(
          quality: GlassQuality.premium,
          padding: const EdgeInsets.all(20),
          child: const Icon(
            CupertinoIcons.bus,
            size: 42,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'PasaHero',
          textAlign: TextAlign.center,
          style: AppTextStyles.display,
        ),
        const SizedBox(height: 6),
        const Text(
          'Local transport route and fare guide',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle,
        ),
      ],
    );
  }
}

class _ResolvedUrlHint extends StatelessWidget {
  const _ResolvedUrlHint({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final display = url.isEmpty ? 'http://<your-ip>/pasahero_api/api' : url;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            CupertinoIcons.arrow_turn_down_right,
            size: 13,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(display, style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      quality: GlassQuality.minimal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              size: 16,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _SetupChecklist extends StatelessWidget {
  const _SetupChecklist();

  @override
  Widget build(BuildContext context) {
    const items = <String>[
      'Apache and MySQL are running in XAMPP',
      'This device is on the same Wi-Fi as the server',
      'Port 80 is allowed through the server firewall',
    ];

    return GlassCard(
      quality: GlassQuality.minimal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('BEFORE CONNECTING', style: AppTextStyles.label),
          const SizedBox(height: 14),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      CupertinoIcons.check_mark_circled,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(item, style: AppTextStyles.caption),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
