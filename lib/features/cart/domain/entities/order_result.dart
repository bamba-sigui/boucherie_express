import 'package:equatable/equatable.dart';

/// Résultat retourné par l'API après soumission d'une commande.
///
/// - [orderId] : identifiant de la commande créée
/// - [checkoutUrl] : URL Genius Pay à ouvrir (null pour Cash)
/// - [paymentRef] : référence de paiement Genius Pay (null pour Cash)
class OrderResult extends Equatable {
  final String orderId;
  final String? checkoutUrl;
  final String? paymentRef;

  const OrderResult({
    required this.orderId,
    this.checkoutUrl,
    this.paymentRef,
  });

  bool get requiresRedirect => checkoutUrl != null;

  @override
  List<Object?> get props => [orderId, checkoutUrl, paymentRef];
}
