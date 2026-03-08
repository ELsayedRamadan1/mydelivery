import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

class GetOrdersUseCase implements UseCase<List<OrderEntity>, GetOrdersParams> {
  final OrdersRepository repository;
  GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(GetOrdersParams params) {
    return repository.getOrders(userId: params.userId);
  }
}

class GetOrdersParams extends Equatable {
  final String userId;
  const GetOrdersParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

class PlaceOrderUseCase implements UseCase<OrderEntity, PlaceOrderParams> {
  final OrdersRepository repository;
  PlaceOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(PlaceOrderParams params) {
    return repository.placeOrder(params: params);
  }
}

class PlaceOrderParams extends Equatable {
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<CartItemEntity> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final String? notes;

  const PlaceOrderParams({
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    this.notes,
  });

  @override
  List<Object?> get props => [userId, restaurantId];
}
