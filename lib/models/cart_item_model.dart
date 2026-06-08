class CartItem {
  final int id;
  final int qty;
  final List<String> toppings;
  final double toppingPrice;

  CartItem({
    required this.id,
    required this.qty,
    this.toppings = const [],
    this.toppingPrice = 0,
  });

  String get key {
    final sortedToppings = [...toppings]..sort();
    return '$id-${sortedToppings.join(",")}';
  }

  CartItem copyWith({
    int? id,
    int? qty,
    List<String>? toppings,
    double? toppingPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      qty: qty ?? this.qty,
      toppings: toppings ?? this.toppings,
      toppingPrice: toppingPrice ?? this.toppingPrice,
    );
  }
}