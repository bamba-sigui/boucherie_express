import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/delivery_address_card.dart';
import '../widgets/order_actions_section.dart';
import '../widgets/order_details_header.dart';
import '../widgets/order_item_tile.dart';
import '../widgets/order_status_card.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/payment_method_card.dart';

/// Page « Détails de la commande » de l'application BoucherieExpress.
///
/// Design Stitch pixel-perfect (boucherie_express_home_5).
///
/// Peut recevoir directement un [Order] (Hero animation depuis OrderCard)
/// ou charger par ID via le BLoC (navigation par deeplink / route).
///
/// Structure :
/// - [OrderDetailsHeader] — sticky top avec bouton retour
/// - [OrderStatusCard] — statut cliquable → future tracking
/// - Section Articles — titre + liste [OrderItemTile] dans carte
/// - [DeliveryAddressCard] — adresse de livraison
/// - [PaymentMethodCard] — mode de paiement
/// - [OrderSummaryCard] — récapitulatif financier
/// - [OrderActionsSection] — boutons d'actions (sticky bottom)
///
/// Aucune logique métier dans ce widget — tout est délégué au BLoC.
class OrderDetailsPage extends StatefulWidget {
  /// Commande pré-chargée (Hero animation depuis OrderCard).
  final Order? order;

  /// ID de la commande (alternative au pré-chargement).
  final String? orderId;

  const OrderDetailsPage({super.key, this.order, this.orderId})
    : assert(order != null || orderId != null);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage>
    with SingleTickerProviderStateMixin {
  OrderBloc? _bloc;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  /// Si la commande est passée directement, on l'utilise sans BLoC.
  Order? get _directOrder => widget.order;
  bool get _needsBloc => _directOrder == null;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    if (_needsBloc) {
      _bloc = getIt<OrderBloc>()..add(LoadOrderDetails(widget.orderId!));
    } else {
      // Commande déjà disponible → animation immédiate
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si la commande est disponible directement, pas besoin de BLoC
    if (!_needsBloc) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: _buildContent(_directOrder!),
      );
    }

    return BlocProvider.value(
      value: _bloc!,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderDetailsLoaded) {
              _fadeController.forward();
            }
          },
          builder: (context, state) {
            if (state is OrderLoading) {
              return _buildLoadingState();
            }

            if (state is OrderError) {
              return _buildErrorState(state.message);
            }

            if (state is OrderDetailsLoaded) {
              return _buildContent(state.order);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SafeArea(
      child: Column(
        children: [
          // Header skeleton
          Container(
            padding: const EdgeInsets.fromLTRB(4, 8, 20, 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 140,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Loading indicator
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SafeArea(
      child: Column(
        children: [
          // Header avec bouton retour
          Container(
            padding: const EdgeInsets.fromLTRB(4, 8, 20, 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Détails de la Commande',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Order order) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header sticky ──
            OrderDetailsHeader(order: order),

            // ── Contenu scrollable ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Statut ──
                    OrderStatusCard(
                      status: order.status,
                      onTap: () {
                        // Future: navigation vers page tracking
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── 2. Articles ──
                    _buildArticlesSection(order),
                    const SizedBox(height: 16),

                    // ── 3. Adresse + Paiement ──
                    DeliveryAddressCard(address: order.deliveryAddress),
                    const SizedBox(height: 16),
                    PaymentMethodCard(paymentMethod: order.paymentMethod),
                    const SizedBox(height: 16),

                    // ── 4. Récapitulatif ──
                    OrderSummaryCard(
                      subtotal: order.totalPrice,
                      deliveryFee: order.deliveryFee,
                      total: order.totalAmount,
                    ),
                    const SizedBox(height: 24),

                    // ── 5. Actions ──
                    OrderActionsSection(
                      onTrackOrder: () =>
                          context.push('/order-tracking', extra: order.id),
                      onContactSupport: () {
                        // Future: ouvrir le support client
                      },
                    ),

                    // Espacement SafeArea bottom
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 32,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section "ARTICLES" avec carte contenant la liste de OrderItemTile.
  Widget _buildArticlesSection(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Titre section ──
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'ARTICLES',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Carte articles ──
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: _buildItemTiles(order.items)),
        ),
      ],
    );
  }

  /// Construit la liste des tiles d'articles avec dividers entre eux.
  List<Widget> _buildItemTiles(List<OrderItem> items) {
    final tiles = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      tiles.add(OrderItemTile(item: items[i]));
      if (i < items.length - 1) {
        tiles.add(
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.border,
          ),
        );
      }
    }
    return tiles;
  }
}
