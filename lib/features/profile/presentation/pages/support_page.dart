import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/support_contact.dart';
import '../bloc/support_bloc.dart';
import '../widgets/contact_card.dart';
import '../widgets/faq_accordion_item.dart';
import '../widgets/social_links_widget.dart';

/// Page Support & Aide — design Stitch home_17.
///
/// - Section FAQ interactive (accordéon exclusif)
/// - Contacts rapides (téléphone, WhatsApp)
/// - Réseaux sociaux
class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SupportBloc>()..add(LoadSupport()),
      child: const _SupportView(),
    );
  }
}

class _SupportView extends StatelessWidget {
  const _SupportView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocBuilder<SupportBloc, SupportState>(
        builder: (context, state) {
          // — Loading —
          if (state is SupportLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // — Error —
          if (state is SupportError) {
            return _ErrorWidget(message: state.message);
          }

          // — Loaded —
          if (state is SupportLoaded) {
            return Stack(
              children: [
                // Scrollable content
                CustomScrollView(
                  slivers: [
                    // Espace pour le header sticky
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).padding.top + 64,
                      ),
                    ),

                    // — FAQ section —
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _SectionTitle(title: 'QUESTIONS FRÉQUENTES'),
                      ),
                    ),

                    if (state.faqs.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 24,
                          ),
                          child: Center(
                            child: Text(
                              'Aucune question fréquente disponible',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        sliver: SliverList.separated(
                          itemCount: state.faqs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final faq = state.faqs[index];
                            return FaqAccordionItem(
                              item: faq,
                              onToggle: () => context
                                  .read<SupportBloc>()
                                  .add(ToggleFaq(faq.id)),
                            );
                          },
                        ),
                      ),

                    // — Contacts section —
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                        child: _SectionTitle(title: 'NOUS CONTACTER'),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      sliver: SliverList.separated(
                        itemCount: state.contacts.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final contact = state.contacts[index];
                          return ContactCard(
                            contact: contact,
                            onTap: () => _launchContact(context, contact),
                          );
                        },
                      ),
                    ),

                    // — Social links —
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                        child: SocialLinksWidget(
                          onFacebookTap: () => _launchUrl(
                            'https://facebook.com/boucherieexpress',
                          ),
                          onInstagramTap: () => _launchUrl(
                            'https://instagram.com/boucherieexpress',
                          ),
                          onShareTap: () {
                            // TODO: Implement share
                          },
                        ),
                      ),
                    ),

                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 40),
                    ),
                  ],
                ),

                // — Sticky header —
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _StickyHeader(
                    onBack: () => context.pop(),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Lance l'action appropriée selon le type de contact.
  void _launchContact(BuildContext context, SupportContact contact) {
    switch (contact.type) {
      case SupportContactType.phone:
        _launchUrl('tel:${contact.value}');
        break;
      case SupportContactType.whatsapp:
        final encoded = Uri.encodeComponent(
          'Bonjour, j\'ai besoin d\'aide avec ma commande.',
        );
        _launchUrl('https://wa.me/${contact.value}?text=$encoded');
        break;
      case SupportContactType.email:
        _launchUrl('mailto:${contact.value}');
        break;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ─── Section Title ───────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF94A3B8), // slate-400
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ─── Sticky Header ──────────────────────────────────────────────

class _StickyHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _StickyHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding + 8,
            left: 12,
            right: 20,
            bottom: 12,
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
              // Back button
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onBack,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Title
              const Text(
                'Support & Aide',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Error Widget ───────────────────────────────────────────────

class _ErrorWidget extends StatelessWidget {
  final String message;
  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.accentRed.withValues(alpha: .6),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              style: const TextStyle(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.read<SupportBloc>().add(LoadSupport()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 14,
              ),
            ),
            child: const Text(
              'Réessayer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
