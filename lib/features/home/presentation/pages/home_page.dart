import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/domain/entities/product.dart';
import '../bloc/home_bloc.dart';
import '../widgets/category_selector.dart';
import '../widgets/home_header.dart';
import '../widgets/home_product_card.dart';
import '../widgets/search_bar_widget.dart';

/// Page d'accueil de l'application BoucherieExpress.
///
/// Contient : Header, barre de recherche, catégories horizontales,
/// liste verticale de produits avec carousel d'images.
/// Fidèle au design Stitch boucherie_express_home_3.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late final HomeBloc _homeBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _homeBloc = getIt<HomeBloc>()..add(const HomeLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _homeBloc.close();
    super.dispose();
  }

  /// Rafraîchir les favoris depuis la source de données.
  void refreshFavorites() {
    _homeBloc.add(const HomeFavoritesRefreshRequested());
  }

  /// Recharger les produits et catégories depuis l'API.
  /// Skip si les données sont déjà en mémoire (état HomeLoaded).
  void reloadProducts() {
    if (_homeBloc.state is! HomeLoaded) {
      _homeBloc.add(const HomeLoadRequested());
    }
  }

  /// Appliquer les produits filtrés depuis le FilterBottomSheet.
  void applyFilteredProducts(List<Product> products) {
    _homeBloc.add(HomeFilterApplied(products));
  }

  /// Réinitialiser les filtres et recharger tous les produits.
  void resetFilter() {
    _homeBloc.add(const HomeFilterReset());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Header ──
              const HomeHeader(),

              // ── Contenu scrollable ──
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    if (state is HomeError) {
                      return _buildErrorState(context, state.message);
                    }

                    if (state is HomeLoaded) {
                      return _buildLoadedContent(context, state);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, HomeLoaded state) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundDark,
      onRefresh: () async {
        _homeBloc.add(const HomeLoadRequested());
        // Attendre que le bloc émette un nouvel état (loaded ou error)
        await _homeBloc.stream.firstWhere(
          (s) => s is HomeLoaded || s is HomeError,
        );
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Barre de recherche ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: SearchBarWidget(
                controller: _searchController,
                onChanged: (query) {
                  if (query.isEmpty) {
                    context.read<HomeBloc>().add(const HomeSearchCleared());
                  } else {
                    context.read<HomeBloc>().add(HomeSearchRequested(query));
                  }
                  setState(() {}); // Refresh pour icône clear
                },
                onClear: () {
                  context.read<HomeBloc>().add(const HomeSearchCleared());
                  setState(() {});
                },
              ),
            ),
          ),

          // ── Catégories horizontales ──
          if (!state.isSearching)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: CategorySelector(
                  categories: state.categories,
                  selectedCategoryId: state.selectedCategoryId,
                  onCategorySelected: (categoryId) {
                    context.read<HomeBloc>().add(
                      HomeCategorySelected(categoryId),
                    );
                  },
                ),
              ),
            ),

          // ── Espacement ──
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Liste de produits ──
          if (state.products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, color: Colors.grey.shade600, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      state.isSearching
                          ? 'Aucun résultat pour "${state.searchQuery}"'
                          : 'Aucun produit disponible',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.separated(
                itemCount: state.products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return HomeProductCard(
                    product: product,
                    isFavorite: state.favoriteIds.contains(product.id),
                  );
                },
              ),
            ),

          // ── Espacement bas pour la bottom nav ──
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<HomeBloc>().add(const HomeLoadRequested());
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
