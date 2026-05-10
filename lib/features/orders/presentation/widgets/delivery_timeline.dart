import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/delivery_step.dart';
import 'timeline_step_widget.dart';

/// Timeline verticale des étapes de livraison.
///
/// Carte arrondie bg-cardDark contenant la liste des [TimelineStepWidget].
class DeliveryTimeline extends StatelessWidget {
  final List<DeliveryStep> steps;

  const DeliveryTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          return TimelineStepWidget(
            step: steps[index],
            isLast: index == steps.length - 1,
          );
        }),
      ),
    );
  }
}
