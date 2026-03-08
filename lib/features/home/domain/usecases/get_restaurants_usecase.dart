import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/restaurant_entity.dart';
import '../repositories/home_repository.dart';

class GetRestaurantsUseCase
    implements UseCase<List<RestaurantEntity>, GetRestaurantsParams> {
  final HomeRepository repository;
  GetRestaurantsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RestaurantEntity>>> call(
      GetRestaurantsParams params) {
    return repository.getRestaurants(
      categoryId: params.categoryId,
      searchQuery: params.searchQuery,
      page: params.page,
    );
  }
}

class GetRestaurantsParams extends Equatable {
  final String? categoryId;
  final String? searchQuery;
  final int page;

  const GetRestaurantsParams({
    this.categoryId,
    this.searchQuery,
    this.page = 1,
  });

  @override
  List<Object?> get props => [categoryId, searchQuery, page];
}

class GetCategoriesUseCase implements UseCaseNoParams<List<CategoryEntity>> {
  final HomeRepository repository;
  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call() {
    return repository.getCategories();
  }
}
