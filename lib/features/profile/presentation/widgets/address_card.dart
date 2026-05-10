import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/address.dart';

/// Carte d'adresse interactive.
///
/// Design Stitch (home_6) :
/// - bg-cardDark, rounded-2xl
/// - Sélectionnée : border-2 primary/50 | Non sélectionnée : border white/5
/// - Icône type (home/work/location) dans cercle
/// - Badge "PAR DÉFAUT" vert si [address.isDefault]
/// - Boutons Modifier / Supprimer en bas, séparés par border-t white/5
/// - Radio button à droite
class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _iconForType(AddressType type) {
    switch (type) {
      case AddressType.home:
        return Icons.home_rounded;
      case AddressType.work:
        return Icons.work_rounded;
      case AddressType.other:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDefault = address.isDefault;

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDefault
                ? AppColors.primary.withValues(alpha: .5)
                : AppColors.border,
            width: isDefault ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // ── Contenu principal ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône type
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDefault
                        ? AppColors.primary.withValues(alpha: .1)
                        : AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconForType(address.type),
                    color: isDefault
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Label + adresse
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.label,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: .2),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Text(
                                'PAR DÉFAUT',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.fullAddress,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Radio button
                _RadioIndicator(isSelected: isDefault),
              ],
            ),

            // ── Actions Modifier / Supprimer ──
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Modifier
                    GestureDetector(
                      onTap: onEdit,
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Modifier',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Supprimer
                    GestureDetector(
                      onTap: onDelete,
                      child: const Row(
                        children: [
                          Icon(
                            Icons.delete_rounded,
                            color: AppColors.accentRed,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Supprimer',
                            style: TextStyle(
                              color: AppColors.accentRed,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicateur radio custom fidèle au design Stitch.
class _RadioIndicator extends StatelessWidget {
  final bool isSelected;

  const _RadioIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.border,
          width: isSelected ? 7 : 2,
        ),
        color: isSelected ? AppColors.backgroundDark : AppColors.backgroundDark,
      ),
    );
  }
}
