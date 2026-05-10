import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment_method.dart';
import 'payment_option_card.dart';

/// Section mode de paiement avec titre, badge SÉCURISÉ, et liste de cartes.
class PaymentMethodSelector extends StatelessWidget {
  final List<PaymentMethod> methods;
  final PaymentMethod? selectedMethod;
  final ValueChanged<PaymentMethod> onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.methods,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header : title + badge ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mode de paiement',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'SÉCURISÉ',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Payment cards list ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: methods.map((method) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PaymentOptionCard(
                  method: method,
                  isSelected: selectedMethod?.id == method.id,
                  onTap: () => onMethodSelected(method),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
