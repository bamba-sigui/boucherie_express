import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Image de fond statique (carte/map preview) avec overlay gradient,
/// icône animée au centre et badge ETA.
///
/// Design Stitch :
/// - 380px height, bg-cover, brightness=0.7
/// - Gradient top→transparent + transparent→bottom
/// - Icône `motorcycle` dans cercle primary avec glow + ping anim
/// - Badge bottom : « Koffi arrive dans 8 min »
class EstimatedArrivalCard extends StatelessWidget {
  final String? mapImageUrl;
  final String etaBannerMessage;
  final bool isDelivered;

  const EstimatedArrivalCard({
    super.key,
    this.mapImageUrl,
    required this.etaBannerMessage,
    this.isDelivered = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      width: double.infinity,
      child: Stack(
        children: [
          // ── Background image ──
          if (mapImageUrl != null)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: mapImageUrl!,
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: .35),
                colorBlendMode: BlendMode.darken,
                placeholder: (_, __) => Container(color: AppColors.cardDark),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.cardDark),
              ),
            )
          else
            Container(color: AppColors.cardDark),

          // ── Gradient top ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 96,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDark,
                    AppColors.backgroundDark.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // ── Gradient bottom ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 128,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.backgroundDark,
                    AppColors.backgroundDark.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // ── Center icon + badge ──
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing motorcycle icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .6),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isDelivered
                        ? Icons.check_rounded
                        : Icons.motorcycle_rounded,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),

                // ETA badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .8),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: AppColors.surface,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        etaBannerMessage,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
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
