import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../domain/entities/cart.dart';

/// Cart item card matching the Stitch design.
///
/// Layout:
/// ┌──────────────────────────────────────────┐
/// │ [Image]  Name              [delete btn]  │
/// │          [weight] [prep]                 │
/// │          Price         [-] 2 [+]         │
/// └──────────────────────────────────────────┘
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product image ──
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 96,
              height: 96,
              child: CachedNetworkImage(
                imageUrl: item.product.images.isNotEmpty ? item.product.images.first : '',
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.backgroundDark,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.backgroundDark,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // ── Details column ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + delete
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Badges: unit + preparation
                          Row(
                            children: [
                              _Badge(
                                label: item.product.unit.toUpperCase(),
                                isPrimary: true,
                              ),
                              const SizedBox(width: 8),
                              _Badge(
                                label: item.preparationOption.toUpperCase(),
                                isPrimary: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Delete button
                    GestureDetector(
                      onTap: onRemove,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Price + quantity selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      FormatUtils.formatPrice(item.totalPrice),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _CartQuantitySelector(
                      quantity: item.quantity,
                      onChanged: onQuantityChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small badge (weight / preparation option).
class _Badge extends StatelessWidget {
  final String label;
  final bool isPrimary;

  const _Badge({required this.label, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary.withValues(alpha: .1)
            : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrimary ? AppColors.primary : AppColors.textGrey,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: .8,
        ),
      ),
    );
  }
}

/// Compact quantity selector for cart items.
///
/// Design: rounded-full, bg-white/5, minus=bg-white/10, plus=bg-primary.
class _CartQuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _CartQuantitySelector({
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus
          GestureDetector(
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove_rounded,
                size: 16,
                color: quantity > 1
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),

          // Count
          SizedBox(
            width: 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Plus
          GestureDetector(
            onTap: () => onChanged(quantity + 1),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
