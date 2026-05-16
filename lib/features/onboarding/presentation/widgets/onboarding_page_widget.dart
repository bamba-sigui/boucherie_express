import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/onboarding_page.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with badge in rounded container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // White/light gray rounded container
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: CachedNetworkImage(
                      imageUrl: page.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Icon(
                          Icons.restaurant,
                          color: AppColors.textGrey,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                ),

                // Badge "100% FRAIS"
                Positioned(
                  bottom: -20,
                  right: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          color: AppColors.backgroundDark,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          page.badgeText,
                          style: const TextStyle(
                            color: AppColors.backgroundDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Title with mixed colors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                children: _buildTitleSpans(page.title),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              page.description,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Parse title to highlight green words
  List<TextSpan> _buildTitleSpans(String title) {
    final List<TextSpan> spans = [];
    final lines = title.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check if line should be green (contains specific keywords)
      final isGreen =
          line.toLowerCase().contains('livrée chez vous') ||
          line.toLowerCase().contains('recevez rapidement') ||
          line.toLowerCase().contains('garantie') ||
          line.toLowerCase().contains('sécurisé');

      spans.add(
        TextSpan(
          text: line,
          style: TextStyle(color: isGreen ? AppColors.primary : AppColors.textPrimary),
        ),
      );

      // Add line break if not last line
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }
}
