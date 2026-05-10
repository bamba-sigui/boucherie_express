import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Champ de saisie stylisé pour la page Informations personnelles.
///
/// Design Stitch (home_2) :
/// - Label gris semibold au-dessus
/// - Input bg-cardDark, border white/5, rounded-2xl, py-4, pl-12
/// - Icône à gauche dans l'input (slate-500, passe primary au focus)
/// - Bordure accent vert au focus
class ProfileInputField extends StatefulWidget {
  final String label;
  final String placeholder;
  final IconData icon;
  final String? initialValue;
  final TextInputType keyboardType;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.icon,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onChanged,
    this.errorText,
  });

  @override
  State<ProfileInputField> createState() => _ProfileInputFieldState();
}

class _ProfileInputFieldState extends State<ProfileInputField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(covariant ProfileInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Input
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? AppColors.accentRed.withValues(alpha: .6)
                  : _isFocused
                  ? AppColors.primary
                  : AppColors.border,
              width: _isFocused || hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: widget.readOnly,
            keyboardType: widget.keyboardType,
            style: TextStyle(
              color: widget.readOnly
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.icon,
                    key: ValueKey(_isFocused),
                    color: _isFocused
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 50),
              hintText: widget.placeholder,
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),

        // Erreur
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: AppColors.accentRed.withValues(alpha: .8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
