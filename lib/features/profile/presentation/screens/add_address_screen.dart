import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return BlocProvider(
      create: (_) => getIt<AddressBloc>()..add(LoadAddresses()),
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
  final _labelController = TextEditingController();
  final _fullAddressController = TextEditingController();
  AddressType _selectedType = AddressType.home;
  bool _isDefault = false;

  @override
  void dispose() {
    _labelController.dispose();
    _fullAddressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final address = Address(
      id: const Uuid().v4(),
      label: _labelController.text.trim(),
      fullAddress: _fullAddressController.text.trim(),
      type: _selectedType,
      isDefault: _isDefault,
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
                        labelController: _labelController,
                        fullAddressController: _fullAddressController,
                        selectedType: _selectedType,
                        isDefault: _isDefault,
                        onTypeChanged: (t) =>
                            setState(() => _selectedType = t!),
                        onDefaultChanged: (v) =>
                            setState(() => _isDefault = v ?? false),
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
  final TextEditingController labelController;
  final TextEditingController fullAddressController;
  final AddressType selectedType;
  final bool isDefault;
  final ValueChanged<AddressType?> onTypeChanged;
  final ValueChanged<bool?> onDefaultChanged;

  const AddressFormFields({
    super.key,
    required this.labelController,
    required this.fullAddressController,
    required this.selectedType,
    required this.isDefault,
    required this.onTypeChanged,
    required this.onDefaultChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        _inputLabel('Libellé (ex : Maison, Bureau)'),
        const SizedBox(height: 8),
        _textField(
          controller: labelController,
          hint: 'Mon domicile',
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
        ),
        const SizedBox(height: 20),

        // Adresse complète
        _inputLabel('Adresse complète'),
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
