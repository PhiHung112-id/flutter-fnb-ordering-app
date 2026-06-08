class OrderModel {
  final int id;
  final List<Map<String, dynamic>> items;
  final double total;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  OrderModel copyWith({
    int? id,
    List<Map<String, dynamic>>? items,
    double? total,
    String? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


