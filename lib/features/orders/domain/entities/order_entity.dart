import 'package:equatable/equatable.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  onWay,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'في الانتظار';
      case OrderStatus.confirmed:
        return 'تم التأكيد';
      case OrderStatus.preparing:
        return 'قيد التحضير';
      case OrderStatus.onWay:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  int get step {
    switch (this) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.onWay:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }
}

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<CartItemEntity> items;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final String? deliveryPersonId;
  final String? deliveryPersonName;
  final double? deliveryPersonLat;
  final double? deliveryPersonLng;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? notes;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    this.deliveryPersonId,
    this.deliveryPersonName,
    this.deliveryPersonLat,
    this.deliveryPersonLng,
    required this.createdAt,
    this.estimatedDelivery,
    this.notes,
  });

  @override
  List<Object?> get props => [id, status];
}
