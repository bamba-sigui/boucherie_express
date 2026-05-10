import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Footer du bottom sheet de filtres.
///
/// Contient deux boutons :
/// - "Réinitialiser" : texte simple
/// - "Appliquer les filtres" : bouton plein rouge large
class FilterFooter extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onApply;
  final bool isFilterActive;

  const FilterFooter({
    super.key,
    required this.onReset,
    required this.onApply,
    this.isFilterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 12),
      child: Row(
        children: [
          // ── Bouton Réinitialiser ──
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: onReset,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.categoryUnselected,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Réinitialiser',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Bouton Appliquer ──
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: onApply,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE32626),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE32626).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Appliquer les filtres',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
