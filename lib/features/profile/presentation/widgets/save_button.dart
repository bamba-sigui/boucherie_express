import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Bouton "Enregistrer les modifications" de la page infos personnelles.
///
/// Design Stitch (home_2) :
/// - bg-brandRed, text-white, font-bold, py-4, rounded-2xl
/// - Icône save à gauche
/// - shadow-lg shadow-brandRed/20
/// - active:scale-[0.98] transition
/// - État désactivé si aucun changement
/// - État loading avec spinner
class SaveButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const SaveButton({
    super.key,
    this.enabled = true,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = enabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.accentRed
                  : AppColors.accentRed.withValues(alpha: .3),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.accentRed.withValues(alpha: .2),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    Icons.save_rounded,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: .4),
                    size: 22,
                  ),
                const SizedBox(width: 12),
                Text(
                  isLoading
                      ? 'Enregistrement...'
                      : 'Enregistrer les modifications',
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: .4),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
