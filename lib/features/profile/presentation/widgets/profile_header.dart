import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// En-tête sticky du profil.
///
/// Design Stitch (home_13) :
/// - Sticky, bg-backgroundDark/90, backdrop-blur-md, border-b white/5
/// - BOUCHERIE EXPRESS à gauche (font-black tracking-tighter uppercase)
/// - Panier à droite avec badge vert
class ProfileHeader extends StatelessWidget {
  final int cartItemCount;

  const ProfileHeader({super.key, this.cartItemCount = 0});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 16,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: .9),
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(text: 'BOUCHERIE '),
                    TextSpan(
                      text: 'EXPRESS',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),

              // Cart button
              GestureDetector(
                onTap: () => context.push('/cart'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                      if (cartItemCount > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                cartItemCount > 9
                                    ? '9+'
                                    : cartItemCount.toString(),
                                style: const TextStyle(
                                  color: AppColors.backgroundDark,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
