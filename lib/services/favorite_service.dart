import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_client.dart';

class FavoriteService {
  final supabase = Supabase.instance.client;

  String getCurrentUserId() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập');
    }

    return user.id;
  }

  int getIntValue(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  Future<List<int>> getFavorites() async {
    final userId = getCurrentUserId();
    final data = await ApiClient.getList('/api/customers/$userId/favorites');

    return data
        .map((item) => getIntValue(item['product_id'] ?? item['productId']))
        .where((id) => id > 0)
        .toList();
  }

  Future<void> addFavorite(int productId) async {
    final userId = getCurrentUserId();

    await ApiClient.post(
      '/api/customers/$userId/favorites',
      body: {
        'productId': productId,
      },
    );
  }

  Future<void> removeFavorite(int productId) async {
    final userId = getCurrentUserId();

    await ApiClient.delete(
      '/api/customers/$userId/favorites/$productId',
    );
  }

  Future<void> toggleFavorite({
    required int productId,
    required bool isFavorite,
  }) async {
    if (isFavorite) {
      await removeFavorite(productId);
    } else {
      await addFavorite(productId);
    }
  }
}
