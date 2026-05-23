import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../shared/domain/entities/product.dart';

/// Card produit pour l'écran d'accueil.
///
/// Design Stitch fidèle :
/// - Carousel d'images avec indicateurs
/// - Bouton favori top-right
/// - Titre, description, prix en vert
/// - Bouton "Ajouter au panier" pleine largeur
class HomeProductCard extends StatefulWidget {
  final Product product;

  const HomeProductCard({
    super.key,
    required this.product,
  });

  @override
  State<HomeProductCard> createState() => _HomeProductCardState();
}

class _HomeProductCardState extends State<HomeProductCard> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image carousel ──
          _buildImageCarousel(),

          // ── Informations produit ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre + Prix
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre + Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.product.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Prix
                    Text(
                      FormatUtils.formatPrice(widget.product.price),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Bouton "Ajouter au panier"
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CartBloc>().add(
                        AddProductToCart(
                          product: widget.product,
                          quantity: 1,
                          preparationOption:
                              widget.product.preparationOptions.isNotEmpty
                                  ? widget.product.preparationOptions.first
                                  : '',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${widget.product.name} ajouté au panier',
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_shopping_cart, size: 18),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Ajouter au panier',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Carousel d'images avec indicateurs et bouton favori.
  Widget _buildImageCarousel() {
    final images = widget.product.images;

    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          // PageView images (or placeholder when none)
          if (images.isEmpty)
            GestureDetector(
              onTap: () => context.push('/details', extra: widget.product),
              child: Container(
                width: double.infinity,
                height: 180,
                color: AppColors.backgroundDark,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textGrey,
                  size: 48,
                ),
              ),
            )
          else
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => context.push('/details', extra: widget.product),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.backgroundDark,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.backgroundDark,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textGrey,
                        size: 48,
                      ),
                    ),
                  ),
                );
              },
            ),

          // Indicateurs de page
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentImageIndex
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

          // Bouton favori
          Positioned(
            top: 16,
            right: 16,
            child: BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, favState) {
                final isFavorite = favState is FavoritesLoaded &&
                    favState.favorites.any((f) => f.id == widget.product.id);
                return GestureDetector(
                  onTap: () => context.read<FavoritesBloc>().add(
                    FavoritesToggleRequested(widget.product),
                  ),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? AppColors.accentRed
                          : AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
