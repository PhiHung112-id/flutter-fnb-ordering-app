import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final supabase = Supabase.instance.client;

  String getCurrentUserId() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập để đặt hàng');
    }

    return user.id;
  }

  int getIntValue(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? defaultValue;
  }

  double getDoubleValue(dynamic value, {double defaultValue = 0}) {
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? defaultValue;
  }

  Future<int> createOrder({
    required String customerName,
    required String phone,
    required String address,
    required String note,
    required String paymentMethod,
    required double subtotal,
    required double shippingFee,
    required double discount,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    final userId = getCurrentUserId();

    final orderData = await supabase
        .from('orders')
        .insert({
      'user_id': userId,
      'customer_name': customerName,
      'phone': phone,
      'address': address,
      'note': note,
      'payment_method': paymentMethod,
      'status': 'Đang xử lý',
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'discount': discount,
      'total': total,
    })
        .select()
        .single();

    final orderId = (orderData['id'] as num).toInt();

    final orderItems = items.map((item) {
      final productId = item['productId'] ??
          item['product_id'] ??
          item['id'];

      final qty = item['qty'] ??
          item['quantity'] ??
          1;

      return {
        'order_id': orderId,
        'product_id': getIntValue(productId),
        'product_title': item['title'] ??
            item['product_title'] ??
            item['name'] ??
            'Sản phẩm',
        'product_thumbnail': item['thumbnail'] ??
            item['product_thumbnail'] ??
            item['image'] ??
            '',
        'price': getDoubleValue(item['price']),
        'qty': getIntValue(qty, defaultValue: 1),
        'toppings': item['toppings'] ?? [],
      };
    }).where((item) {
      return (item['product_id'] as int) > 0;
    }).toList();

    if (orderItems.isNotEmpty) {
      await supabase.from('order_items').insert(orderItems);
    }

    return orderId;
  }

  Future<List<Map<String, dynamic>>> getMyOrders() async {
    final userId = getCurrentUserId();

    final data = await supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getOrderDetail(int orderId) async {
    final data = await supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .maybeSingle();

    return data;
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    await supabase
        .from('orders')
        .update({
      'status': status,
    })
        .eq('id', orderId);
  }
}