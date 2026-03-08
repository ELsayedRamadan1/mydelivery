import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_orders_usecase.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderEntity>> getOrders({required String userId});
  Future<OrderEntity> placeOrder({required PlaceOrderParams params});
  Stream<OrderEntity> watchOrder(String orderId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final FirebaseFirestore firestore;
  OrdersRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<OrderEntity>> getOrders({required String userId}) async {
    await firestore
        .collection('orders')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();
    // TODO: Map documents to OrderEntity
    return [];
  }

  @override
  Future<OrderEntity> placeOrder({required PlaceOrderParams params}) async {
    // TODO: Implement place order logic
    throw UnimplementedError();
  }

  @override
  Stream<OrderEntity> watchOrder(String orderId) {
    // TODO: Implement real-time order watching
    throw UnimplementedError();
  }
}
