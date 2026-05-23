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
      userId: (json['user_id'] ?? json['userId'])?.toString() ?? '',
      userName: (json['user_name'] ?? json['userName']) as String?,
      userPhone: (json['user_phone'] ?? json['userPhone']) as String?,
      items: ((json['items'] ?? json['order_items']) as List<dynamic>? ?? [])
          .map(
            (item) => OrderItem(
              productId: (item['product_id'] ?? item['productId'] ?? '').toString(),
              productName: (item['product_name'] ?? item['productName'] ?? '') as String,
              price: ((item['price'] ?? item['unit_price'] ?? 0) as num).toDouble(),
              quantity: (item['quantity'] ?? 1) as int,
              option: item['option'] as String? ?? '',
              imageUrl: (item['image_url'] ?? item['imageUrl']) as String?,
            ),
          )
          .toList(),
      totalPrice: ((json['total_price'] ?? json['totalPrice'] ?? 0) as num).toDouble(),
      deliveryFee: ((json['delivery_fee'] ?? json['deliveryFee'] ?? 0) as num).toDouble(),
      totalAmount: ((json['total_amount'] ?? json['totalAmount'] ?? 0) as num).toDouble(),
      deliveryAddress: (json['delivery_address'] ?? json['deliveryAddress'] ?? '') as String,
      status: _parseStatus((json['status'] as String?) ?? 'pending'),
      paymentMethod: _parsePaymentMethod(
        (json['payment_method'] ?? json['paymentMethod']) as String? ?? 'cash',
      ),
      paymentStatus: (json['payment_status'] ?? json['paymentStatus'] ?? '') as String,
      orderedAt: (json['ordered_at'] ?? json['orderedAt'] ?? json['created_at']) != null
          ? DateTime.parse(
              (json['ordered_at'] ?? json['orderedAt'] ?? json['created_at']) as String,
            )
          : DateTime.now(),
      note: json['note'] as String?,
    );
  }

  static OrderStatus _parseStatus(String value) {
    switch (value) {
      case 'pending': return OrderStatus.pending;
      case 'confirmed': return OrderStatus.confirmed;
      case 'preparing': return OrderStatus.preparing;
      case 'out_for_delivery':
      case 'delivering': return OrderStatus.delivering;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }

  static PaymentMethod _parsePaymentMethod(String value) {
    switch (value) {
      case 'orange_money':
        return PaymentMethod.orangeMoney;
      case 'mtn_momo':
        return PaymentMethod.moovMoney;
      case 'wave':
        return PaymentMethod.orangeMoney;
      case 'cash':
        return PaymentMethod.cash;
      default:
        return PaymentMethod.cash;
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
