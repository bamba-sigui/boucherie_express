import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/checkout.dart';
import '../entities/delivery_address.dart';
import '../entities/order_result.dart';
import '../entities/payment_method.dart';

/// Contrat du repository checkout.
abstract class CheckoutRepository {
  /// Récupère les méthodes de paiement disponibles.
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods();

  /// Récupère l'adresse de livraison par défaut.
  Future<Either<Failure, DeliveryAddress>> getDefaultAddress();

  /// Passe la commande finale.
  Future<Either<Failure, OrderResult>> placeOrder(Checkout checkout);
}
