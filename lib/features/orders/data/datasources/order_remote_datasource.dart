import 'package:injectable/injectable.dart' hide Order;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';

/// Remote data source for orders via the backend API.
abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder(Order order);
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<OrderModel> getOrderById(String orderId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Stream<OrderModel> watchOrder(String orderId);
}

@LazySingleton(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSourceImpl(this.apiClient);

  @override
  Future<OrderModel> createOrder(Order order) async {
    // Orders are created via the /checkout endpoint, not directly.
    // This method is kept for interface compatibility.
    throw ServerException('Utilisez le checkout pour créer une commande');
  }

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final data = await apiClient.get(ApiConstants.orders);
      final list = data as List;
      if (list.isNotEmpty) {
        AppLogger.debug('orders[0] raw keys: ${(list.first as Map).keys.toList()}');
        AppLogger.debug('orders[0] raw: ${list.first}');
      }
      return list
          .map(
            (json) => OrderModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.error('getUserOrders raw error: $e\n$st');
      throw ServerException('Erreur lors de la récupération des commandes');
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final data = await apiClient.get(ApiConstants.order(orderId));
      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Erreur lors de la récupération de la commande');
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await apiClient.put(
        '${ApiConstants.order(orderId)}/status',
        data: {'status': status.name},
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Erreur lors de la mise à jour du statut');
    }
  }

  @override
  Stream<OrderModel> watchOrder(String orderId) {
    // Polling-based: the caller can periodically call getOrderById instead.
    // Real-time streaming requires WebSocket which the backend doesn't expose.
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      return await getOrderById(orderId);
    });
  }
}
