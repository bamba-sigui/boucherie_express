import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Bouton de déconnexion.
///
/// Design Stitch (home_13) :
/// - bg-brandRed/10, border brand-red/20
/// - Texte + icône brand-red, font-bold
/// - Hover : bg-brandRed, text-white
/// - Affiche une modale de confirmation
class LogoutButton extends StatelessWidget {
  final VoidCallback onConfirmed;

  const LogoutButton({super.key, required this.onConfirmed});

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Déconnexion',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'ANNULER',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirmed();
            },
            child: const Text(
              'DÉCONNEXION',
              style: TextStyle(
                color: AppColors.accentRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showConfirmationDialog(context),
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.accentRed.withValues(alpha: .15),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.accentRed.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentRed.withValues(alpha: .2),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: AppColors.accentRed,
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  'Déconnexion',
                  style: TextStyle(
                    color: AppColors.accentRed,
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
