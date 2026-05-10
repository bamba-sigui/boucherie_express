import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';

/// Sticky bottom bar with total price and "Ajouter au Panier" CTA.
///
/// Design spec:
/// - bg-backgroundDark/80, backdrop-blur-2xl, border-t white/10
/// - Button: bg-freshRed, h-16, rounded-2xl, shadow-red
/// - Icon: shopping_basket, Text: "Ajouter au Panier · TOTAL"
class StickyAddToCartBar extends StatelessWidget {
  final double unitPrice;
  final int quantity;
  final VoidCallback onAddToCart;

  const StickyAddToCartBar({
    super.key,
    required this.unitPrice,
    required this.quantity,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = unitPrice * quantity;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: 16 + bottomPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: .8),
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: SizedBox(
            height: 64,
            child: ElevatedButton(
              onPressed: onAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.freshRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: AppColors.freshRed.withValues(alpha: .5),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_basket_outlined, size: 22),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Ajouter · ${FormatUtils.formatPrice(totalPrice)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
