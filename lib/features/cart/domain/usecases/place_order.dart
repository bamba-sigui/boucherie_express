import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/checkout.dart';
import '../entities/order_result.dart';
import '../repositories/checkout_repository.dart';

/// Passe la commande finale après validation métier.
@lazySingleton
class PlaceOrder implements UseCase<OrderResult, PlaceOrderParams> {
  final CheckoutRepository repository;

  PlaceOrder(this.repository);

  @override
  Future<Either<Failure, OrderResult>> call(PlaceOrderParams params) async {
    // 1. Validate business rules BEFORE calling repository
    if (!params.checkout.canPlaceOrder) {
      if (!params.checkout.hasItems) {
        return const Left(ValidationFailure('Le panier est vide'));
      }
      if (!params.checkout.hasPaymentMethod) {
        return const Left(
          ValidationFailure('Veuillez sélectionner un mode de paiement'),
        );
      }
      if (!params.checkout.hasValidAddress) {
        return const Left(
          ValidationFailure('Veuillez renseigner une adresse de livraison'),
        );
      }
    }

    // 2. Delegate to repository
    return repository.placeOrder(params.checkout);
  }
}

class PlaceOrderParams extends Equatable {
  final Checkout checkout;

  const PlaceOrderParams({required this.checkout});

  @override
  List<Object?> get props => [checkout];
}
