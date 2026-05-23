import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/auth_gate.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/favorites_bloc.dart';
import '../widgets/empty_favorites_content.dart';
import '../widgets/favorite_product_card.dart';
import '../widgets/favorites_header.dart';

/// Page Favoris de l'application BoucherieExpress.
///
/// Affiche les produits favoris avec le même style que Home.
/// Gère l'état vide avec un message d'incitation.
/// Les favoris sont synchronisés avec la feature Home via la source
/// de données partagée [HomeLocalDataSource].
class FavoritesPage extends StatefulWidget {
  /// Callback optionnel pour naviguer vers l'onglet Home.
  final VoidCallback? onNavigateToHome;

  const FavoritesPage({super.key, this.onNavigateToHome});

  @override
  State<FavoritesPage> createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<FavoritesBloc>().add(const FavoritesLoadRequested());
      }
    }
  }

  /// Recharge les favoris (appelé quand l'onglet devient visible).
  void reload() {
    context.read<FavoritesBloc>().add(const FavoritesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return AuthGate(
        icon: Icons.favorite_outline_rounded,
        title: 'Connectez-vous',
        subtitle: 'Connectez-vous pour voir vos favoris.',
        child: Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Header ──
                const FavoritesHeader(),

                // ── Contenu ──
                Expanded(
                  child: BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (context, state) {
                      if (state is FavoritesLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        );
                      }

                      if (state is FavoritesError) {
                        return _buildErrorState(context, state.message);
                      }

                      if (state is FavoritesLoaded) {
                        if (state.favorites.isEmpty) {
                          return _buildEmptyState(context);
                        }
                        return _buildFavoritesList(context, state);
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

  Future<void> _onRefresh(BuildContext context) async {
    context.read<FavoritesBloc>().add(const FavoritesLoadRequested());
  }

  /// Liste des produits favoris.
  Widget _buildFavoritesList(BuildContext context, FavoritesLoaded state) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      color: AppColors.primary,
      backgroundColor: AppColors.cardDark,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: state.favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = state.favorites[index];
                return FavoriteProductCard(product: product);
              },
            ),
          ),

          // Espacement bas pour la bottom nav
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  /// État vide : aucun favori — délègue au widget dédié.
  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      color: AppColors.primary,
      backgroundColor: AppColors.cardDark,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyFavoritesContent(
              onDiscoverProducts: widget.onNavigateToHome,
            ),
          ),
        ],
      ),
    );
  }

  /// État d'erreur avec bouton réessayer.
  Widget _buildErrorState(BuildContext context, String message) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      color: AppColors.primary,
      backgroundColor: AppColors.cardDark,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _onRefresh(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
