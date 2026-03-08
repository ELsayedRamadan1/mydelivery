import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/place_order_usecase.dart';

// States
abstract class OrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}
class OrdersLoading extends OrdersState {}
class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  OrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}
class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
  @override
  List<Object?> get props => [message];
}
class OrderPlacing extends OrdersState {}
class OrderPlaced extends OrdersState {
  final OrderEntity order;
  OrderPlaced(this.order);
}

// Cubit
class OrdersCubit extends Cubit<OrdersState> {
  final GetOrdersUseCase getOrdersUseCase;
  final PlaceOrderUseCase placeOrderUseCase;

  OrdersCubit({
    required this.getOrdersUseCase,
    required this.placeOrderUseCase,
  }) : super(OrdersInitial());

  Future<void> loadOrders(String userId) async {
    emit(OrdersLoading());
    final result = await getOrdersUseCase(GetOrdersParams(userId: userId));
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  Future<void> placeOrder(PlaceOrderParams params) async {
    emit(OrderPlacing());
    final result = await placeOrderUseCase(params);
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (order) => emit(OrderPlaced(order)),
    );
  }
}
