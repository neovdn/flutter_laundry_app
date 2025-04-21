import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/voucher.dart';

class VoucherModel extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String type;
  final String obtainMethod;
  final DateTime? validityPeriod;
  final String userId;

  const VoucherModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.obtainMethod,
    this.validityPeriod,
    required this.userId,
  });

  factory VoucherModel.fromEntity(Voucher voucher, String userId) =>
      VoucherModel(
        id: voucher.id,
        name: voucher.name,
        amount: voucher.amount,
        type: voucher.type,
        obtainMethod: voucher.obtainMethod,
        validityPeriod: voucher.validityPeriod,
        userId: userId,
      );

  Voucher toEntity() => Voucher(
        id: id,
        name: name,
        amount: amount,
        type: type,
        obtainMethod: obtainMethod,
        validityPeriod: validityPeriod,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'amount': amount,
        'type': type,
        'obtainMethod': obtainMethod,
        'validityPeriod':
            validityPeriod != null ? Timestamp.fromDate(validityPeriod!) : null,
        'userId': userId,
      };

  factory VoucherModel.fromJson(Map<String, dynamic> data, String id) {
    return VoucherModel(
      id: id,
      name: data['name']?.toString() ?? 'Unknown',
      amount: (data['amount'] is num ? data['amount'].toDouble() : 0.0),
      type: data['type']?.toString() ?? 'Unknown',
      obtainMethod: data['obtainMethod']?.toString() ?? 'Unknown',
      validityPeriod: data['validityPeriod'] != null
          ? (data['validityPeriod'] is Timestamp
              ? (data['validityPeriod'] as Timestamp).toDate()
              : null)
          : null,
      userId: data['userId']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props =>
      [id, name, amount, type, obtainMethod, validityPeriod, userId];
}
