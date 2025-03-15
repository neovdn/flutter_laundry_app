import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import '../../domain/entities/order.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.laundryUniqueName,
    required super.customerUniqueName,
    required super.clothes,
    required super.laundrySpeed,
    required super.vouchers,
    required super.weight,
    required super.status,
    required super.totalPrice,
    required super.createdAt,
    required super.estimatedCompletion,
    super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime getDateTime(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
      return DateTime.now();
    }

    final clothesData = json['clothes'];
    final clothesCount =
        clothesData is List ? clothesData.length : (clothesData as int? ?? 0);

    return OrderModel(
      id: json['id'] as String? ?? '',
      laundryUniqueName: json['laundryUniqueName'] as String? ?? '',
      customerUniqueName: json['customerUniqueName'] as String? ?? '',
      clothes: clothesCount,
      laundrySpeed: json['laundrySpeed'] as String? ?? '',
      vouchers: List<String>.from(json['vouchers'] as List<dynamic>? ?? []),
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      totalPrice: json['totalPrice'] as double? ?? 0,
      createdAt: getDateTime(json['createdAt']),
      estimatedCompletion: getDateTime(json['estimatedCompletion']),
      updatedAt:
          json['updatedAt'] != null ? getDateTime(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'laundryUniqueName': laundryUniqueName,
      'customerUniqueName': customerUniqueName,
      'clothes': clothes,
      'laundrySpeed': laundrySpeed,
      'vouchers': vouchers,
      'weight': weight,
      'status': status,
      'totalPrice': totalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'estimatedCompletion': Timestamp.fromDate(estimatedCompletion),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'laundryUniqueName': laundryUniqueName,
      'customerUniqueName': customerUniqueName,
      'clothes': clothes,
      'laundrySpeed': laundrySpeed,
      'vouchers': vouchers,
      'weight': weight,
      'status': status,
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      'estimatedCompletion': estimatedCompletion.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Updated copyWith to match the Order entity properties
  OrderModel copyWith({
    String? id,
    String? laundryUniqueName,
    String? customerUniqueName,
    int? clothes,
    String? laundrySpeed,
    List<String>? vouchers,
    double? weight,
    String? status,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? estimatedCompletion,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      laundryUniqueName: laundryUniqueName ?? this.laundryUniqueName,
      customerUniqueName: customerUniqueName ?? this.customerUniqueName,
      clothes: clothes ?? this.clothes,
      laundrySpeed: laundrySpeed ?? this.laundrySpeed,
      vouchers: vouchers ?? this.vouchers,
      weight: weight ?? this.weight,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Add equality operators (good practice for entity classes)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          laundryUniqueName == other.laundryUniqueName &&
          customerUniqueName == other.customerUniqueName &&
          clothes == other.clothes &&
          laundrySpeed == other.laundrySpeed &&
          vouchers == other.vouchers &&
          weight == other.weight &&
          status == other.status &&
          totalPrice == other.totalPrice &&
          createdAt == other.createdAt &&
          estimatedCompletion == other.estimatedCompletion &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        laundryUniqueName,
        customerUniqueName,
        clothes,
        laundrySpeed,
        vouchers,
        weight,
        status,
        totalPrice,
        createdAt,
        estimatedCompletion,
        updatedAt,
      );
}
