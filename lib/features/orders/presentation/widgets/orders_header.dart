import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Header de la page Mes Commandes.
///
/// Design Stitch (boucherie_express_home_11) :
/// - Titre « Mes commandes » à gauche, blanc, font-black, tracking-tight
/// - Icône notification à droite dans un cercle cardDark
/// - Bordure inférieure white/5
class OrdersHeader extends StatelessWidget {
  const OrdersHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Titre ──
          const Text(
            'Mes commandes',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),

          // ── Icône notification ──
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
