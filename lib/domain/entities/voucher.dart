import 'package:equatable/equatable.dart';

class Voucher extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String type;
  final String obtainMethod;
  final DateTime? validityPeriod;

  const Voucher({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.obtainMethod,
    this.validityPeriod,
  });

  @override
  List<Object?> get props =>
      [id, name, amount, type, obtainMethod, validityPeriod];
}
