import 'package:boucherie_express/features/auth/domain/entities/user.dart';

/// User model for data layer
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.addresses,
    super.photoUrl,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      name: (json['name'] as String?) ?? 'Utilisateur',
      phone: json['phone'] as String?,
      addresses:
          (json['addresses'] as List<dynamic>?)
              ?.map((e) => (e as Map<String, dynamic>)['id'].toString())
              .toList() ??
          [],
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'addresses': addresses,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      addresses: user.addresses,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
    );
  }
}
