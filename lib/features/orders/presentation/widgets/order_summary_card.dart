import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Carte récapitulatif financier de la commande.
///
/// Design Stitch (boucherie_express_home_5) :
/// - Background cardDark, rounded-2xl, border white/5, padding 20px (p-5)
/// - Sous-total : label slate-400, montant blanc → text-sm
/// - Frais de livraison : label slate-400, montant blanc → text-sm
/// - Divider pt-3 border-t white/5
/// - Total : "Total" blanc bold, montant primary text-xl font-black
class OrderSummaryCard extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double total;

  const OrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Sous-total
          _buildRow('Sous-total', _formatPrice(subtotal)),
          const SizedBox(height: 12),

          // Frais de livraison
          _buildRow('Frais de livraison', _formatPrice(deliveryFee)),
          const SizedBox(height: 12),

          // Divider
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatPrice(total),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
      ],
    );
  }

  /// Formate le prix avec séparateur de milliers (ex: 14.500 FCFA).
  String _formatPrice(double amount) {
    final intAmount = amount.toInt();
    final formatted = intAmount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted FCFA';
  }
}
