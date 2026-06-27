import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_client.dart';

class PaymentService {
  final SupabaseClient supabase = Supabase.instance.client;

  String getCurrentUserId() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập');
    }

    return user.id;
  }

  int toVndAmount(double amount) {
    return amount.round();
  }

  String createPaymentCode(int orderId) {
    return 'CB$orderId';
  }

  String createSePayQrUrl({
    required int orderId,
    required double amount,
  }) {
    final paymentCode = createPaymentCode(orderId);
    final amountVnd = toVndAmount(amount);

    final uri = Uri.https(
      'qr.sepay.vn',
      '/img',
      {
        'acc': '011614088888',
        'bank': 'MBBank',
        'amount': amountVnd.toString(),
        'des': paymentCode,
        'template': 'compact',
        'showinfo': 'true',
        'holder': 'NGUYEN PHI HUNG',
        'store': 'CHILL BITES',
      },
    );

    return uri.toString();
  }

  Future<Map<String, dynamic>> createSePayPayment({
    required int orderId,
    required double amount,
  }) async {
    final userId = getCurrentUserId();

    final data = await ApiClient.post(
      '/api/payments/sepay',
      body: {
        'userId': userId,
        'orderId': orderId,
        'amount': amount,
      },
    );

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return {
      'order_id': orderId,
      'amount': amount,
      'payment_code': createPaymentCode(orderId),
      'qr_url': createSePayQrUrl(orderId: orderId, amount: amount),
      'payment_status': 'pending',
    };
  }

  Future<String> getOrderPaymentStatus(int orderId) async {
    final userId = getCurrentUserId();

    final data = await ApiClient.getMap(
      '/api/payments/orders/$orderId/status',
      queryParameters: {
        'userId': userId,
      },
    );

    return data?['payment_status']?.toString() ?? 'unpaid';
  }

  Future<Map<String, dynamic>?> getOrderPaymentInfo(int orderId) async {
    final userId = getCurrentUserId();

    return ApiClient.getMap(
      '/api/payments/orders/$orderId',
      queryParameters: {
        'userId': userId,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final userId = getCurrentUserId();

    return ApiClient.getList(
      '/api/payment-methods',
      queryParameters: {
        'userId': userId,
      },
    );
  }

  Future<void> addPaymentMethod({
    required String type,
    required String title,
    required String subtitle,
  }) async {
    final userId = getCurrentUserId();

    await ApiClient.post(
      '/api/payment-methods',
      body: {
        'userId': userId,
        'type': type,
        'title': title,
        'subtitle': subtitle,
      },
    );
  }

  Future<void> deletePaymentMethod(int id) async {
    final userId = getCurrentUserId();

    await ApiClient.delete(
      '/api/payment-methods/$id',
      queryParameters: {
        'userId': userId,
      },
    );
  }
}
