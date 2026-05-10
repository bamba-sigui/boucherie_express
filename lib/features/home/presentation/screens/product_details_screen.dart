import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../shared/domain/entities/product.dart';
import '../widgets/preparation_selector.dart';
import '../widgets/product_carousel.dart';
import '../widgets/product_info_cards.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/sticky_add_to_cart_bar.dart';

/// Premium product details page matching the Stitch design.
///
/// Layout (top → bottom):
/// 1. Full-bleed [ProductCarousel] with overlay controls
/// 2. Product info section overlapping the carousel (-48px)
///    – Farm badge, secondary text, title, price
/// 3. [PreparationSelector] – horizontal pills
/// 4. [ProductInfoCards] – about + preparation advice
/// 5. [QuantitySelector]
/// 6. Sticky [StickyAddToCartBar] at the bottom
class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  late String _selectedOption;
  int _quantity = 1;

  // ── Notification state ──
  bool _showNotification = false;
  AnimationController? _notifController;
  Animation<Offset>? _notifSlide;
  Animation<double>? _notifFade;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.product.preparationOptions.isNotEmpty
        ? widget.product.preparationOptions.first
        : '';
    _initNotifAnimations();
  }

  void _initNotifAnimations() {
    _notifController?.dispose();
    _notifController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );
    _notifSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _notifController!,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeIn,
          ),
        );
    _notifFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _notifController!, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _notifController?.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void _addToCart() {
    context.read<CartBloc>().add(
      AddProductToCart(
        product: widget.product,
        quantity: _quantity,
        preparationOption: _selectedOption,
      ),
    );

    // Show inline bottom notification
    if (_notifController == null) _initNotifAnimations();
    setState(() => _showNotification = true);
    _notifController!.forward();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showNotification) {
        _notifController?.reverse().then((_) {
          if (mounted) setState(() => _showNotification = false);
        });
      }
    });
  }

  /// Returns a contextual preparation advice based on the selected option.
  String? get _preparationAdvice {
    switch (_selectedOption.toLowerCase()) {
      case 'entier':
        return 'Idéal pour une cuisson au four. Assaisonnez généreusement et laissez reposer 30 min avant cuisson.';
      case 'découpé':
        return 'Parfait pour les sautés et ragoûts. Les morceaux sont découpés prêts à cuire.';
      case 'nettoyé':
        return 'Nettoyé et prêt à l\'emploi. Rincez légèrement avant la préparation.';
      case 'tranché':
        return 'Tranches fines idéales pour grillades ou poêle. Cuisson rapide recommandée.';
      case 'haché':
        return 'Viande hachée fraîche, parfaite pour boulettes, burgers ou sauce bolognaise.';
      case 'écaillé':
        return 'Poisson écaillé et vidé. Prêt pour cuisson au four, grillé ou braisé.';
      case 'filet':
        return 'Filet désarêté, cuisson rapide à la poêle avec un filet de citron.';
      case 'mariné':
        return 'Déjà mariné aux épices locales. Cuisson directe au gril ou au four.';
      default:
        return null;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // ── Scrollable content ──
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Carousel
                BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, state) {
                    final isFavorite =
                        state is FavoritesLoaded &&
                        state.favorites.any((f) => f.id == product.id);

                    return ProductCarousel(
                      images: product.images,
                      videoUrl: product.videoUrl,
                      isFavorite: isFavorite,
                      onBack: () => context.pop(),
                      onFavoriteToggle: () {
                        context.read<FavoritesBloc>().add(
                          FavoritesToggleRequested(product),
                        );
                      },
                    );
                  },
                ),

                // 2. Product info section (overlapping carousel)
                Transform.translate(
                  offset: const Offset(0, -48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Farm badge + freshness
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: .2,
                                  ),
                                ),
                              ),
                              child: Text(
                                product.farmName.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            if (product.isFresh) ...[
                              const SizedBox(width: 10),
                              Text(
                                'Récolté aujourd\'hui',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Title
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Description subtitle
                        Text(
                          product.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Price row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              FormatUtils.formatPrice(product.price),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                            if (product.hasDiscount) ...[
                              const SizedBox(width: 10),
                              Text(
                                FormatUtils.formatPrice(product.oldPrice!),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            const SizedBox(width: 6),
                            Text(
                              '/ ${product.unit}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // 3. Preparation selector
                        if (product.preparationOptions.length > 1) ...[
                          PreparationSelector(
                            options: product.preparationOptions,
                            selected: _selectedOption,
                            onChanged: (option) {
                              setState(() => _selectedOption = option);
                            },
                          ),
                          const SizedBox(height: 28),
                        ],

                        // 4. Info cards
                        ProductInfoCards(
                          description: product.description,
                          preparationAdvice: _preparationAdvice,
                        ),
                        const SizedBox(height: 28),

                        // 5. Quantity selector
                        QuantitySelector(
                          quantity: _quantity,
                          max: product.stock > 0 ? product.stock : 99,
                          onChanged: (q) => setState(() => _quantity = q),
                        ),

                        // Bottom spacer for sticky bar
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 6. Sticky bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StickyAddToCartBar(
                  unitPrice: product.price,
                  quantity: _quantity,
                  onAddToCart: _addToCart,
                ),
                // 7. Inline notification below the button
                if (_showNotification &&
                    _notifSlide != null &&
                    _notifFade != null)
                  SlideTransition(
                    position: _notifSlide!,
                    child: FadeTransition(
                      opacity: _notifFade!,
                      child: _CartAddedBanner(
                        productName: product.name,
                        quantity: _quantity,
                        onViewCart: () => context.push('/cart'),
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
}

// ═══════════════════════════════════════════════════════════════════════════
// INLINE ADD-TO-CART NOTIFICATION BANNER
// ═══════════════════════════════════════════════════════════════════════════

class _CartAddedBanner extends StatelessWidget {
  final String productName;
  final int quantity;
  final VoidCallback onViewCart;

  const _CartAddedBanner({
    required this.productName,
    required this.quantity,
    required this.onViewCart,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 20,
        right: 14,
        top: 12,
        bottom: 12 + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: Border(
          top: BorderSide(color: AppColors.primary.withValues(alpha: .12)),
        ),
      ),
      child: Row(
        children: [
          // Check icon
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),

          // Text
          Expanded(
            child: Text(
              '$productName × $quantity ajouté',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),

          // View cart pill
          GestureDetector(
            onTap: onViewCart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: .2),
                ),
              ),
              child: const Text(
                'VOIR',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
