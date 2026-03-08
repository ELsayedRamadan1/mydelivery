import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrdersRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders({required String userId}) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final orders = await remoteDataSource.getOrders(userId: userId);
      return Right(orders);
    } catch (e) {
      return const Left(ServerFailure(message: 'فشل تحميل الطلبات'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> placeOrder({required PlaceOrderParams params}) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final order = await remoteDataSource.placeOrder(params: params);
      return Right(order);
    } catch (e) {
      return const Left(ServerFailure(message: 'فشل إرسال الطلب'));
    }
  }

  @override
  Stream<OrderEntity> watchOrder(String orderId) => remoteDataSource.watchOrder(orderId);
}
