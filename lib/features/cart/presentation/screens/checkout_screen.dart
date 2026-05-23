import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/auth_gate.dart';
import '../../domain/entities/cart.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/checkout_bloc.dart';
import '../widgets/checkout_summary.dart';
import '../widgets/delivery_address_card.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/place_order_button.dart';

/// Écran de finalisation de la commande.
///
/// Layout (top → bottom) :
/// 1. Header blurred (retour + titre centré)
/// 2. Section adresse de livraison
/// 3. Section mode de paiement (4 options avec radio)
/// 4. Résumé financier
/// 5. Footer (bouton validation + mention légale)
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupère le cart depuis le CartBloc parent
    final cartState = context.read<CartBloc>().state;
    final cart = cartState is CartLoaded ? cartState.cart : const Cart();

    return AuthGate(
      icon: Icons.shopping_bag_outlined,
      title: 'Connectez-vous',
      subtitle: 'Connectez-vous pour finaliser votre commande.',
      child: BlocProvider(
        create: (_) => getIt<CheckoutBloc>()..add(LoadCheckout(cart: cart)),
        child: const _CheckoutView(),
      ),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<CheckoutBloc, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutSuccess) {
            context.read<CartBloc>().add(ClearCart());
            context.go('/order-confirmation', extra: {
              'orderId': state.orderId,
              'paymentMethodType': state.paymentMethodType,
            });
          }
          if (state is CheckoutReady && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CheckoutLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CheckoutError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          if (state is CheckoutReady) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CheckoutReady state) {
    final checkout = state.checkout;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        // ── Header ──
        _CheckoutHeader(),

        // ── Scrollable content ──
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 1. Section title: Adresse de livraison
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Adresse de livraison',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 2. Delivery address card
                if (checkout.deliveryAddress != null)
                  DeliveryAddressCard(
                    address: checkout.deliveryAddress!,
                    onEdit: () => context.push('/addresses'),
                  )
                else
                  _NoAddressCard(),

                const SizedBox(height: 28),

                // 3. Payment method selector
                PaymentMethodSelector(
                  methods: state.paymentMethods,
                  selectedMethod: checkout.selectedPaymentMethod,
                  onMethodSelected: (method) {
                    context.read<CheckoutBloc>().add(
                      SelectPaymentMethod(method),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // 4. Order summary
                CheckoutSummary(
                  subtotal: checkout.subtotal,
                  deliveryFee: checkout.deliveryFee,
                  total: checkout.totalAmount,
                  itemCount: checkout.totalItems,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // ── Footer ──
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + bottomPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlaceOrderButton(
                enabled: state.canSubmit,
                isLoading: state.isSubmitting,
                onPressed: () {
                  context.read<CheckoutBloc>().add(SubmitOrder());
                },
              ),
              const SizedBox(height: 16),
              Text(
                'BOUCHERIE EXPRESS • QUALITÉ GARANTIE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NO ADDRESS CARD
// ═══════════════════════════════════════════════════════════════════════════

class _NoAddressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.push('/addresses'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: .4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_location_alt_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajouter une adresse de livraison',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Requis pour passer la commande',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════════════════

class _CheckoutHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark.withValues(alpha: .8),
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),

                // Title
                const Expanded(
                  child: Text(
                    'Finaliser la commande',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),

                // Spacer to balance back button
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
