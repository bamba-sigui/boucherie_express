import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget d'état vide pour la page Favoris.
///
/// Design Stitch pixel-perfect (boucherie_express_home_7) :
/// - Grand cercle gris foncé avec icône panier + cœur rouge
/// - Éléments décoratifs (set_meal + restaurant) en opacité très faible
/// - Particules glow (vert en haut, rouge en bas)
/// - Titre "Aucun produit en favori"
/// - Description grise centrée
/// - CTA rouge "Découvrir les produits →" (pill shape)
///
/// Aucune logique métier — n'accepte qu'un callback [onDiscoverProducts].
class EmptyFavoritesContent extends StatefulWidget {
  /// Action déclenchée par le bouton CTA.
  final VoidCallback? onDiscoverProducts;

  const EmptyFavoritesContent({super.key, this.onDiscoverProducts});

  @override
  State<EmptyFavoritesContent> createState() => _EmptyFavoritesContentState();
}

class _EmptyFavoritesContentState extends State<EmptyFavoritesContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Illustration ──
                _buildIllustration(),

                const SizedBox(height: 32),

                // ── Titre ──
                const Text(
                  'Aucun produit en favori',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // ── Description ──
                SizedBox(
                  width: 240,
                  child: Text(
                    'Ajoutez vos produits préférés pour les retrouver plus facilement lors de vos prochaines commandes.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // ── Bouton CTA ──
                _buildCtaButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Illustration : cercle avec panier + cœur rouge + éléments décoratifs.
  Widget _buildIllustration() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow vert (coin haut droite)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Glow rouge (coin bas gauche)
          Positioned(
            bottom: -4,
            left: -4,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ── Cercle principal ──
          Container(
            width: 192,
            height: 192,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Élément décoratif : set_meal (haut droite)
                Positioned(
                  top: 16,
                  right: 32,
                  child: Transform.rotate(
                    angle: 0.21, // ~12 degrés
                    child: Icon(
                      Icons.set_meal,
                      size: 36,
                      color: AppColors.textSecondary.withValues(alpha: 0.15),
                    ),
                  ),
                ),

                // Élément décoratif : restaurant (bas gauche)
                Positioned(
                  bottom: 40,
                  left: 16,
                  child: Transform.rotate(
                    angle: -0.21, // ~-12 degrés
                    child: Icon(
                      Icons.restaurant,
                      size: 36,
                      color: AppColors.textSecondary.withValues(alpha: 0.15),
                    ),
                  ),
                ),

                // Icône panier (grande, semi-transparente)
                Icon(
                  Icons.shopping_basket,
                  size: 96,
                  color: AppColors.textSecondary.withValues(alpha: 0.15),
                ),

                // Cœur rouge (centré sur le panier)
                Icon(
                  Icons.favorite,
                  size: 48,
                  color: AppColors.accentRed.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton CTA rouge "Découvrir les produits →".
  Widget _buildCtaButton() {
    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onDiscoverProducts,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.transparent,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE32626),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE32626).withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Découvrir les produits',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
