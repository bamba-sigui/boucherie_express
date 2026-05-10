import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Grille de sélection des catégories (2 colonnes).
///
/// Design : sélectionné → rouge vif (#E32626), non sélectionné → gris foncé.
/// Border radius important, animation de sélection.
class FilterCategoryGrid extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const FilterCategoryGrid({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<_CategoryItem> _categories = [
    _CategoryItem(id: 'poulet', name: 'Poulet', icon: '🐔'),
    _CategoryItem(id: 'poisson', name: 'Poisson', icon: '🐟'),
    _CategoryItem(id: 'boeuf', name: 'Bœuf', icon: '🐄'),
    _CategoryItem(id: 'mouton', name: 'Mouton', icon: '🐑'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catégories',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Grille 2 colonnes
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = selectedCategory == category.id;

              return GestureDetector(
                onTap: () => onCategorySelected(category.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE32626)
                        : AppColors.categoryUnselected,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(
                            color: const Color(
                              0xFFE32626,
                            ).withValues(alpha: 0.5),
                            width: 1.5,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFE32626,
                              ).withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final String id;
  final String name;
  final String icon;

  const _CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
  });
}
