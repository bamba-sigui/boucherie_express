import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';

/// Progress bar toward free delivery.
///
/// Shows:
/// - "LIVRAISON GRATUITE" label (primary)
/// - Dynamic text: "Encore X FCFA" or "Livraison offerte !"
/// - Animated progress bar
class FreeDeliveryProgress extends StatelessWidget {
  /// Value between 0.0 and 1.0 representing progress.
  final double progress;

  /// Remaining amount to reach free delivery threshold.
  final double remaining;

  /// Whether free delivery has been achieved.
  final bool hasFreeDelivery;

  const FreeDeliveryProgress({
    super.key,
    required this.progress,
    required this.remaining,
    required this.hasFreeDelivery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Labels row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'LIVRAISON GRATUITE',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            if (hasFreeDelivery)
              const Text(
                'Livraison offerte !',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text.rich(
                TextSpan(
                  text: 'Encore ',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: FormatUtils.formatPrice(remaining),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            height: 8,
            width: double.infinity,
            child: Stack(
              children: [
                // Background
                Container(color: AppColors.border),
                // Fill
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A [FractionallySizedBox] that animates its [widthFactor].
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final AlignmentGeometry alignment;
  final double widthFactor;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    super.curve,
    required this.alignment,
    required this.widthFactor,
    required this.child,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor =
        visitor(
              _widthFactor,
              widget.widthFactor,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: widget.alignment,
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      child: widget.child,
    );
  }
}
