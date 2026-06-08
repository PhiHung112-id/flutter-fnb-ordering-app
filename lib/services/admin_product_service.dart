import 'package:supabase_flutter/supabase_flutter.dart';

class AdminProductService {
  final supabase = Supabase.instance.client;

  Future<void> createProduct({
    required int categoryId,
    required String title,
    required String description,
    required String type,
    required double price,
    required String thumbnail,
    required double rating,
    required bool isPopular,
  }) async {
    await supabase.from('products').insert({
      'category_id': categoryId,
      'title': title,
      'description': description,
      'type': type,
      'price': price,
      'thumbnail': thumbnail,
      'rating': rating,
      'is_popular': isPopular,
    });
  }

  Future<void> updateProduct({
    required int productId,
    required int categoryId,
    required String title,
    required String description,
    required String type,
    required double price,
    required String thumbnail,
    required double rating,
    required bool isPopular,
  }) async {
    await supabase.from('products').update({
      'category_id': categoryId,
      'title': title,
      'description': description,
      'type': type,
      'price': price,
      'thumbnail': thumbnail,
      'rating': rating,
      'is_popular': isPopular,
    }).eq('id', productId);
  }

  Future<void> deleteProduct(int productId) async {
    await supabase.from('products').delete().eq('id', productId);
  }
}


