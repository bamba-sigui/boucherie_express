import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/auth_gate.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/empty_orders_content.dart';
import '../widgets/order_card.dart';
import '../widgets/orders_header.dart';

/// Page « Mes Commandes » de l'application BoucherieExpress.
///
/// Intégrée dans le [MainScreen] via IndexedStack (index 3).
/// Gère les états : loading, vide, liste, erreur.
/// Le BLoC est créé ici et injecté via [getIt].
///
/// Architecture identique à [FavoritesPage] :
/// - Stateful avec clé publique [OrdersPageState]
/// - Méthode [reload] exposée pour le rafraîchissement inter-onglets
/// - Délègue l'affichage vide à [EmptyOrdersContent]
/// - Délègue chaque carte à [OrderCard] (widget dédié)
class OrdersPage extends StatefulWidget {
  /// Callback pour naviguer vers l'onglet Home (CTA "Commander maintenant").
  final VoidCallback? onNavigateToHome;

  const OrdersPage({super.key, this.onNavigateToHome});

  @override
  State<OrdersPage> createState() => OrdersPageState();
}

class OrdersPageState extends State<OrdersPage> {
  late final OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    _orderBloc = getIt<OrderBloc>();
    // Ne charger les commandes que si l'utilisateur est connecté.
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _orderBloc.add(LoadUserOrders());
    }
  }

  @override
  void dispose() {
    _orderBloc.close();
    super.dispose();
  }

  /// Recharge les commandes (appelé quand l'onglet devient visible).
  void reload() {
    _orderBloc.add(LoadUserOrders());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderBloc,
      child: AuthGate(
        icon: Icons.receipt_long_outlined,
        title: 'Connectez-vous',
        subtitle: 'Connectez-vous pour voir vos commandes.',
        child: Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Header ──
                const OrdersHeader(),

                // ── Contenu ──
                Expanded(
                  child: BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, state) {
                      if (state is OrderLoading) {
                        return _buildLoadingState();
                      }

                      if (state is OrderError) {
                        return _buildErrorState(context, state.message);
                      }

                      if (state is OrdersLoaded) {
                        if (state.orders.isEmpty) {
                          return _buildEmptyState();
                        }
                        return _OrdersListView(
                          orders: state.orders,
                          onNavigateToHome: widget.onNavigateToHome,
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shimmer / loading indicator.
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2,
      ),
    );
  }

  /// État vide — délègue au widget dédié.
  Widget _buildEmptyState() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyOrdersContent(
            onCommanderMaintenant: widget.onNavigateToHome,
          ),
        ),
      ],
    );
  }

  /// État d'erreur avec bouton réessayer.
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<OrderBloc>().add(LoadUserOrders());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Liste animée des commandes
// ─────────────────────────────────────────────────────────

class _OrdersListView extends StatefulWidget {
  final List<Order> orders;
  final VoidCallback? onNavigateToHome;

  const _OrdersListView({required this.orders, this.onNavigateToHome});

  @override
  State<_OrdersListView> createState() => _OrdersListViewState();
}

class _OrdersListViewState extends State<_OrdersListView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + widget.orders.length * 100),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: widget.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = widget.orders[index];

              // Animation staggered par carte
              final start = (index * 0.15).clamp(0.0, 0.7);
              final end = (start + 0.3).clamp(0.0, 1.0);

              final animation = CurvedAnimation(
                parent: _controller,
                curve: Interval(start, end, curve: Curves.easeOutCubic),
              );

              // Opacité réduite pour les commandes livrées (sauf 1ère)
              final isOldDelivered =
                  order.status == OrderStatus.delivered && index > 1;

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: OrderCard(
                    order: order,
                    opacity: isOldDelivered ? 0.9 : 1.0,
                    onTap: () {
                      context.push('/order-details', extra: order);
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // Espacement bas pour la bottom nav
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}
