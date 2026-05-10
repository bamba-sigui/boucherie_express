import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Section d'actions sticky en bas de la page détails commande.
///
/// Design Stitch (boucherie_express_home_5) :
/// - Bouton 1 : « Suivre la commande » — brand-red, blanc, icône map, shadow
///   active:scale-95, transition-transform
/// - Bouton 2 : « Contacter le support » — bg-white/5, blanc, icône support_agent
///   active:bg-white/10, transition-colors
/// - space-y-3, pb-8
class OrderActionsSection extends StatelessWidget {
  final VoidCallback? onTrackOrder;
  final VoidCallback? onContactSupport;

  const OrderActionsSection({
    super.key,
    this.onTrackOrder,
    this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Bouton 1 : Suivre la commande ──
        _TrackOrderButton(onTap: onTrackOrder),
        const SizedBox(height: 12),

        // ── Bouton 2 : Contacter le support ──
        _ContactSupportButton(onTap: onContactSupport),
      ],
    );
  }
}

class _TrackOrderButton extends StatefulWidget {
  final VoidCallback? onTap;

  const _TrackOrderButton({this.onTap});

  @override
  State<_TrackOrderButton> createState() => _TrackOrderButtonState();
}

class _TrackOrderButtonState extends State<_TrackOrderButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accentRed,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentRed.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Suivre la commande',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactSupportButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ContactSupportButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.support_agent, color: AppColors.textPrimary, size: 22),
              SizedBox(width: 8),
              Text(
                'Contacter le support',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
