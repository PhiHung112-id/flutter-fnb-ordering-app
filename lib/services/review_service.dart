import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getReviewsByProductId(int productId) async {
    final data = await supabase
        .from('reviews')
        .select()
        .eq('product_id', productId)
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(data).map((item) {
      return {
        'id': item['id'],
        'productId': item['product_id'],
        'orderId': item['order_id'],
        'userId': item['user_id']?.toString() ?? '',
        'customerName': item['customer_name']?.toString() ?? 'Khách hàng',
        'customerAvatar': item['customer_avatar']?.toString() ?? '',
        'rating': item['rating'] is num
            ? (item['rating'] as num).toDouble()
            : double.tryParse(item['rating'].toString()) ?? 0,
        'content': item['content']?.toString() ?? '',
        'createdAt': item['created_at']?.toString() ?? '',
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

    await supabase.from('reviews').insert({
      'user_id': user.id,
      'product_id': productId,
      'order_id': orderId,
      'customer_name': customerName,
      'customer_avatar': customerAvatar,
      'rating': rating,
      'content': content,
    });
  }

  Future<double> updateProductRating(int productId) async {
    final data = await supabase
        .from('reviews')
        .select('rating')
        .eq('product_id', productId);

    final reviews = List<Map<String, dynamic>>.from(data);

    if (reviews.isEmpty) {
      await supabase
          .from('products')
          .update({
        'rating': 0,
      })
          .eq('id', productId);

      return 0;
    }

    double total = 0;

    for (final review in reviews) {
      final value = review['rating'];

      if (value is num) {
        total += value.toDouble();
      } else {
        total += double.tryParse(value.toString()) ?? 0;
      }
    }

    final average = total / reviews.length;
    final roundedAverage = double.parse(average.toStringAsFixed(1));

    await supabase
        .from('products')
        .update({
      'rating': roundedAverage,
    })
        .eq('id', productId);

    return roundedAverage;
  }
}