import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AppDialogs {
  const AppDialogs._();

  static Future<void> showError(
      BuildContext context, {
        String title = 'Connection Failed',
        required String message,
      }) {
    return GlassDialog.show<void>(
      context: context,
      title: title,
      message: message,
      barrierDismissible: true,
      quality: GlassQuality.standard,
      actions: <GlassDialogAction>[
        GlassDialogAction(
          label: 'Close',
          isPrimary: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  static Future<void> showSuccess(
      BuildContext context, {
        required String title,
        required String message,
      }) {
    return GlassDialog.show<void>(
      context: context,
      title: title,
      message: message,
      barrierDismissible: true,
      quality: GlassQuality.standard,
      actions: <GlassDialogAction>[
        GlassDialogAction(
          label: 'Close',
          isPrimary: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  static Future<bool> showConfirm(
      BuildContext context, {
        required String title,
        required String message,
        String confirmLabel = 'Confirm',
        String cancelLabel = 'Cancel',
        bool isDestructive = true,
      }) async {
    final result = await GlassDialog.show<bool>(
      context: context,
      title: title,
      message: message,
      barrierDismissible: true,
      quality: GlassQuality.standard,
      actions: <GlassDialogAction>[
        GlassDialogAction(
          label: cancelLabel,
          onPressed: () => Navigator.pop(context, false),
        ),
        GlassDialogAction(
          label: confirmLabel,
          isDestructive: isDestructive,
          isPrimary: !isDestructive,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );

    return result ?? false;
  }

  static Future<void> showServerDisconnected(
      BuildContext context, {
        required String host,
        required VoidCallback onClose,
      }) {
    final where = host.isEmpty ? 'the PHP API' : 'the PHP API at $host';

    return GlassDialog.show<void>(
      context: context,
      title: 'Server Disconnected',
      message:
      'The application can no longer reach $where. Check that Apache and '
          'MySQL are still running in XAMPP and that this device is on the '
          'same network.\n\nYou will be returned to the connection screen.',
      barrierDismissible: false,
      quality: GlassQuality.standard,
      actions: <GlassDialogAction>[
        GlassDialogAction(
          label: 'Close',
          isPrimary: true,
          onPressed: () {
            Navigator.pop(context);
            onClose();
          },
        ),
      ],
    );
  }
}
