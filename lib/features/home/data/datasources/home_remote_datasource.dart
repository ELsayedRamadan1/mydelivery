import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/restaurant_entity.dart';

abstract class HomeRemoteDataSource {
  Future<List<RestaurantEntity>> getRestaurants({String? categoryId, String? searchQuery, int page = 1});
  Future<List<CategoryEntity>> getCategories();
  Future<RestaurantEntity> getRestaurantById(String id);
  Future<List<ProductEntity>> getRestaurantProducts(String restaurantId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore firestore;
  HomeRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<RestaurantEntity>> getRestaurants({String? categoryId, String? searchQuery, int page = 1}) async {
    Query query = firestore.collection('restaurants').where('is_active', isEqualTo: true);
    if (categoryId != null) query = query.where('category_id', isEqualTo: categoryId);
    final snapshot = await query.limit(10).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return RestaurantEntity(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        imageUrl: data['image_url'] ?? '',
        categoryId: data['category_id'] ?? '',
        categoryName: data['category_name'] ?? '',
        rating: (data['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: data['review_count'] ?? 0,
        deliveryFee: (data['delivery_fee'] as num?)?.toDouble() ?? 5,
        deliveryTimeMin: data['delivery_time_min'] ?? 20,
        deliveryTimeMax: data['delivery_time_max'] ?? 40,
        minOrder: (data['min_order'] as num?)?.toDouble() ?? 10,
        isOpen: data['is_open'] ?? true,
        latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
        address: data['address'] ?? '',
      );
    }).toList();
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final snapshot = await firestore.collection('categories').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CategoryEntity(
        id: doc.id,
        name: data['name'] ?? '',
        iconUrl: data['icon'] ?? '🍔',
        restaurantCount: data['restaurant_count'] ?? 0,
      );
    }).toList();
  }

  @override
  Future<RestaurantEntity> getRestaurantById(String id) async {
    final doc = await firestore.collection('restaurants').doc(id).get();
    final data = doc.data()!;
    return RestaurantEntity(
      id: doc.id, name: data['name'] ?? '', description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '', categoryId: data['category_id'] ?? '',
      categoryName: data['category_name'] ?? '', rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: data['review_count'] ?? 0, deliveryFee: (data['delivery_fee'] as num?)?.toDouble() ?? 5,
      deliveryTimeMin: data['delivery_time_min'] ?? 20, deliveryTimeMax: data['delivery_time_max'] ?? 40,
      minOrder: (data['min_order'] as num?)?.toDouble() ?? 10, isOpen: data['is_open'] ?? true,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0, longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      address: data['address'] ?? '',
    );
  }

  @override
  Future<List<ProductEntity>> getRestaurantProducts(String restaurantId) async {
    final snapshot = await firestore.collection('products')
      .where('restaurant_id', isEqualTo: restaurantId)
      .where('is_available', isEqualTo: true)
      .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProductEntity(
        id: doc.id, restaurantId: restaurantId, name: data['name'] ?? '',
        description: data['description'] ?? '', imageUrl: data['image_url'] ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0,
        discountedPrice: (data['discounted_price'] as num?)?.toDouble(),
        categoryId: data['category_id'] ?? '', isAvailable: data['is_available'] ?? true,
        rating: (data['rating'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }
}
