import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order.dart';

/// Carte du mode de paiement dans la page détails commande.
///
/// Design Stitch (boucherie_express_home_5) :
/// - Background cardDark, rounded-2xl, border white/5
/// - Icône payments (slate-400, text-sm)
/// - Label "MODE DE PAIEMENT" (slate-400, xs, bold, uppercase, tracking-wider)
/// - Badge logo (w-10, h-6, slate-800, rounded, border white/10, text "Mobile" en uppercase 8px bold)
/// - Nom du service (text-sm, font-medium)
class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;

  const PaymentMethodCard({super.key, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    final (String label, String badge) = _paymentData(paymentMethod);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label ──
          Row(
            children: [
              Icon(Icons.payments, color: Colors.grey.shade500, size: 16),
              const SizedBox(width: 8),
              Text(
                'MODE DE PAIEMENT',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Badge + Nom ──
          Row(
            children: [
              // Badge logo
              Container(
                width: 40,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.surface,
                  ),
                ),
                child: Center(
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nom service
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (String, String) _paymentData(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => ('Paiement à la livraison', 'CASH'),
      PaymentMethod.orangeMoney => ('Orange Money', 'MOBILE'),
      PaymentMethod.moovMoney => ('Moov Money', 'MOBILE'),
    };
  }
}
