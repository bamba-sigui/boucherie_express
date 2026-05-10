import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment_method.dart';

/// Couleurs par provider (design Stitch home_14).
const _waveBlue = Color(0xFF1DA1F2);
const _orangeBrand = Color(0xFFFF7900);
const _mtnYellow = Color(0xFFFFCC00);

/// Carte wallet mobile (Wave, Orange Money, MTN MoMo).
///
/// Design Stitch (home_14) :
/// - bg-cardDark, rounded-2xl, border white/5, p-4
/// - Logo custom à gauche (couleur provider), nom + statut
/// - Connecté : check_circle primary à droite
/// - Non configuré : bouton "AJOUTER" primary à droite, opacity-80
class WalletCard extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback onTap;

  const WalletCard({
    super.key,
    required this.method,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = method.status == PaymentMethodStatus.connected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isConnected ? 1.0 : 0.8,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              // Logo provider
              _buildProviderLogo(),
              const SizedBox(width: 16),

              // Nom + statut
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.providerName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isConnected
                          ? 'Connecté • ${method.maskedPhone}'
                          : 'Non configuré',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Action
              if (isConnected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 24,
                )
              else
                Text(
                  'AJOUTER',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderLogo() {
    switch (method.type) {
      case PaymentMethodType.wave:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _waveBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'W',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );

      case PaymentMethodType.orangeMoney:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _orangeBrand,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'OM',
                  style: TextStyle(
                    color: _orangeBrand,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );

      case PaymentMethodType.momo:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _mtnYellow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'MTN',
                  style: TextStyle(
                    color: _mtnYellow,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        );

      default:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.textSecondary,
            size: 24,
          ),
        );
    }
  }
}
