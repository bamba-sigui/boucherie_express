import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/order_tracking_bloc.dart';
import '../widgets/courier_card.dart';
import '../widgets/delivery_timeline.dart';
import '../widgets/estimated_arrival_card.dart';
import '../widgets/tracking_header.dart';

/// Écran de suivi de commande – Version Timeline Only.
///
/// Stack layout :
/// 1. ScrollView : EstimatedArrivalCard (map preview) → DeliveryTimeline
/// 2. Sticky header (blurred)
/// 3. CourierCard fixe en bas
///
/// Pull-to-refresh dispatche [RefreshOrderTracking].
class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.I<OrderTrackingBloc>()
            ..add(LoadOrderTracking(orderId: orderId)),
      child: const _OrderTrackingView(),
    );
  }
}

class _OrderTrackingView extends StatelessWidget {
  const _OrderTrackingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocBuilder<OrderTrackingBloc, OrderTrackingState>(
        builder: (context, state) {
          return switch (state) {
            OrderTrackingInitial() || OrderTrackingLoading() => _buildLoading(),
            OrderTrackingError(:final message) => _buildError(context, message),
            OrderTrackingLoaded(:final tracking) => Stack(
              children: [
                // ── Scrollable content ──
                RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.cardDark,
                  onRefresh: () async {
                    context.read<OrderTrackingBloc>().add(
                      const RefreshOrderTracking(),
                    );
                    // Attend un peu pour visibilité
                    await Future.delayed(const Duration(milliseconds: 600));
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // Safe area top spacer
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: MediaQuery.of(context).padding.top,
                        ),
                      ),

                      // Header space (pour le sticky header au-dessus)
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),

                      // Map preview / ETA visual
                      SliverToBoxAdapter(
                        child: EstimatedArrivalCard(
                          mapImageUrl: tracking.mapImageUrl,
                          etaBannerMessage: tracking.etaBannerMessage,
                          isDelivered: tracking.isDelivered,
                        ),
                      ),

                      // Overlap la carte map : marge négative via Transform
                      SliverToBoxAdapter(
                        child: Transform.translate(
                          offset: const Offset(0, -32),
                          child: DeliveryTimeline(steps: tracking.steps),
                        ),
                      ),

                      // Bottom spacer (CourierCard height + safe area)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 120 + MediaQuery.of(context).padding.bottom,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Sticky header ──
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: TrackingHeader(orderId: tracking.orderId),
                  ),
                ),

                // ── Courier card bottom ──
                if (tracking.courier != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 16,
                            bottom: 16 + MediaQuery.of(context).padding.bottom,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDark.withValues(
                              alpha: .6,
                            ),
                            border: Border(
                              top: BorderSide(
                                color: AppColors.surface,
                              ),
                            ),
                          ),
                          child: CourierCard(
                            courier: tracking.courier!,
                            canCall: tracking.canCallCourier,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          };
        },
      ),
    );
  }

  // ── Loading state ─────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                final bloc = context.read<OrderTrackingBloc>();
                bloc.add(const RefreshOrderTracking());
              },
              child: const Text(
                'Réessayer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
