import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../usecases/get_orders_usecase.dart';

abstract class OrdersRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders({required String userId});
  Future<Either<Failure, OrderEntity>> placeOrder({required PlaceOrderParams params});
  Stream<OrderEntity> watchOrder(String orderId);
}
