import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment_method.dart';
import '../bloc/payment_methods_bloc.dart';
import '../widgets/cash_payment_card.dart';
import '../widgets/empty_cards_widget.dart';
import '../widgets/wallet_card.dart';

/// Écran "Moyens de paiement" — design Stitch (home_14).
///
/// Sections : Wallets Mobiles, Options de livraison, Cartes Bancaires.
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaymentMethodsBloc>()..add(LoadPaymentMethods()),
      child: const _PaymentMethodsView(),
    );
  }
}

class _PaymentMethodsView extends StatelessWidget {
  const _PaymentMethodsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<PaymentMethodsBloc, PaymentMethodsState>(
        listener: (context, state) {
          if (state is PaymentMethodsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.accentRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentMethodsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is PaymentMethodsLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaymentMethodsLoaded state) {
    return Stack(
      children: [
        // Contenu scrollable
        SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 72,
            left: 16,
            right: 16,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Section Wallets Mobiles ──
              _buildSectionTitle('WALLETS MOBILES'),
              const SizedBox(height: 16),
              ...state.wallets.map(
                (wallet) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WalletCard(
                    method: wallet,
                    onTap: () {
                      if (wallet.status == PaymentMethodStatus.connected) {
                        context
                            .read<PaymentMethodsBloc>()
                            .add(SelectDefaultMethod(wallet.id));
                      } else {
                        _showConfigureDialog(context, wallet);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Section Options de livraison ──
              _buildSectionTitle('OPTIONS DE LIVRAISON'),
              const SizedBox(height: 16),
              const CashPaymentCard(),
              const SizedBox(height: 24),

              // ── Section Cartes Bancaires ──
              EmptyCardsWidget(
                onAdd: () => _showComingSoon(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),

        // Header sticky
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildHeader(context),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 16,
            left: 12,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: .9),
            border: Border(
              bottom: BorderSide(
                color: AppColors.border,
              ),
            ),
          ),
          child: Row(
            children: [
              // Bouton retour
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Titre
              const Text(
                'Moyens de paiement',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border),
        ),
        title: const Row(
          children: [
            Icon(Icons.credit_card_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 10),
            Text(
              'Prochainement',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Le paiement par carte bancaire sera disponible dans une prochaine mise à jour.\n\nUtilisez Orange Money, MTN MoMo ou Wave pour payer dès maintenant.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfigureDialog(BuildContext context, PaymentMethod method) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border),
        ),
        title: Text(
          'Configurer ${method.providerName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Entrez votre numéro de téléphone pour connecter ${method.providerName}.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: '07 08 09 10 11',
                hintStyle: TextStyle(
                  color: AppColors.surface,
                ),
                prefixText: '+225 ',
                prefixStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: AppColors.backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'ANNULER',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final phone = controller.text.trim();
              if (phone.isEmpty) return;
              Navigator.pop(dialogCtx);
              // Simuler la config : on ne fait rien de plus en mock
              context.read<PaymentMethodsBloc>().add(LoadPaymentMethods());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.backgroundDark, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        '${method.providerName} configuré',
                        style: const TextStyle(
                          color: AppColors.backgroundDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: const Text(
              'CONFIGURER',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
