import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../theme/app_theme.dart';

/// Search field and add button, docked at the bottom of the home screen.
///
/// Sitting at the bottom keeps both controls within thumb reach and leaves the
/// top of the screen clear, which is where GlassScaffold floats its app bar.
///
/// The home screen already wraps its body in a SafeArea, so no gesture-bar
/// inset is added here.
class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onAdd,
  });

  final TextEditingController controller;

  /// Called when the user submits the search field.
  final VoidCallback onSearch;

  /// Called when the plus button is tapped.
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: SizedBox(
        height: 56,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: GlassTextField.search(
                controller: controller,
                placeholder: 'Search routes',
                useOwnLayer: true,
                settings: AppGlass.input,
                textStyle: AppTextStyles.body,
                placeholderStyle: AppTextStyles.placeholder,
                prefixIcon: const Icon(
                  CupertinoIcons.search,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onSubmitted: (_) => onSearch(),
              ),
            ),
            const SizedBox(width: 12),
            GlassButton(
              icon: const Icon(CupertinoIcons.add),
              label: 'Add new route',
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
