import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/support_contact.dart';

/// Couleur WhatsApp officielle.
const Color _whatsappGreen = Color(0xFF25D366);

/// Carte de contact support — design Stitch home_17.
///
/// Prend en charge les types [SupportContactType.phone] et
/// [SupportContactType.whatsapp] avec icônes et styles adaptés.
class ContactCard extends StatelessWidget {
  final SupportContact contact;
  final VoidCallback onTap;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWhatsApp = contact.type == SupportContactType.whatsapp;
    final iconColor = isWhatsApp ? _whatsappGreen : AppColors.primary;

    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: iconColor.withValues(alpha: .08),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.surface,
            ),
          ),
          child: Row(
            children: [
              // — Icon circle —
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: .1),
                ),
                child: Center(
                  child: isWhatsApp
                      ? _WhatsAppIcon(color: iconColor)
                      : Icon(Icons.call_rounded, color: iconColor, size: 24),
                ),
              ),
              const SizedBox(width: 16),

              // — Textes —
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.title,
                      style: const TextStyle(
                        color: Color(0xFFF1F5F9), // slate-100
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // — Badge "EN LIGNE" pour WhatsApp —
              if (contact.isOnline)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _whatsappGreen.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'EN LIGNE',
                    style: TextStyle(
                      color: _whatsappGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icône WhatsApp SVG-like en Flutter.
class _WhatsAppIcon extends StatelessWidget {
  final Color color;
  const _WhatsAppIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.chat_rounded, color: color, size: 24);
  }
}
