import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/restaurant_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<RestaurantEntity>>> getRestaurants({
    String? categoryId,
    String? searchQuery,
    int page = 1,
  });

  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, RestaurantEntity>> getRestaurantById(String id);

  Future<Either<Failure, List<ProductEntity>>> getRestaurantProducts(
      String restaurantId);
}
