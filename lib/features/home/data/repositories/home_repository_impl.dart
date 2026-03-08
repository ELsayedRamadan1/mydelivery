import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<RestaurantEntity>>> getRestaurants({String? categoryId, String? searchQuery, int page = 1}) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final restaurants = await remoteDataSource.getRestaurants(categoryId: categoryId, searchQuery: searchQuery, page: page);
      return Right(restaurants);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, RestaurantEntity>> getRestaurantById(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final restaurant = await remoteDataSource.getRestaurantById(id);
      return Right(restaurant);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getRestaurantProducts(String restaurantId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final products = await remoteDataSource.getRestaurantProducts(restaurantId);
      return Right(products);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }
}
