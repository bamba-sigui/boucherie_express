import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Header du suivi de commande.
///
/// Design Stitch :
/// - Sticky, bg-backgroundDark/60, backdrop-blur, border-b white/5
/// - Bouton retour (circle bg-cardDark border-white/5)
/// - Centre : « SUIVI EN DIRECT » uppercase tracking-widest primary
///            + « Commande #XX » white/60
/// - Bouton more_horiz à droite
class TrackingHeader extends StatelessWidget {
  final String orderId;
  final VoidCallback? onBack;

  const TrackingHeader({super.key, required this.orderId, this.onBack});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 24,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: .6),
          ),
          child: Row(
            children: [
              // Back
              GestureDetector(
                onTap: onBack ?? () => Navigator.maybePop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
              ),

              // Center
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'SUIVI EN DIRECT',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Commande #$orderId',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // More
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
