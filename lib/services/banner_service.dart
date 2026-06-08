import 'package:supabase_flutter/supabase_flutter.dart';

class BannerService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getBanners() async {
    final data = await supabase
        .from('banners')
        .select()
        .eq('is_active', true)
        .order('id', ascending: true);

    return List<Map<String, dynamic>>.from(data).map((item) {
      return {
        'id': item['id'],
        'title': item['title']?.toString() ?? '',
        'subtitle': item['subtitle']?.toString() ?? '',
        'imageUrl': item['image_url']?.toString() ?? '',
        'colorHex': item['color_hex']?.toString() ?? '#FF7A00',
      };
    }).toList();
  }
}


