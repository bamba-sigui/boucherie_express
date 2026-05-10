import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Full-bleed image carousel with overlay controls.
///
/// Matches the Stitch design:
/// - Aspect ratio ~4/5
/// - Pagination dots (active = wider bar, inactive = small dot)
/// - Gradient overlay at the bottom blending into [AppColors.backgroundDark]
/// - Back button (circle, blurred, borderless)
/// - Favorite button (white circle, red filled heart when active)
/// - Optional play button when [videoUrl] is provided
class ProductCarousel extends StatefulWidget {
  final List<String> images;
  final String? videoUrl;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onPlayVideo;

  const ProductCarousel({
    super.key,
    required this.images,
    this.videoUrl,
    required this.isFavorite,
    required this.onBack,
    required this.onFavoriteToggle,
    this.onPlayVideo,
  });

  @override
  State<ProductCarousel> createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Image Carousel (or placeholder when none) ──
          if (widget.images.isEmpty)
            Container(
              color: AppColors.cardDark,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textGrey,
                  size: 64,
                ),
              ),
            )
          else
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Container(
                    color: AppColors.backgroundDark,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.backgroundDark,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textGrey,
                      size: 48,
                    ),
                  ),
                );
              },
            ),

          // ── Gradient overlay bottom ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 128,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.backgroundDark.withValues(alpha: .6),
                    AppColors.backgroundDark,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // ── Top overlay buttons ──
          Positioned(
            top: topPadding + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                _CircleButton(
                  onTap: widget.onBack,
                  backgroundColor: Colors.black.withValues(alpha: .3),
                  blur: true,
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
                // Favorite button
                _CircleButton(
                  onTap: widget.onFavoriteToggle,
                  backgroundColor: AppColors.surface,
                  child: Icon(
                    widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: widget.isFavorite
                        ? AppColors.freshRed
                        : Colors.black54,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          // ── Play button (video) ──
          if (widget.videoUrl != null && widget.onPlayVideo != null)
            Center(
              child: GestureDetector(
                onTap: widget.onPlayVideo,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textSecondary,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.textPrimary,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Pagination dots ──
          if (widget.images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 32 : 8,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

/// Reusable circular overlay button.
class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final bool blur;
  final Widget child;

  const _CircleButton({
    required this.onTap,
    required this.backgroundColor,
    this.blur = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: blur
            ? Border.all(color: AppColors.border)
            : null,
      ),
      child: Center(child: child),
    );

    if (blur) {
      content = ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: content,
        ),
      );
    }

    return GestureDetector(onTap: onTap, child: content);
  }
}
