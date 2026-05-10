import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order.dart';

/// Avatars circulaires empilés des produits d'une commande.
///
/// Design Stitch (boucherie_express_home_11) :
/// - Images circulaires 32×32 (size-8) avec bordure 2px cardDark
/// - Empilés avec -12px d'overlap (flex -space-x-3)
/// - Maximum 2 images visibles
/// - Badge "+X" si plus de 2 items
class OrderProductAvatars extends StatelessWidget {
  final List<OrderItem> items;

  /// Nombre max d'avatars image avant le badge "+X".
  final int maxVisible;

  const OrderProductAvatars({
    super.key,
    required this.items,
    this.maxVisible = 2,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = items.length > maxVisible ? maxVisible : items.length;
    final remaining = items.length - visibleCount;

    final avatars = <Widget>[];

    for (int i = 0; i < visibleCount; i++) {
      avatars.add(_buildImageAvatar(items[i].imageUrl, i));
    }

    if (remaining > 0) {
      avatars.add(_buildCountBadge(remaining, visibleCount));
    }

    if (avatars.isEmpty) {
      return const SizedBox(width: 32, height: 32);
    }

    final totalCount = visibleCount + (remaining > 0 ? 1 : 0);
    final width = (totalCount - 1) * 20.0 + 32.0;

    return SizedBox(
      width: width,
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Non-positioned child to anchor the Stack's layout
          SizedBox(width: width, height: 32),
          ...avatars,
        ],
      ),
    );
  }

  Widget _buildImageAvatar(String? imageUrl, int index) {
    return Positioned(
      left: index * 20.0, // 32 - 12 overlap
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cardDark, width: 2),
          color: const Color(0xFF1E293B), // slate-800 fallback
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.restaurant,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                )
              : const Icon(Icons.restaurant, size: 14, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildCountBadge(int count, int positionIndex) {
    return Positioned(
      left: positionIndex * 20.0,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // slate-800
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cardDark, width: 2),
        ),
        child: Center(
          child: Text(
            '+$count',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
