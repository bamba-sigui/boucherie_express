import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/delivery_address.dart';

/// Carte d'adresse de livraison.
///
/// Design Stitch :
/// - Icône location verte dans cercle bg-primary/10, size-14 (56px)
/// - Titre bold, détail secondaire
/// - Bouton "Modifier" ghost pill vert
class DeliveryAddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final VoidCallback? onEdit;

  const DeliveryAddressCard({super.key, required this.address, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ── Location icon ──
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // ── Address text ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${address.detail} • ${address.city}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Edit button ──
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Modifier',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
