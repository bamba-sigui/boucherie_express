import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';

/// Écran Paramètres — sections : Compte, Notifications, À propos.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
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

                // ── Compte ──
                _buildSectionTitle('COMPTE'),
                const SizedBox(height: 12),
                _buildTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Informations personnelles',
                  onTap: () => context.push('/personal-info'),
                ),
                const SizedBox(height: 8),
                _buildTile(
                  icon: Icons.location_on_outlined,
                  title: 'Mes adresses',
                  onTap: () => context.push('/addresses'),
                ),
                const SizedBox(height: 8),
                _buildTile(
                  icon: Icons.payment_outlined,
                  title: 'Moyens de paiement',
                  onTap: () => context.push('/payment-methods'),
                ),
                const SizedBox(height: 24),

                // ── Notifications ──
                _buildSectionTitle('NOTIFICATIONS'),
                const SizedBox(height: 12),
                _buildToggleTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications push',
                  value: _pushNotifications,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                ),
                const SizedBox(height: 8),
                _buildToggleTile(
                  icon: Icons.email_outlined,
                  title: 'Notifications email',
                  value: _emailNotifications,
                  onChanged: (v) => setState(() => _emailNotifications = v),
                ),
                const SizedBox(height: 8),
                _buildToggleTile(
                  icon: Icons.sms_outlined,
                  title: 'Notifications SMS',
                  value: _smsNotifications,
                  onChanged: (v) => setState(() => _smsNotifications = v),
                ),
                const SizedBox(height: 24),

                // ── À propos ──
                _buildSectionTitle('À PROPOS'),
                const SizedBox(height: 12),
                _buildTile(
                  icon: Icons.description_outlined,
                  title: "Conditions d'utilisation",
                  onTap: () => _launchUrl('https://boucherie-express.ci/cgu'),
                ),
                const SizedBox(height: 8),
                _buildTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Politique de confidentialité',
                  onTap: () =>
                      _launchUrl('https://boucherie-express.ci/privacy'),
                ),
                const SizedBox(height: 8),
                _buildTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'Contacter le support',
                  onTap: () => context.push('/support'),
                ),
                const SizedBox(height: 32),

                // Version
                Center(
                  child: Text(
                    'Boucherie Express v1.0.0',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
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
            right: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: .9),
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
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
              const Text(
                'Paramètres',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: .3),
            inactiveThumbColor: AppColors.border,
            inactiveTrackColor: AppColors.border.withValues(alpha: .5),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
