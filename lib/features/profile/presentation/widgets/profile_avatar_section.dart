import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Section avatar de la page Informations personnelles.
///
/// Design Stitch (home_2) :
/// - Avatar size-28 circle, bg-primary/10, border-4 card-dark, shadow-xl
/// - Icône account_circle primary, taille 6xl
/// - Bouton photo_camera en bas à droite : bg-primary, text-backgroundDark
/// - Légende : "PHOTO DE PROFIL" en uppercase tracking-widest slate-400
class ProfileAvatarSection extends StatelessWidget {
  final String? photoUrl;
  final VoidCallback onChangePhoto;

  const ProfileAvatarSection({
    super.key,
    this.photoUrl,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar avec bouton caméra
        GestureDetector(
          onTap: onChangePhoto,
          child: SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              children: [
                // Cercle avatar
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cardDark, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: photoUrl != null && photoUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.account_circle_rounded,
                              color: AppColors.primary,
                              size: 64,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.account_circle_rounded,
                          color: AppColors.primary,
                          size: 64,
                        ),
                ),

                // Bouton caméra
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.backgroundDark,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: AppColors.backgroundDark,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Légende
        Text(
          'PHOTO DE PROFIL',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }
}
