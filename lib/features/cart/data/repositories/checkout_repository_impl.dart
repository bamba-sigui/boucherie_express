import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/checkout.dart';
import '../../domain/entities/delivery_address.dart';
import '../../domain/entities/order_result.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/checkout_repository.dart';

/// Implémentation du repository checkout connectée au backend Flask.
@LazySingleton(as: CheckoutRepository)
class CheckoutRepositoryImpl implements CheckoutRepository {
  final ApiClient _apiClient;

  CheckoutRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods() async {
    // Les méthodes de paiement sont définies côté client (correspondant
    // aux méthodes supportées par le backend : orange_money, mtn_momo, wave, cash).
    return Right(_paymentMethods);
  }

  @override
  Future<Either<Failure, DeliveryAddress>> getDefaultAddress() async {
    try {
      final data = await _apiClient.get(ApiConstants.addresses);
      final addresses = data as List;

      if (addresses.isEmpty) {
        return const Left(
          NotFoundFailure('Aucune adresse enregistrée'),
        );
      }

      // Chercher l'adresse par défaut, sinon prendre la première
      final defaultAddr = addresses.firstWhere(
        (a) => a['isDefault'] == true,
        orElse: () => addresses.first,
      );

      final map = defaultAddr as Map<String, dynamic>;
      return Right(
        DeliveryAddress(
          id: map['id'].toString(),
          title: map['label'] as String? ?? '',
          detail: map['address'] as String? ?? '',
          city: map['city'] as String? ?? '',
        ),
      );
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderResult>> placeOrder(Checkout checkout) async {
    try {
      final cartItems = checkout.cart.items
          .map(
            (item) => {
              'product_id': int.tryParse(item.product.id) ?? item.product.id,
              'quantity': item.quantity,
              if (item.preparationOption.isNotEmpty)
                'option': item.preparationOption,
            },
          )
          .toList();

      final body = <String, dynamic>{
        'items': cartItems,
        'payment_method': _mapPaymentMethodId(
          checkout.selectedPaymentMethod?.id,
        ),
        if (checkout.deliveryAddress != null)
          'address_id': int.tryParse(checkout.deliveryAddress!.id) ??
              checkout.deliveryAddress!.id,
      };

      final data = await _apiClient.post(ApiConstants.checkout, data: body);
      final map = data as Map<String, dynamic>;

      return Right(
        OrderResult(
          orderId: map['orderId']?.toString() ?? map['id'].toString(),
          checkoutUrl: map['checkoutUrl'] as String?,
          paymentRef: map['paymentRef'] as String?,
        ),
      );
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Map l'ID du PaymentMethod client vers la valeur attendue par le backend.
  String _mapPaymentMethodId(String? id) {
    switch (id) {
      case 'orange_money':
        return 'orange_money';
      case 'mtn_momo':
        return 'mtn_momo';
      case 'wave':
        return 'wave';
      case 'cash':
      default:
        return 'cash';
    }
  }

  static final _paymentMethods = [
    const PaymentMethod(
      id: 'orange_money',
      name: 'Orange Money',
      description: 'Paiement instantané via Orange',
      type: PaymentMethodType.mobileMoney,
      logoUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuANXWmp2XJRxx5dhVeeyfABXfa7MyB0sVjwjhTmmI1Z5Qr7H455sVznhjGAF80b7vSva7BdXz-xUGd5EJ2o1FvhnFKqBuv0wIwrMoDSfvDCv27z-kYmEWNl9ClqzXiBOg6c1q2LyrjP5vg5itAGqpVYai7I3N619I2T6J7cpTdvUts0KgAhhJEkKfmIkyIPOLk8eTA87VvZeAqWcCyAQaWQaVoaPipz14Z887LDhP8E3DHIR2xR0eQJPCo7gTgGJzGdgKx5f3AvFg',
      logoBgColor: 0xFFFFFFFF,
    ),
    const PaymentMethod(
      id: 'mtn_momo',
      name: 'MTN MoMo',
      description: 'Payez avec votre compte MTN',
      type: PaymentMethodType.mobileMoney,
      logoUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDxEX5-zoa6P7nx6Q9Za_B3P1pIkq8Qy_nINHRoyMTr0B2ieol_RCgZOpRPQzvwuyw1w60vYop4-EMjRF98FMbLJNfrnxd0v7GN3dBs7K2eKuTPGK2FO9pI_9ABxm4t8cLpggqg7jWmdKHsaEQ8A6_Fi3U-HmnwXNtCYpfjv5JDeUuGceS6j4exvA6qbIUkSDasEhYA3RJ8FpwINqn7Su7tnLUqGVxFJgCoAf8MQ6GM0Vfb9O_Wmao8nkeIMdCZj9q4HHXAS85HoQ',
      logoBgColor: 0xFFFFCC00,
    ),
    const PaymentMethod(
      id: 'wave',
      name: 'Wave',
      description: "Application Wave Côte d'Ivoire",
      type: PaymentMethodType.mobileMoney,
      logoUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAxRpKG0gPyfNmyrH99QkTLepbLqdYlU_Izo_z48Inpy3hyypr58Liiib7Y_v9qDIqoNC2JC9pXSpy_s6FquVAwkCLaBar796uy7leGse0buRfrKJSvp9s6IXfGSIhB16GwsJg7Nfwxoo67i_VAwlrYHe1X3LZD5NbeIEi8YZIhv0TIAO-fgRxLE6ATPNVnFgYqXqC4MO-qPKh4NAaJfTxt-oF_Oa7VCwp7VVmIh7ffWDU4v90z3zSWXTbIyet-fUIIg66iggBgWw',
      logoBgColor: 0xFF1DA1F2,
    ),
    const PaymentMethod(
      id: 'cash',
      name: 'Paiement à la livraison',
      description: 'Régler en espèces à la réception',
      type: PaymentMethodType.cash,
    ),
  ];
}
