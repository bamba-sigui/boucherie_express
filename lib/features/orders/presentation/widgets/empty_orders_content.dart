import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget d'état vide pour la page Mes Commandes.
///
/// Design Stitch pixel-perfect (boucherie_express_home_1) :
/// - Grand cercle (192px) gris anthracite avec icône `shopping_bag` (100px, slate-700)
/// - Badge rouge circulaire (56px) en bas à droite avec icône `history_toggle_off`
///   Le badge a une bordure de 4px couleur backgroundDark
/// - Titre « Historique vide » — 2xl, bold
/// - Description — slate-400, base, leading-relaxed, max-w-280px
/// - CTA rouge « Commander maintenant » — brand-red, rounded-xl, shadow
///
/// Aucune logique métier — n'accepte qu'un callback [onCommanderMaintenant].
class EmptyOrdersContent extends StatefulWidget {
  /// Action déclenchée par le bouton CTA.
  final VoidCallback? onCommanderMaintenant;

  const EmptyOrdersContent({super.key, this.onCommanderMaintenant});

  @override
  State<EmptyOrdersContent> createState() => _EmptyOrdersContentState();
}

class _EmptyOrdersContentState extends State<EmptyOrdersContent>
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
                  'Historique vide',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // ── Description ──
                SizedBox(
                  width: 280,
                  child: Text(
                    'Vous n\'avez encore passé aucune commande chez Boucherie Express.',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
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

  /// Illustration : cercle anthracite + sac de courses + badge rouge horloge.
  Widget _buildIllustration() {
    const double circleSize = 192;
    const double badgeSize = 56;

    return SizedBox(
      width: circleSize + 16, // espace pour le badge qui dépasse
      height: circleSize + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Cercle principal ──
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_bag,
                size: 100,
                color: Color(0xFF334155), // slate-700
              ),
            ),
          ),

          // ── Badge rouge (bas droite) ──
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.backgroundDark, width: 4),
              ),
              child: const Center(
                child: Icon(
                  Icons.history_toggle_off,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton CTA rouge « Commander maintenant ».
  Widget _buildCtaButton() {
    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onCommanderMaintenant,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC62828).withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Commander maintenant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
