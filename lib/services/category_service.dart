import 'api_client.dart';

class CategoryService {
  int getIntValue(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final data = await ApiClient.getList('/api/categories');

    return data.map((item) {
      final imageUrl = item['imageUrl']?.toString() ??
          item['image_url']?.toString() ??
          '';

      return {
        'id': getIntValue(item['id']),
        'name': item['name']?.toString() ?? '',
        'type': item['type']?.toString() ?? '',
        'icon': item['icon']?.toString() ?? '',
        'imageUrl': imageUrl,
        'image_url': imageUrl,
      };
    }).toList();
  }
}
