import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Livraison'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is! CartLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final cart = state.cart;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Adresse de livraison',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Address
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            hintText: 'Quartier, Rue, Porte',
                            prefixIcon: Icon(
                              Icons.location_on_outlined,
                              size: 20,
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'L\'adresse est requise'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // City
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            hintText: 'Ville (ex: Bamako)',
                            prefixIcon: Icon(
                              Icons.location_city_outlined,
                              size: 20,
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'La ville est requise'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Téléphone de contact',
                            prefixIcon: Icon(Icons.phone_outlined, size: 20),
                          ),
                          validator: ValidationUtils.validatePhone,
                        ),
                        const SizedBox(height: 16),

                        // Note
                        TextFormField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText:
                                'Instructions spéciales (ex: Code portail, étage...)',
                            prefixIcon: Icon(Icons.note_add_outlined, size: 20),
                          ),
                        ),

                        const SizedBox(height: 32),
                        const Text(
                          'Résumé de la commande',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow(
                          'Sous-total',
                          FormatUtils.formatPrice(cart.totalPrice),
                        ),
                        _buildSummaryRow(
                          'Frais de livraison',
                          FormatUtils.formatPrice(cart.deliveryFee),
                        ),
                        const Divider(height: 32),
                        _buildSummaryRow(
                          'Total',
                          FormatUtils.formatPrice(cart.totalAmount),
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Button
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundDark,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.push(
                          '/payment',
                          extra: {
                            'cart': cart,
                            'address':
                                '${_addressController.text}, ${_cityController.text}',
                            'phone': _phoneController.text,
                            'note': _noteController.text,
                          },
                        );
                      }
                    },
                    child: const Text(
                      'Continuer vers le paiement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? AppColors.textPrimary : AppColors.textGrey,
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
