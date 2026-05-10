import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Section disponibilité (en stock) avec switch.
///
/// Design : carte sombre, icône check verte, texte "En stock", switch vert.
class FilterAvailabilityToggle extends StatelessWidget {
  final bool inStock;
  final ValueChanged<bool> onChanged;

  const FilterAvailabilityToggle({
    super.key,
    required this.inStock,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disponibilité',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.categoryUnselected,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Icône check
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: inStock
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: inStock ? AppColors.primary : Colors.grey.shade500,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'En stock',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Afficher uniquement les produits disponibles',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Switch
                Switch(
                  value: inStock,
                  onChanged: onChanged,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.grey.shade600,
                  inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
