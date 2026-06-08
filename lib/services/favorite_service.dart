import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteService {
  final supabase = Supabase.instance.client;

  String getCurrentUserId() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Báº¡n cáº§n Ä‘Äƒng nháº­p');
    }

    return user.id;
  }

  Future<List<int>> getFavorites() async {
    final userId = getCurrentUserId();

    final data = await supabase
        .from('favorites')
        .select('product_id')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(data).map((item) {
      return (item['product_id'] as num).toInt();
    }).toList();
  }

  Future<void> addFavorite(int productId) async {
    final userId = getCurrentUserId();

    await supabase.from('favorites').upsert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  Future<void> removeFavorite(int productId) async {
    final userId = getCurrentUserId();

    await supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
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


