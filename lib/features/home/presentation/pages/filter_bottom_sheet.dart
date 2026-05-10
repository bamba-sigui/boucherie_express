import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product_filter.dart';
import '../bloc/filter_bloc.dart';
import '../widgets/filter_availability_toggle.dart';
import '../widgets/filter_category_grid.dart';
import '../widgets/filter_footer.dart';
import '../widgets/filter_header.dart';
import '../widgets/filter_price_slider.dart';

/// Bottom sheet modal de filtrage des produits.
///
/// Slide up animé avec backdrop blur.
/// Contient : catégories, prix range slider, disponibilité, boutons.
///
/// Retourne les produits filtrés via [Navigator.pop] quand "Appliquer" est pressé.
/// Retourne `'reset'` quand "Réinitialiser" est pressé.
class FilterBottomSheet extends StatelessWidget {
  /// Filtre actuel à pré-remplir dans le formulaire.
  final ProductFilter? initialFilter;

  const FilterBottomSheet({super.key, this.initialFilter});

  /// Affiche le bottom sheet avec les animations appropriées.
  static Future<dynamic> show(
    BuildContext context, {
    ProductFilter? currentFilter,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => FilterBottomSheet(initialFilter: currentFilter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<FilterBloc>();
        // Pré-remplir avec le filtre actuel s'il existe.
        if (initialFilter != null && initialFilter!.isActive) {
          if (initialFilter!.category != null) {
            bloc.add(FilterCategoryChanged(initialFilter!.category));
          }
          if (initialFilter!.minPrice > 0 || initialFilter!.maxPrice < 15000) {
            bloc.add(
              FilterPriceRangeChanged(
                minPrice: initialFilter!.minPrice,
                maxPrice: initialFilter!.maxPrice,
              ),
            );
          }
          if (initialFilter!.inStock) {
            bloc.add(const FilterInStockToggled(true));
          }
        }
        return bloc;
      },
      child: _FilterBottomSheetContent(initialFilter: initialFilter),
    );
  }
}

class _FilterBottomSheetContent extends StatelessWidget {
  final ProductFilter? initialFilter;

  const _FilterBottomSheetContent({this.initialFilter});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: BlocConsumer<FilterBloc, FilterState>(
        listener: (context, state) {
          if (state is FilterApplied) {
            Navigator.of(context).pop(state.filteredProducts);
          } else if (state is FilterReset) {
            Navigator.of(context).pop('reset');
          }
        },
        builder: (context, state) {
          final filter = _resolveCurrentFilter(state);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header ──
                    FilterHeader(onClose: () => Navigator.of(context).pop()),

                    // ── Catégories (grille 2 colonnes) ──
                    FilterCategoryGrid(
                      selectedCategory: filter.category,
                      onCategorySelected: (category) {
                        context.read<FilterBloc>().add(
                          FilterCategoryChanged(category),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Prix (range slider) ──
                    FilterPriceSlider(
                      minPrice: filter.minPrice,
                      maxPrice: filter.maxPrice,
                      onChanged: (range) {
                        context.read<FilterBloc>().add(
                          FilterPriceRangeChanged(
                            minPrice: range.start,
                            maxPrice: range.end,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Disponibilité ──
                    FilterAvailabilityToggle(
                      inStock: filter.inStock,
                      onChanged: (value) {
                        context.read<FilterBloc>().add(
                          FilterInStockToggled(value),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Footer (Réinitialiser + Appliquer) ──
                    FilterFooter(
                      isFilterActive: filter.isActive,
                      onReset: () {
                        context.read<FilterBloc>().add(
                          const FilterResetRequested(),
                        );
                      },
                      onApply: () {
                        context.read<FilterBloc>().add(
                          const FilterApplyRequested(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Résout le filtre actuel selon l'état du BLoC.
  ProductFilter _resolveCurrentFilter(FilterState state) {
    if (state is FilterEditing) return state.currentFilter;
    return initialFilter ?? ProductFilter.defaultFilter;
  }
}
