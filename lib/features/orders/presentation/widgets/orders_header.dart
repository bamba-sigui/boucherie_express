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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
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
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),

          // ── Icône notification ──
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
