import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order.dart';

/// Extension pour formater les dates de commande.
extension _OrderDetailDateFormat on DateTime {
  String toDetailLabel() {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '$day ${months[month - 1]} $year';
  }
}

/// Header "Détails de la commande" avec bouton retour.
///
/// Design Stitch (boucherie_express_home_5) :
/// - Sticky top, backdrop blur
/// - Bouton retour ← (rounded-full, hover bg-white/5)
/// - Titre « Détails de la Commande » (text-lg, font-bold)
/// - Sous-titre « #BE-1234 • 24 Mai 2024 » (text-xs, slate-400, font-medium)
/// - Border-bottom white/5
class OrderDetailsHeader extends StatelessWidget {
  final Order order;
  final VoidCallback? onBack;

  const OrderDetailsHeader({super.key, required this.order, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // ── Bouton retour ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack ?? () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(9999),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── Titre + sous-titre ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Détails de la Commande',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '#${order.id} • ${order.orderedAt.toDetailLabel()}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
