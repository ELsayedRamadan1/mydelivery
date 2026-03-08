import 'package:equatable/equatable.dart';

/// User Entity - طبقة Domain
/// لا تعتمد على أي framework خارجي
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String? address;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.isActive = true,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, photoUrl, isActive];
}
