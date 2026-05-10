import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// En-tête de la page Informations personnelles.
///
/// Design Stitch (home_2) :
/// - Sticky, bg-backgroundDark/90, backdrop-blur-md, border-b white/5
/// - Bouton retour (arrow_back_ios_new) à gauche
/// - Titre centré : "Informations personnelles"
class ProfileDetailsHeader extends StatelessWidget {
  final VoidCallback onBack;

  const ProfileDetailsHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 16,
            left: 8,
            right: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: .9),
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              // Bouton retour
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),

              // Titre centré
              const Expanded(
                child: Text(
                  'Informations personnelles',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Spacer pour centrer le titre
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}
