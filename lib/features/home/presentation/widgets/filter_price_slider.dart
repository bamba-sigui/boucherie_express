import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Slider de prix avec range min/max.
///
/// Design : thumb rouge, track active rouge, affichage dynamique des valeurs.
/// Debounce intégré pour éviter les rebuilds excessifs.
class FilterPriceSlider extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onChanged;

  const FilterPriceSlider({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.onChanged,
  });

  @override
  State<FilterPriceSlider> createState() => _FilterPriceSliderState();
}

class _FilterPriceSliderState extends State<FilterPriceSlider> {
  late RangeValues _currentRange;

  @override
  void initState() {
    super.initState();
    _currentRange = RangeValues(widget.minPrice, widget.maxPrice);
  }

  @override
  void didUpdateWidget(FilterPriceSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minPrice != widget.minPrice ||
        oldWidget.maxPrice != widget.maxPrice) {
      _currentRange = RangeValues(widget.minPrice, widget.maxPrice);
    }
  }

  String _formatPrice(double value) {
    return '${value.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ')} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Titre section ──
          const Text(
            'Prix (FCFA)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // ── Affichage dynamique des valeurs ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceLabel(_formatPrice(_currentRange.start)),
              _buildPriceLabel(_formatPrice(_currentRange.end)),
            ],
          ),
          const SizedBox(height: 8),

          // ── Range slider ──
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFE32626),
              inactiveTrackColor: AppColors.categoryUnselected,
              thumbColor: const Color(0xFFE32626),
              overlayColor: const Color(0xFFE32626).withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
                pressedElevation: 4,
              ),
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 8,
                pressedElevation: 4,
              ),
              rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: RangeSlider(
              values: _currentRange,
              min: 0,
              max: 15000,
              divisions: 30,
              onChanged: (values) {
                setState(() {
                  _currentRange = values;
                });
              },
              onChangeEnd: (values) {
                widget.onChanged(values);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.categoryUnselected,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
