import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item_entity.dart';

// ===== STATES =====
class CartState extends Equatable {
  final List<CartItemEntity> items;
  final String? restaurantId;
  final String? restaurantName;

  const CartState({
    this.items = const [],
    this.restaurantId,
    this.restaurantName,
  });

  // Calculations
  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => subtotal >= 50 ? 0 : 5;

  double get total => subtotal + deliveryFee;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItemEntity>? items,
    String? restaurantId,
    String? restaurantName,
  }) {
    return CartState(
      items: items ?? this.items,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
    );
  }

  @override
  List<Object?> get props => [items, restaurantId];
}

// ===== CUBIT =====
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addItem(CartItemEntity item) {
    // Check if item from different restaurant
    if (state.restaurantId != null &&
        state.restaurantId != item.restaurantId &&
        state.items.isNotEmpty) {
      // Emit a special state or handle this case
      // For now, clear cart and add new item
      emit(CartState(
        items: [item],
        restaurantId: item.restaurantId,
        restaurantName: item.restaurantName,
      ));
      return;
    }

    final existingIndex =
        state.items.indexWhere((i) => i.productId == item.productId);

    if (existingIndex != -1) {
      // Increment quantity
      final updatedItems = List<CartItemEntity>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      emit(state.copyWith(items: updatedItems));
    } else {
      // Add new item
      emit(CartState(
        items: [...state.items, item],
        restaurantId: item.restaurantId,
        restaurantName: item.restaurantName,
      ));
    }
  }

  void removeItem(String productId) {
    final updatedItems =
        state.items.where((i) => i.productId != productId).toList();
    if (updatedItems.isEmpty) {
      emit(const CartState());
    } else {
      emit(state.copyWith(items: updatedItems));
    }
  }

  void decrementItem(String productId) {
    final existingIndex =
        state.items.indexWhere((i) => i.productId == productId);
    if (existingIndex == -1) return;

    final item = state.items[existingIndex];
    if (item.quantity <= 1) {
      removeItem(productId);
    } else {
      final updatedItems = List<CartItemEntity>.from(state.items);
      updatedItems[existingIndex] =
          item.copyWith(quantity: item.quantity - 1);
      emit(state.copyWith(items: updatedItems));
    }
  }

  void clearCart() => emit(const CartState());
}
