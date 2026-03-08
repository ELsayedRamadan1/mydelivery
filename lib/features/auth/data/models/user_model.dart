import '../../domain/entities/user_entity.dart';

/// User Model - طبقة Data
/// يمتد من UserEntity ويضيف طرق التحويل من/إلى JSON
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.photoUrl,
    super.address,
    super.latitude,
    super.longitude,
    required super.createdAt,
    super.isActive,
  });

  /// تحويل من Firestore Document
  factory UserModel.fromFirestore(Map<String, dynamic> map, String id) {
    // created_at might be a Timestamp, String, or int (ms since epoch)
    DateTime createdAt;
    final rawCreated = map['created_at'] ?? map['createdAt'];
    if (rawCreated == null) {
      createdAt = DateTime.now();
    } else if (rawCreated is String) {
      try {
        createdAt = DateTime.parse(rawCreated);
      } catch (_) {
        createdAt = DateTime.now();
      }
    } else if (rawCreated is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(rawCreated);
    } else if (rawCreated is Map && rawCreated['seconds'] != null) {
      // Some serialized timestamps may appear as map
      createdAt = DateTime.fromMillisecondsSinceEpoch((rawCreated['seconds'] as int) * 1000);
    } else {
      try {
        // Firestore Timestamp
        createdAt = (rawCreated as dynamic).toDate();
      } catch (_) {
        createdAt = DateTime.now();
      }
    }

    double? latitude;
    double? longitude;
    final rawLat = map['latitude'] ?? map['lat'];
    final rawLng = map['longitude'] ?? map['lng'] ?? map['long'];
    if (rawLat != null) {
      latitude = (rawLat as num?)?.toDouble();
    }
    if (rawLng != null) {
      longitude = (rawLng as num?)?.toDouble();
    }

    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      photoUrl: map['photo_url'] ?? map['photoUrl'],
      address: map['address'],
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      isActive: map['is_active'] ?? map['isActive'] ?? true,
    );
  }

  /// تحويل إلى Map لحفظه في Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photo_url': photoUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// تحويل من JSON عام
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      photoUrl: json['photo_url'],
      address: json['address'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo_url': photoUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// تحويل من Entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      photoUrl: entity.photoUrl,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      createdAt: entity.createdAt,
      isActive: entity.isActive,
    );
  }
}
