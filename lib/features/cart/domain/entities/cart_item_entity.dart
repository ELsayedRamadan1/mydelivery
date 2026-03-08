import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String productId;
  final String restaurantId;
  final String restaurantName;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final String? notes;

  const CartItemEntity({
    required this.productId,
    required this.restaurantId,
    required this.restaurantName,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.notes,
  });

  double get totalPrice => price * quantity;

  CartItemEntity copyWith({
    String? productId,
    String? restaurantId,
    String? restaurantName,
    String? name,
    String? imageUrl,
    double? price,
    int? quantity,
    String? notes,
  }) {
    return CartItemEntity(
      productId: productId ?? this.productId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [productId, quantity];
}
