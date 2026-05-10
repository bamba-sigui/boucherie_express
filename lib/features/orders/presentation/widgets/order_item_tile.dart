import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order.dart';

/// Tuile d'un article dans la page détails commande.
///
/// Design Stitch (boucherie_express_home_5) :
/// - Image carrée arrondie (size-20 → 80px) à gauche
/// - Nom produit blanc (font-bold, text-sm)
/// - Quantité gris (text-xs, slate-400)
/// - Prix vert fluo (font-bold, text-primary)
/// - Padding 16px, gap 16px
class OrderItemTile extends StatelessWidget {
  final OrderItem item;

  const OrderItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image produit ──
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF1E293B),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.restaurant,
                        color: AppColors.textSecondary,
                        size: 32,
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.restaurant,
                      color: AppColors.textSecondary,
                      size: 32,
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // ── Info produit ──
          Expanded(
            child: SizedBox(
              height: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nom + quantité
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantité: ${item.quantity}${item.option.isNotEmpty ? ' • ${item.option}' : ''}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  // Prix
                  Text(
                    _formatPrice(item.price * item.quantity),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formate le prix avec séparateur de milliers (ex: 11.000 FCFA).
  String _formatPrice(double amount) {
    final intAmount = amount.toInt();
    final formatted = intAmount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted FCFA';
  }
}
