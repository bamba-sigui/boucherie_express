import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/checkout.dart';
import '../../domain/entities/delivery_address.dart';
import '../../domain/entities/order_result.dart';
import '../../domain/entities/payment_method.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/get_default_address.dart';
import '../../domain/usecases/get_payment_methods.dart';
import '../../domain/usecases/place_order.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

@injectable
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final GetPaymentMethods getPaymentMethods;
  final GetDefaultAddress getDefaultAddress;
  final PlaceOrder placeOrder;

  CheckoutBloc(this.getPaymentMethods, this.getDefaultAddress, this.placeOrder)
    : super(CheckoutInitial()) {
    on<LoadCheckout>(_onLoadCheckout);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<SubmitOrder>(_onSubmitOrder);
  }

  /// Charge les données initiales (adresse, méthodes de paiement).
  Future<void> _onLoadCheckout(
    LoadCheckout event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());

    // Fetch in parallel
    final results = await Future.wait([
      getPaymentMethods(),
      getDefaultAddress(),
    ]);

    final methodsResult = results[0];
    final addressResult = results[1];

    // Check both results
    DeliveryAddress? address;
    List<PaymentMethod> methods = [];

    methodsResult.fold(
      (failure) => emit(CheckoutError(failure.message)),
      (data) => methods = data as List<PaymentMethod>,
    );

    addressResult.fold((failure) {
      // Address failure is non-blocking
    }, (data) => address = data as DeliveryAddress);

    if (state is CheckoutError) return;

    final checkout = Checkout(cart: event.cart, deliveryAddress: address);

    emit(CheckoutReady(checkout: checkout, paymentMethods: methods));
  }

  /// Met à jour la méthode de paiement sélectionnée.
  void _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<CheckoutState> emit,
  ) {
    final currentState = state;
    if (currentState is CheckoutReady) {
      final updatedCheckout = currentState.checkout.selectPayment(event.method);
      emit(currentState.copyWith(checkout: updatedCheckout));
    }
  }

  /// Passe la commande.
  Future<void> _onSubmitOrder(
    SubmitOrder event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CheckoutReady) return;

    if (currentState.checkout.deliveryAddress == null) {
      emit(currentState.copyWith(
        isSubmitting: false,
        errorMessage: 'Veuillez ajouter une adresse de livraison',
      ));
      return;
    }

    emit(currentState.copyWith(isSubmitting: true));

    final result = await placeOrder(
      PlaceOrderParams(checkout: currentState.checkout),
    );

    // Extraire failure ou result sans fold asynchrone
    String? failureMessage;
    OrderResult? orderResult;
    result.fold(
      (failure) => failureMessage = failure.message,
      (r) => orderResult = r,
    );

    if (failureMessage != null) {
      AppLogger.error('placeOrder failed: $failureMessage');
      emit(currentState.copyWith(
        isSubmitting: false,
        errorMessage: failureMessage,
      ));
      return;
    }

    final paymentType =
        currentState.checkout.selectedPaymentMethod?.type ==
                PaymentMethodType.cash
            ? 'cash'
            : 'mobile_money';

    // Ouvrir la page Genius Pay si mobile money
    if (orderResult!.requiresRedirect) {
      try {
        await launchUrl(
          Uri.parse(orderResult!.checkoutUrl!),
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        // URL invalide ou navigateur indisponible — on continue
      }
    }

    emit(CheckoutSuccess(
      orderId: orderResult!.orderId,
      paymentMethodType: paymentType,
    ));
  }
}
