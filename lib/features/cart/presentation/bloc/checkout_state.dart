part of 'checkout_bloc.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutReady extends CheckoutState {
  final Checkout checkout;
  final List<PaymentMethod> paymentMethods;
  final bool isSubmitting;
  final String? errorMessage;

  const CheckoutReady({
    required this.checkout,
    required this.paymentMethods,
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// `true` si toutes les conditions sont remplies pour passer commande.
  bool get canSubmit => checkout.canPlaceOrder && !isSubmitting;

  CheckoutReady copyWith({
    Checkout? checkout,
    List<PaymentMethod>? paymentMethods,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return CheckoutReady(
      checkout: checkout ?? this.checkout,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    checkout,
    paymentMethods,
    isSubmitting,
    errorMessage,
  ];
}

class CheckoutSuccess extends CheckoutState {
  final String orderId;
  final String paymentMethodType; // 'cash' | 'mobile_money'

  const CheckoutSuccess({
    required this.orderId,
    required this.paymentMethodType,
  });

  @override
  List<Object?> get props => [orderId, paymentMethodType];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}
