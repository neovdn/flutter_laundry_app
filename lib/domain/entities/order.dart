class Order {
  final String id;
  final String laundryUniqueName;
  final String customerUniqueName;
  final int clothes;
  final String laundrySpeed;
  final List<String> vouchers;
  final double weight;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime estimatedCompletion;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.laundryUniqueName,
    required this.customerUniqueName,
    required this.clothes,
    required this.laundrySpeed,
    required this.vouchers,
    required this.weight,
    required this.status,
    required this.totalPrice,
    required this.estimatedCompletion,
    required this.createdAt,
    this.updatedAt,
  });
}
