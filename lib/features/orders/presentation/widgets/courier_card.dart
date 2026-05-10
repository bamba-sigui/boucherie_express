import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/courier.dart';

/// Carte livreur fixée en bas de l'écran.
///
/// Design Stitch :
/// - bg-cardDark/90 + blur, rounded-ios, border-white/10
/// - Photo ronde (56px) avec badge verified
/// - Nom, étoile rating, véhicule
/// - Boutons : message (gris) + appel (vert primary)
class CourierCard extends StatelessWidget {
  final Courier courier;
  final bool canCall;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  const CourierCard({
    super.key,
    required this.courier,
    this.canCall = true,
    this.onCall,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Photo + badge ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .5),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: courier.photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.cardDark),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.cardDark,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
              ),
              // Verified badge
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cardDark, width: 2),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 10,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // ── Info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courier.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      courier.rating.toString(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${courier.vehicle}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Action buttons ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message
              GestureDetector(
                onTap: onMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: const Icon(
                    Icons.sms_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Call
              GestureDetector(
                onTap: canCall ? onCall : null,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: canCall
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: .3),
                    shape: BoxShape.circle,
                    boxShadow: canCall
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: .3),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: const Icon(
                    Icons.call_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
