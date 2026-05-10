import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order.dart';
import 'order_product_avatars.dart';
import 'order_status_badge.dart';

/// Extension pour formater les dates de commande de façon humaine.
extension _OrderDateFormat on DateTime {
  String toOrderLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final orderDay = DateTime(year, month, day);

    final time =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    if (orderDay == today) {
      return 'Aujourd\'hui, $time';
    } else if (orderDay == yesterday) {
      return 'Hier, $time';
    }

    const months = [
      'Jan.',
      'Fév.',
      'Mars',
      'Avr.',
      'Mai',
      'Juin',
      'Juil.',
      'Août',
      'Sep.',
      'Oct.',
      'Nov.',
      'Déc.',
    ];
    return '${day.toString().padLeft(2, '0')} ${months[month - 1]} $year, $time';
  }
}

/// Carte de commande pixel-perfect.
///
/// Design Stitch (boucherie_express_home_11) :
/// - Background cardDark (#161D19)
/// - Border radius 2xl (rounded-2xl → 16+)
/// - Bordure white/5
/// - Padding 20px (p-5)
///
/// Structure :
/// ```
/// ┌────────────────────────────────────┐
/// │ COMMANDE               [BADGE]    │
/// │ #BE-1245                           │
/// │ Aujourd'hui, 14:30                 │
/// ├────────────────────────────────────┤
/// │ [img1][img2][+1]      TOTAL       │
/// │                    12.500 FCFA     │
/// └────────────────────────────────────┘
/// ```
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  /// Opacité réduite pour les commandes livrées anciennes.
  final double opacity;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── En-tête : label + numéro + date + badge ──
                _buildHeader(),

                const SizedBox(height: 16),

                // ── Séparateur ──
                Container(
                  height: 1,
                  color: AppColors.surface,
                ),

                const SizedBox(height: 16),

                // ── Pied : avatars produits + total ──
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Info commande (gauche) ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label "COMMANDE"
              Text(
                'COMMANDE',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),

              // Numéro de commande
              Text(
                '#${order.id}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // Date formatée
              Text(
                order.orderedAt.toOrderLabel(),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),

        // ── Badge statut (droite) ──
        OrderStatusBadge(status: order.status),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Avatars produits ──
        OrderProductAvatars(items: order.items),

        // ── Total ──
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'TOTAL',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatPrice(order.totalAmount),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Formate le prix avec séparateur de milliers (ex: 12.500 FCFA).
  String _formatPrice(double amount) {
    final intAmount = amount.toInt();
    final formatted = intAmount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted FCFA';
  }
}
