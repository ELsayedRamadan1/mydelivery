import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/usecases/get_restaurants_usecase.dart';

// ===== STATES =====
abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<RestaurantEntity> restaurants;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final String? searchQuery;

  HomeLoaded({
    required this.restaurants,
    required this.categories,
    this.selectedCategoryId,
    this.searchQuery,
  });

  HomeLoaded copyWith({
    List<RestaurantEntity>? restaurants,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    String? searchQuery,
  }) {
    return HomeLoaded(
      restaurants: restaurants ?? this.restaurants,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props =>
      [restaurants, categories, selectedCategoryId, searchQuery];
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// ===== CUBIT =====
class HomeCubit extends Cubit<HomeState> {
  final GetRestaurantsUseCase getRestaurantsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  HomeCubit({
    required this.getRestaurantsUseCase,
    required this.getCategoriesUseCase,
  }) : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());

    // Load categories and restaurants in parallel
    final results = await Future.wait([
      getCategoriesUseCase(),
      getRestaurantsUseCase(const GetRestaurantsParams()),
    ]);

    final categoriesResult = results[0];
    final restaurantsResult = results[1];

    // Check for failures
    if (categoriesResult.isLeft() || restaurantsResult.isLeft()) {
      String errorMsg = '';
      categoriesResult.fold((f) => errorMsg = f.message, (_) {});
      restaurantsResult.fold((f) => errorMsg = f.message, (_) {});
      emit(HomeError(errorMsg));
      return;
    }

    final categories = categoriesResult.getOrElse(() => []) as List<CategoryEntity>;
    final restaurants = restaurantsResult.getOrElse(() => []) as List<RestaurantEntity>;

    emit(HomeLoaded(
      restaurants: restaurants,
      categories: categories,
    ));
  }

  Future<void> filterByCategory(String? categoryId) async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    // Optimistically update UI
    emit(current.copyWith(selectedCategoryId: categoryId));

    final result = await getRestaurantsUseCase(
      GetRestaurantsParams(categoryId: categoryId),
    );

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (restaurants) => emit(current.copyWith(
        restaurants: restaurants,
        selectedCategoryId: categoryId,
      )),
    );
  }

  Future<void> search(String query) async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    final result = await getRestaurantsUseCase(
      GetRestaurantsParams(searchQuery: query.isEmpty ? null : query),
    );

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (restaurants) => emit(current.copyWith(
        restaurants: restaurants,
        searchQuery: query,
      )),
    );
  }
}
