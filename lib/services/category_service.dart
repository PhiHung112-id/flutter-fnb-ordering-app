import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCategories() async {
    final data = await supabase
        .from('categories')
        .select('*')
        .order('id', ascending: true);

    return List<Map<String, dynamic>>.from(data).map((item) {
      return {
        'id': (item['id'] as num).toInt(),
        'name': item['name']?.toString() ?? '',
        'type': item['type']?.toString() ?? '',
        'icon': item['icon']?.toString() ?? '',
        'image_url': item['image_url']?.toString() ?? '',
      };
    }).toList();
  }
}