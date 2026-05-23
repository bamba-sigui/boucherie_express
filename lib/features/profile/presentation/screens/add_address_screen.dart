import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/address.dart';
import '../bloc/address_bloc.dart';

/// Écran d'ajout d'une nouvelle adresse de livraison.
class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AddressBloc>(),
      child: const _AddAddressView(),
    );
  }
}

class _AddAddressView extends StatefulWidget {
  const _AddAddressView();

  @override
  State<_AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<_AddAddressView> {
  final _formKey = GlobalKey<FormState>();
  final _fullAddressController = TextEditingController();
  AddressType _selectedType = AddressType.home;
  bool _isDefault = false;
  bool _isGettingLocation = false;
  double? _lat;
  double? _lng;

  @override
  void dispose() {
    _fullAddressController.dispose();
    super.dispose();
  }

  String _labelFromType(AddressType type) => switch (type) {
    AddressType.home  => 'Domicile',
    AddressType.work  => 'Bureau',
    AddressType.other => 'Autre',
  };

  Future<void> _getLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showLocationError('Le service de localisation est désactivé.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showLocationError('Permission de localisation refusée.');
        return;
      }
      // Essayer d'abord la position en cache (instantané)
      Position? position = await Geolocator.getLastKnownPosition();
      // Sinon, localisation réseau (WiFi/antennes) — rapide même en intérieur
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 30),
        ),
      );
      _lat = position.latitude;
      _lng = position.longitude;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            if (p.street?.isNotEmpty == true) p.street,
            if (p.subLocality?.isNotEmpty == true) p.subLocality,
            if (p.locality?.isNotEmpty == true) p.locality,
          ];
          final address = parts.whereType<String>().join(', ');
          if (address.isNotEmpty) {
            _fullAddressController.text = address;
          } else {
            // Fallback : coordonnées brutes si le geocoding ne retourne rien
            _fullAddressController.text =
                '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
          }
        }
      } catch (_) {
        // Geocoding échoué (pas de réseau) → coordonnées brutes
        _fullAddressController.text =
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      }
    } catch (e) {
      _showLocationError('Erreur GPS : ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _showLocationError(String msg) {
    if (!mounted) return;
    setState(() => _isGettingLocation = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final address = Address(
      id: const Uuid().v4(),
      label: _labelFromType(_selectedType),
      fullAddress: _fullAddressController.text.trim(),
      type: _selectedType,
      isDefault: _isDefault,
      latitude: _lat,
      longitude: _lng,
    );

    context.read<AddressBloc>().add(AddAddressRequested(address));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressSaved) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.backgroundDark, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Adresse ajoutée',
                      style: TextStyle(
                        color: AppColors.backgroundDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
          if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.accentRed,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AddressLoading;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 72,
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 100,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      AddressFormFields(
                        fullAddressController: _fullAddressController,
                        selectedType: _selectedType,
                        isDefault: _isDefault,
                        onTypeChanged: (t) =>
                            setState(() => _selectedType = t!),
                        onDefaultChanged: (v) =>
                            setState(() => _isDefault = v ?? false),
                        onGetLocation: _getLocation,
                        isGettingLocation: _isGettingLocation,
                      ),
                    ],
                  ),
                ),
              ),

              // Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AddressFormHeader(title: 'Nouvelle adresse'),
              ),

              // Bouton Enregistrer
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AddressSaveButton(isLoading: isLoading, onPressed: _submit),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGETS PARTAGÉS (utilisés par AddAddressScreen et EditAddressScreen)
// ════════════════════════════════════════════════════════════════════════════

/// Champs du formulaire d'adresse réutilisés par add et edit.
class AddressFormFields extends StatelessWidget {
  final TextEditingController fullAddressController;
  final AddressType selectedType;
  final bool isDefault;
  final ValueChanged<AddressType?> onTypeChanged;
  final ValueChanged<bool?> onDefaultChanged;
  final VoidCallback? onGetLocation;
  final bool isGettingLocation;

  const AddressFormFields({
    super.key,
    required this.fullAddressController,
    required this.selectedType,
    required this.isDefault,
    required this.onTypeChanged,
    required this.onDefaultChanged,
    this.onGetLocation,
    this.isGettingLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Adresse complète + bouton GPS
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _inputLabel('Adresse complète'),
            const Spacer(),
            GestureDetector(
              onTap: isGettingLocation ? null : onGetLocation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isGettingLocation
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          color: AppColors.primary,
                          size: 15,
                        ),
                  const SizedBox(width: 4),
                  Text(
                    'Ma position',
                    style: TextStyle(
                      color: isGettingLocation
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _textField(
          controller: fullAddressController,
          hint: 'Rue 12, Cocody, Abidjan',
          maxLines: 3,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
        ),
        const SizedBox(height: 20),

        // Type
        _inputLabel('Type d\'adresse'),
        const SizedBox(height: 8),
        _typeSelector(context),
        const SizedBox(height: 20),

        // Par défaut
        _defaultCheckbox(context),
      ],
    );
  }

  Widget _inputLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.surface),
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentRed),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _typeSelector(BuildContext context) {
    final types = [
      (AddressType.home, Icons.home_rounded, 'Domicile'),
      (AddressType.work, Icons.work_rounded, 'Bureau'),
      (AddressType.other, Icons.location_on_rounded, 'Autre'),
    ];
    return Row(
      children: types.map((entry) {
        final (type, icon, label) = entry;
        final selected = selectedType == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTypeChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: .15)
                      : AppColors.cardDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary.withValues(alpha: .5)
                        : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 20),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _defaultCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: () => onDefaultChanged(!isDefault),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isDefault ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDefault
                    ? AppColors.primary
                    : AppColors.border,
                width: 2,
              ),
            ),
            child: isDefault
                ? const Icon(Icons.check_rounded,
                    color: AppColors.backgroundDark, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            'Définir comme adresse par défaut',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header blurred partagé.
class AddressFormHeader extends StatelessWidget {
  final String title;
  const AddressFormHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
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
              bottom:
                  BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
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
              Text(
                title,
                style: const TextStyle(
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
}

/// Bouton Enregistrer partagé.
class AddressSaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const AddressSaveButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundDark.withValues(alpha: 0),
            AppColors.backgroundDark.withValues(alpha: .9),
            AppColors.backgroundDark,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.backgroundDark,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: .4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.backgroundDark,
                  ),
                )
              : const Text(
                  'ENREGISTRER',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}
