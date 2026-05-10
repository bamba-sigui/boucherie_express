import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// "À propos" card + "Conseil de préparation" card.
///
/// Design spec:
/// - About card: bg-cardDark, rounded-2xl, border white/5
/// - Advice card: bg-primary/5, rounded-2xl, border primary/10
class ProductInfoCards extends StatelessWidget {
  final String description;
  final String? preparationAdvice;

  const ProductInfoCards({
    super.key,
    required this.description,
    this.preparationAdvice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── About card ──
        _InfoCard(
          title: 'À propos',
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.textSecondary,
          backgroundColor: AppColors.cardDark,
          borderColor: AppColors.border,
          titleColor: AppColors.textPrimary,
          child: Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),

        // ── Preparation advice card ──
        if (preparationAdvice != null && preparationAdvice!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Conseil de préparation',
            icon: Icons.restaurant_outlined,
            iconColor: AppColors.primary,
            backgroundColor: AppColors.primary.withValues(alpha: .05),
            borderColor: AppColors.primary.withValues(alpha: .1),
            titleColor: AppColors.primary,
            child: Text(
              preparationAdvice!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
