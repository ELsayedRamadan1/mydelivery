import 'package:equatable/equatable.dart';

class RestaurantEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String categoryId;
  final String categoryName;
  final double rating;
  final int reviewCount;
  final double deliveryFee;
  final int deliveryTimeMin; // minutes
  final int deliveryTimeMax;
  final double minOrder;
  final bool isOpen;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> tags;

  const RestaurantEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.rating,
    required this.reviewCount,
    required this.deliveryFee,
    required this.deliveryTimeMin,
    required this.deliveryTimeMax,
    required this.minOrder,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.tags = const [],
  });

  String get deliveryTimeText => '$deliveryTimeMin-$deliveryTimeMax دقيقة';

  @override
  List<Object?> get props => [id, name, isOpen];
}

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconUrl;
  final int restaurantCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.restaurantCount,
  });

  @override
  List<Object?> get props => [id, name];
}

class ProductEntity extends Equatable {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double? discountedPrice;
  final String categoryId;
  final bool isAvailable;
  final List<String> ingredients;
  final double rating;

  const ProductEntity({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.discountedPrice,
    required this.categoryId,
    required this.isAvailable,
    this.ingredients = const [],
    this.rating = 0.0,
  });

  double get effectivePrice => discountedPrice ?? price;
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;

  @override
  List<Object?> get props => [id, name, price];
}
