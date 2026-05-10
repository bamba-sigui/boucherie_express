import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Carte d'adresse de livraison dans la page détails commande.
///
/// Design Stitch (boucherie_express_home_5) :
/// - Background cardDark, rounded-2xl, border white/5
/// - Icône location_on (slate-400, text-sm)
/// - Label "ADRESSE DE LIVRAISON" (slate-400, xs, bold, uppercase, tracking-wider)
/// - Adresse complète (text-sm, blanc)
class DeliveryAddressCard extends StatelessWidget {
  final String address;

  const DeliveryAddressCard({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label ──
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey.shade500, size: 16),
              const SizedBox(width: 8),
              Text(
                'ADRESSE DE LIVRAISON',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Adresse ──
          Text(
            address,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
