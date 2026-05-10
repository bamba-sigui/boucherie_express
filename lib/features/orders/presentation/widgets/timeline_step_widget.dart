import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/delivery_status.dart';
import '../../domain/entities/delivery_step.dart';

/// Un pas individuel de la timeline.
///
/// Design Stitch :
/// - Completed : cercle bg-primary, icône check noir, texte white/40
/// - Active    : cercle bg-primary + glow, texte blanc, badge « Active »
/// - Pending   : cercle border-white/10, icône white/20, texte white/20
class TimelineStepWidget extends StatelessWidget {
  final DeliveryStep step;
  final bool isLast;

  const TimelineStepWidget({
    super.key,
    required this.step,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left column : icon + line ──
        Column(children: [_buildIcon(), if (!isLast) _buildLine()]),
        const SizedBox(width: 16),

        // ── Right column : text ──
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2, bottom: isLast ? 0 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row (with optional badge)
                Row(
                  children: [
                    Text(
                      step.label,
                      style: TextStyle(
                        color: _titleColor,
                        fontSize: step.isActive ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (step.isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Subtitle
                if (step.subtitle != null || step.completedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _subtitleText,
                    style: TextStyle(
                      color: _subtitleColor,
                      fontSize: step.isActive ? 14 : 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Icon ───────────────────────────────────────────────────────────────

  Widget _buildIcon() {
    switch (step.status) {
      case DeliveryStatus.completed:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.black, size: 18),
        );

      case DeliveryStatus.active:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .5),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            color: Colors.black,
            size: 18,
          ),
        );

      case DeliveryStatus.pending:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.home_rounded,
            color: AppColors.surface,
            size: 18,
          ),
        );
    }
  }

  // ── Line ───────────────────────────────────────────────────────────────

  Widget _buildLine() {
    final isGreen =
        step.status == DeliveryStatus.completed ||
        step.status == DeliveryStatus.active;

    return Container(
      width: 2,
      height: 48,
      color: isGreen ? AppColors.primary : AppColors.border,
    );
  }

  // ── Colors & text helpers ──────────────────────────────────────────────

  Color get _titleColor {
    switch (step.status) {
      case DeliveryStatus.completed:
        return AppColors.textSecondary;
      case DeliveryStatus.active:
        return AppColors.textPrimary;
      case DeliveryStatus.pending:
        return AppColors.surface;
    }
  }

  Color get _subtitleColor {
    switch (step.status) {
      case DeliveryStatus.completed:
        return AppColors.surface;
      case DeliveryStatus.active:
        return AppColors.textSecondary;
      case DeliveryStatus.pending:
        return AppColors.border;
    }
  }

  String get _subtitleText {
    if (step.isCompleted && step.completedAt != null) {
      final h = step.completedAt!.hour.toString().padLeft(2, '0');
      final m = step.completedAt!.minute.toString().padLeft(2, '0');
      return 'Terminé à $h:$m';
    }
    return step.subtitle ?? '';
  }
}
