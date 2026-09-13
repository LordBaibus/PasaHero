import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../theme/app_theme.dart';

class FormFieldGroup extends StatelessWidget {
  const FormFieldGroup({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder = '',
    this.icon,
    this.prefix,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.helperText,
  });

  final String label;

  final TextEditingController controller;
  final String placeholder;

  final IconData? icon;

  final Widget? prefix;

  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final Widget? resolvedPrefix = prefix ??
        (icon == null
            ? null
            : Icon(icon, size: 18, color: AppColors.textMuted));

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 9),
            child: Text(label.toUpperCase(), style: AppTextStyles.label),
          ),
          GlassTextField(
            controller: controller,
            placeholder: placeholder,
            keyboardType: keyboardType,
            maxLines: maxLines,
            minLines: maxLines > 1 ? maxLines : null,
            enabled: enabled,
            useOwnLayer: true,
            settings: AppGlass.input,
            shape: const LiquidRoundedRectangle(borderRadius: 14),
            textStyle: AppTextStyles.body,
            placeholderStyle: AppTextStyles.placeholder,
            prefixIcon: resolvedPrefix,
            onChanged: onChanged,
          ),
          if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 7),
              child: Text(helperText!, style: AppTextStyles.caption),
            ),
        ],
      ),
    );
  }
}
