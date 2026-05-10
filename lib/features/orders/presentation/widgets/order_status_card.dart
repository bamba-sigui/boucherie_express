import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order.dart';

/// Carte de statut de la commande.
///
/// Design Stitch (boucherie_express_home_5) :
/// - Background cardDark, rounded-2xl, border white/5
/// - Icône camion dans cercle bleu/20 à gauche (size-10)
/// - Label "STATUT" gris uppercase tracking-wider
/// - Statut dynamique coloré (bold)
/// - Chevron > à droite (slate-500)
/// - Carte cliquable → future page tracking
class OrderStatusCard extends StatelessWidget {
  final OrderStatus status;
  final VoidCallback? onTap;

  const OrderStatusCard({super.key, required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label, IconData icon) = _statusData(status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // ── Icône dans cercle ──
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),

              // ── Texte ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUT',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Chevron ──
              Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  (Color, String, IconData) _statusData(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => (
        AppColors.statusOrange,
        'En attente de confirmation',
        Icons.hourglass_top,
      ),
      OrderStatus.confirmed => (
        AppColors.statusBlue,
        'Commande confirmée',
        Icons.check_circle_outline,
      ),
      OrderStatus.preparing => (
        AppColors.statusOrange,
        'En cours de préparation',
        Icons.restaurant,
      ),
      OrderStatus.delivering => (
        AppColors.statusBlue,
        'En cours de livraison',
        Icons.local_shipping,
      ),
      OrderStatus.delivered => (
        AppColors.statusGreen,
        'Livrée avec succès',
        Icons.check_circle,
      ),
      OrderStatus.cancelled => (
        AppColors.error,
        'Commande annulée',
        Icons.cancel_outlined,
      ),
    };
  }
}
