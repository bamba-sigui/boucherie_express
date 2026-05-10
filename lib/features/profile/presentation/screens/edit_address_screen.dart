import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/address.dart';
import '../bloc/address_bloc.dart';
import 'add_address_screen.dart';

/// Écran d'édition d'une adresse existante.
class EditAddressScreen extends StatelessWidget {
  final String addressId;

  const EditAddressScreen({super.key, required this.addressId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddressBloc>()..add(LoadAddresses()),
      child: _EditAddressView(addressId: addressId),
    );
  }
}

class _EditAddressView extends StatefulWidget {
  final String addressId;
  const _EditAddressView({required this.addressId});

  @override
  State<_EditAddressView> createState() => _EditAddressViewState();
}

class _EditAddressViewState extends State<_EditAddressView> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _fullAddressController = TextEditingController();
  AddressType _selectedType = AddressType.home;
  bool _isDefault = false;
  bool _initialized = false;

  @override
  void dispose() {
    _labelController.dispose();
    _fullAddressController.dispose();
    super.dispose();
  }

  void _initFrom(Address address) {
    if (_initialized) return;
    _labelController.text = address.label;
    _fullAddressController.text = address.fullAddress;
    _selectedType = address.type;
    _isDefault = address.isDefault;
    _initialized = true;
  }

  void _submit(Address original) {
    if (!_formKey.currentState!.validate()) return;

    final updated = original.copyWith(
      label: _labelController.text.trim(),
      fullAddress: _fullAddressController.text.trim(),
      type: _selectedType,
      isDefault: _isDefault,
    );

    context.read<AddressBloc>().add(UpdateAddressRequested(updated));
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
                      'Adresse mise à jour',
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
          if (state is AddressLoading && !_initialized) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // Trouver l'adresse dans l'état chargé
          Address? target;
          if (state is AddressLoaded) {
            target = state.addresses
                .where((a) => a.id == widget.addressId)
                .firstOrNull;
          }

          if (target == null && !_initialized) {
            return Center(
              child: Text(
                'Adresse introuvable',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          if (target != null) _initFrom(target);

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
                child: AddressFormHeader(title: 'Modifier l\'adresse'),
              ),

              // Bouton Enregistrer
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AddressSaveButton(
                  isLoading: isLoading,
                  onPressed: () => _submit(target!),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
