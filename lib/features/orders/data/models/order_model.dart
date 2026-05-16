import 'package:boucherie_express/features/orders/domain/entities/order.dart';

/// Order model for data layer
class OrderModel extends Order {
  const OrderModel({
    required super.id,
    super.userId,
    super.userName,
    super.userPhone,
    required super.items,
    required super.totalPrice,
    required super.deliveryFee,
    required super.totalAmount,
    required super.deliveryAddress,
    required super.status,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.orderedAt,
    super.note,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'].toString(),
      userId: json['userId']?.toString() ?? '',
      userName: json['userName'] as String?,
      userPhone: json['userPhone'] as String?,
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => OrderItem(
              productId: item['productId'].toString(),
              productName: item['productName'] as String,
              price: (item['price'] as num).toDouble(),
              quantity: item['quantity'] as int,
              option: item['option'] as String? ?? '',
              imageUrl: item['imageUrl'] as String?,
            ),
          )
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryAddress: (json['deliveryAddress'] as String?) ?? '',
      status: OrderStatus.values.byName(json['status'] as String),
      paymentMethod: _parsePaymentMethod(
        json['paymentMethod'] as String? ?? 'cash',
      ),
      paymentStatus: json['paymentStatus'] as String,
      orderedAt: json['orderedAt'] != null
          ? DateTime.parse(json['orderedAt'] as String)
          : DateTime.now(),
      note: json['note'] as String?,
    );
  }

  static PaymentMethod _parsePaymentMethod(String value) {
    switch (value) {
      case 'orange_money':
        return PaymentMethod.orangeMoney;
      case 'mtn_momo':
        return PaymentMethod.moovMoney;
      default:
        return PaymentMethod.values.byName(value);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'items': items
          .map(
            (item) => {
              'productId': item.productId,
              'productName': item.productName,
              'price': item.price,
              'quantity': item.quantity,
              'option': item.option,
              'imageUrl': item.imageUrl,
            },
          )
          .toList(),
      'totalPrice': totalPrice,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus,
      'orderedAt': orderedAt.toIso8601String(),
      'note': note,
    };
  }
}
