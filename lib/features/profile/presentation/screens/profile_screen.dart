import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/auth_gate.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/user_info_card.dart';

/// Écran Profil utilisateur — design premium sombre.
///
/// Respecte le design Stitch (boucherie_express_home_13).
/// Utilise les widgets modulaires : [ProfileHeader], [UserInfoCard],
/// [ProfileMenuItem] et [LogoutButton].
///
/// Embarqué dans le [MainScreen] via IndexedStack (pas de route propre).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      icon: Icons.person_outline_rounded,
      title: 'Connectez-vous',
      subtitle: 'Connectez-vous pour accéder à votre profil.',
      child: BlocProvider(
        create: (context) => getIt<ProfileBloc>()..add(LoadProfile()),
        child: const _ProfileView(),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          // --- Loading ---
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // --- Error ---
          if (state is ProfileError) {
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
                      state.message,
                      style: const TextStyle(color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ProfileBloc>().add(LoadProfile()),
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

          // --- Loaded ---
          if (state is ProfileLoaded) {
            final user = state.user;
            return Stack(
              children: [
                // Scrollable content
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 72,
                    left: 20,
                    right: 20,
                    bottom: 32,
                  ),
                  child: Column(
                    children: [
                      // — Carte utilisateur —
                      UserInfoCard(
                        name: user.name.isNotEmpty ? user.name : 'Utilisateur',
                        phone: (user.phone != null && user.phone!.isNotEmpty)
                            ? user.phone!
                            : 'Non renseigné',
                        onEdit: () => context.push('/personal-info'),
                      ),
                      const SizedBox(height: 24),

                      // — Menu items —
                      ProfileMenuItem(
                        icon: Icons.location_on_rounded,
                        title: 'Mes adresses',
                        onTap: () => context.push('/addresses'),
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon: Icons.history_rounded,
                        title: 'Historique des commandes',
                        onTap: () => context.push('/orders'),
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon: Icons.payment_rounded,
                        title: 'Moyens de paiement',
                        onTap: () => context.push('/payment-methods'),
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon: Icons.headset_mic_rounded,
                        title: 'Support client',
                        onTap: () => context.push('/support'),
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon: Icons.settings_rounded,
                        title: 'Paramètres',
                        onTap: () => context.push('/settings'),
                      ),
                      const SizedBox(height: 32),

                      // — Déconnexion —
                      LogoutButton(
                        onConfirmed: () {
                          context.read<ProfileBloc>().add(LogoutRequested());
                        },
                      ),
                      const SizedBox(height: 16),

                      // Version
                      Text(
                        'Boucherie Express v1.0.0',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // — Sticky header —
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ProfileHeader(),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
