import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Bottom Navigation Bar custom fidèle au design Stitch.
///
/// 5 items : Accueil, Favoris, FILTRER (FAB central vert avec glow), Commandes, Profil.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isFilterEnabled;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isFilterEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: bottomPadding + 8,
        left: 8,
        right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            iconOutlined: Icons.home_outlined,
            label: 'Accueil',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.favorite,
            iconOutlined: Icons.favorite_border,
            label: 'Favoris',
            index: 1,
          ),
          _buildCenterButton(isFilterEnabled),
          _buildNavItem(
            icon: Icons.receipt_long,
            iconOutlined: Icons.receipt_long_outlined,
            label: 'Commandes',
            index: 3,
          ),
          _buildNavItem(
            icon: Icons.person,
            iconOutlined: Icons.person_outline,
            label: 'Profil',
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData iconOutlined,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? icon : iconOutlined,
              color: isActive ? AppColors.primary : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : Colors.grey.shade600,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bouton central "FILTRER" avec glow vert.
  /// Désactivé visuellement quand [enabled] est false.
  Widget _buildCenterButton(bool enabled) {
    return GestureDetector(
      onTap: enabled ? () => onTap(2) : null,
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary : Colors.grey.shade700,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.backgroundDark, width: 4),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.tune,
                color: enabled
                    ? AppColors.backgroundDark
                    : Colors.grey.shade500,
                size: 24,
              ),
              Text(
                'FILTRER',
                style: TextStyle(
                  color: enabled
                      ? AppColors.backgroundDark
                      : Colors.grey.shade500,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
