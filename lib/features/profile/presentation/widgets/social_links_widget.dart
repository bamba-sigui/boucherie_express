import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Bloc réseaux sociaux — design Stitch home_17.
///
/// Affiche "Suivez-nous sur nos réseaux" avec des boutons circulaires
/// pour Facebook, Instagram et Partage.
class SocialLinksWidget extends StatelessWidget {
  final VoidCallback? onFacebookTap;
  final VoidCallback? onInstagramTap;
  final VoidCallback? onShareTap;

  const SocialLinksWidget({
    super.key,
    this.onFacebookTap,
    this.onInstagramTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surface,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Suivez-nous sur nos réseaux',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialButton(
                icon: Icons.facebook_rounded,
                onTap: onFacebookTap,
              ),
              const SizedBox(width: 24),
              _SocialButton(
                icon: Icons.camera_alt_outlined,
                onTap: onInstagramTap,
              ),
              const SizedBox(width: 24),
              _SocialButton(
                icon: Icons.share_rounded,
                onTap: onShareTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SocialButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: AppColors.primary.withValues(alpha: .1),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Icon(
              icon,
              color: const Color(0xFFCBD5E1), // slate-300
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
