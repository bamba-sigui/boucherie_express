import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Carte profil utilisateur.
///
/// Design Stitch (home_13) :
/// - bg-card-dark, rounded-2xl, border white/5, p-4
/// - Avatar size-16 rounded-full bg-primary/20 border-2 primary/30
///   contenant icône person primary
/// - Nom font-bold text-xl blanc
/// - Téléphone text-sm slate-400
class UserInfoCard extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback? onEdit;

  const UserInfoCard({
    super.key,
    required this.name,
    required this.phone,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: .3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Edit button (optional)
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
