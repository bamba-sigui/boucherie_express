import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Section "Cartes bancaires" vide — design Stitch (home_14).
///
/// Gradient sombre, icône credit_card, texte "Aucune carte enregistrée".
class EmptyCardsWidget extends StatelessWidget {
  final VoidCallback onAdd;

  const EmptyCardsWidget({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'CARTES BANCAIRES',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            GestureDetector(
              onTap: onAdd,
              child: Row(
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AJOUTER',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Empty state card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B).withValues(alpha: .6),
                const Color(0xFF0F172A).withValues(alpha: .6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.credit_card_rounded,
                color: AppColors.textSecondary,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'Aucune carte enregistrée',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
