import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order_model.dart';
import 'api_client.dart';

class OrderService {
  final SupabaseClient supabase = Supabase.instance.client;

  String getCurrentUserId() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập để đặt hàng');
    }

    return user.id;
  }

  int getIntValue(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? defaultValue;
  }

  double getDoubleValue(dynamic value, {double defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? defaultValue;
  }

  List<dynamic> getToppings(dynamic value) {
    if (value == null) return [];
    if (value is List) return value;
    return [];
  }

  bool isSePayPayment(String paymentMethod) {
    final value = paymentMethod.toLowerCase().trim();

    return value == 'sepay' ||
        value == 'sepay vietqr' ||
        value == 'vietqr' ||
        value.contains('sepay') ||
        value.contains('vietqr');
  }

  String normalizePaymentMethod(String paymentMethod) {
    final raw = paymentMethod.trim();

    if (raw.isEmpty) return 'cash';
    if (isSePayPayment(raw)) return 'SePay VietQR';

    return raw;
  }

  Future<int> createOrder({
    required String customerName,
    required String phone,
    required String address,
    required String note,
    required String paymentMethod,
    String orderType = 'delivery',
    required double subtotal,
    required double shippingFee,
    required double discount,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    final userId = getCurrentUserId();

    final cleanItems = items.map((item) {
      final productId = item['productId'] ?? item['product_id'] ?? item['id'];
      final qty = item['qty'] ?? item['quantity'] ?? 1;
      final title = item['title'] ?? item['product_title'] ?? item['name'] ?? 'Sản phẩm';
      final thumbnail = item['thumbnail'] ?? item['product_thumbnail'] ?? item['image'] ?? '';

      return {
        'productId': getIntValue(productId),
        'title': title.toString(),
        'thumbnail': thumbnail.toString(),
        'price': getDoubleValue(item['price']),
        'qty': getIntValue(qty, defaultValue: 1),
        'toppings': getToppings(item['toppings']),
      };
    }).where((item) {
      return getIntValue(item['productId']) > 0;
    }).toList();

    if (cleanItems.isEmpty) {
      throw Exception('Giỏ hàng chưa có sản phẩm hợp lệ');
    }

    final data = await ApiClient.post(
      '/api/orders',
      body: {
        'userId': userId,
        'customerName': customerName.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
        'note': note.trim(),
        'paymentMethod': normalizePaymentMethod(paymentMethod),
        'orderType': orderType.trim().isEmpty ? 'delivery' : orderType.trim(),
        'subtotal': subtotal,
        'shippingFee': shippingFee,
        'discount': discount,
        'total': total,
        'items': cleanItems,
      },
    );

    if (data is Map) {
      return getIntValue(data['id'] ?? data['orderId'] ?? data['order_id']);
    }

    throw Exception('API tạo đơn không trả về mã đơn');
  }

  Future<void> cancelOrder({
    required int orderId,
    String reason = 'Khách hủy đơn',
  }) async {
    final userId = getCurrentUserId();

    await ApiClient.post(
      '/api/customer/orders/$orderId/cancel',
      body: {
        'userId': userId,
        'reason': reason.trim().isEmpty ? 'Khách hủy đơn' : reason.trim(),
      },
    );
  }

  Future<List<OrderModel>> getMyOrders() async {
    final userId = getCurrentUserId();

    final data = await ApiClient.getList(
      '/api/customer/orders',
      queryParameters: {
        'userId': userId,
      },
    );

    return data.map((json) {
      return OrderModel.fromSupabase(json);
    }).toList();
  }

  Future<OrderModel?> getOrderDetail(int orderId) async {
    final userId = getCurrentUserId();

    final data = await ApiClient.getMap(
      '/api/customer/orders/$orderId',
      queryParameters: {
        'userId': userId,
      },
    );

    if (data == null) return null;
    return OrderModel.fromSupabase(data);
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final userId = getCurrentUserId();

    if (status == 'Đã hủy') {
      await cancelOrder(orderId: orderId);
      return;
    }

    await ApiClient.patch(
      '/api/customer/orders/$orderId/status',
      body: {
        'userId': userId,
        'status': status,
      },
    );
  }
}
