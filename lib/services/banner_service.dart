import 'api_client.dart';

class BannerService {
  Future<List<Map<String, dynamic>>> getBanners() async {
    final data = await ApiClient.getList('/api/banners');

    return data.map((item) {
      return {
        'id': item['id'],
        'title': item['title']?.toString() ?? '',
        'subtitle': item['subtitle']?.toString() ?? '',
        'imageUrl': item['imageUrl']?.toString() ?? item['image_url']?.toString() ?? '',
        'image_url': item['image_url']?.toString() ?? item['imageUrl']?.toString() ?? '',
        'colorHex': item['colorHex']?.toString() ?? item['color_hex']?.toString() ?? '#FF7A00',
        'color_hex': item['color_hex']?.toString() ?? item['colorHex']?.toString() ?? '#FF7A00',
      };
    }).toList();
  }
}
