import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.role,
    required super.fullName,
    required super.uniqueName,
    required super.email,
    required super.phoneNumber,
    required super.address,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      role: json['role'],
      fullName: json['fullName'],
      uniqueName: json['uniqueName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'fullName': fullName,
      'uniqueName': uniqueName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      role: user.role,
      fullName: user.fullName,
      uniqueName: user.uniqueName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      address: user.address,
      createdAt: user.createdAt,
    );
  }
}
