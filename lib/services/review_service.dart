import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_client.dart';

class ReviewService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getReviewsByProductId(int productId) async {
    final data = await ApiClient.getList('/api/products/$productId/reviews');

    return data.map((item) {
      return {
        'id': item['id'],
        'productId': item['productId'] ?? item['product_id'],
        'product_id': item['product_id'] ?? item['productId'],
        'orderId': item['orderId'] ?? item['order_id'],
        'order_id': item['order_id'] ?? item['orderId'],
        'userId': item['userId']?.toString() ?? item['user_id']?.toString() ?? '',
        'user_id': item['user_id']?.toString() ?? item['userId']?.toString() ?? '',
        'customerName': item['customerName']?.toString() ?? item['customer_name']?.toString() ?? 'Khách hàng',
        'customer_name': item['customer_name']?.toString() ?? item['customerName']?.toString() ?? 'Khách hàng',
        'customerAvatar': item['customerAvatar']?.toString() ?? item['customer_avatar']?.toString() ?? '',
        'customer_avatar': item['customer_avatar']?.toString() ?? item['customerAvatar']?.toString() ?? '',
        'rating': item['rating'] is num ? (item['rating'] as num).toDouble() : double.tryParse(item['rating'].toString()) ?? 0,
        'content': item['content']?.toString() ?? '',
        'createdAt': item['createdAt']?.toString() ?? item['created_at']?.toString() ?? '',
        'created_at': item['created_at']?.toString() ?? item['createdAt']?.toString() ?? '',
      };
    }).toList();
  }

  Future<void> addReview({
    required int productId,
    required int orderId,
    required String customerName,
    String customerAvatar = '',
    required double rating,
    required String content,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập để đánh giá');
    }

    await ApiClient.post(
      '/api/reviews',
      body: {
        'userId': user.id,
        'productId': productId,
        'orderId': orderId,
        'customerName': customerName,
        'customerAvatar': customerAvatar,
        'rating': rating,
        'content': content,
      },
    );
  }

  Future<double> updateProductRating(int productId) async {
    final data = await ApiClient.post('/api/products/$productId/reviews/recalculate');

    if (data is Map) {
      final value = data['rating'];
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return 0;
  }
}
