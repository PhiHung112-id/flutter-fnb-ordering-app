import 'api_client.dart';

class ProductService {
  int getIntValue(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  double getDoubleValue(dynamic value, {double defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? defaultValue;
  }

  bool getBoolValue(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    final text = value.toString().toLowerCase().trim();
    if (text == 'true' || text == '1' || text == 'yes') return true;
    if (text == 'false' || text == '0' || text == 'no') return false;
    return defaultValue;
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    print('Bắt đầu gọi API categories...');
    final categoriesData = await ApiClient.getList('/api/categories');

    print('Bắt đầu gọi API products...');
    final productsData = await ApiClient.getList('/api/products');

    final Map<int, String> categoryMap = {};

    for (final item in categoriesData) {
      final id = getIntValue(item['id']);
      if (id <= 0) continue;
      categoryMap[id] = item['name']?.toString() ?? '';
    }

    final products = productsData.map((product) {
      final int id = getIntValue(product['id']);
      final int? categoryId = product['categoryId'] == null &&
              product['category_id'] == null
          ? null
          : getIntValue(product['categoryId'] ?? product['category_id']);

      final String title = product['title']?.toString().trim().isNotEmpty == true
          ? product['title'].toString()
          : product['name']?.toString() ?? '';

      final String type = product['type']?.toString() ?? '';

      final String thumbnail = product['thumbnail']?.toString().trim().isNotEmpty == true
          ? product['thumbnail'].toString()
          : product['imageUrl']?.toString().trim().isNotEmpty == true
              ? product['imageUrl'].toString()
              : product['image_url']?.toString() ?? '';

      final imagesRaw = product['images'];
      final List<String> images = imagesRaw is List
          ? imagesRaw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList()
          : thumbnail.trim().isEmpty
              ? <String>[]
              : <String>[thumbnail];

      final bool isActive = getBoolValue(
        product['isActive'] ?? product['is_active'],
        defaultValue: true,
      );

      final bool isAvailable = getBoolValue(
        product['isAvailable'] ?? product['is_available'],
        defaultValue: true,
      );

      final int soldCount = getIntValue(
        product['soldCount'] ?? product['sold_count'],
      );

      final int discountPercent = getIntValue(
        product['discountPercent'] ?? product['discount_percent'],
      );

      final double rating = getDoubleValue(
        product['rating'] ?? product['rate'],
        defaultValue: 0,
      );

      return {
        'id': id,
        'title': title,
        'name': title,
        'category': categoryId == null ? type : (categoryMap[categoryId] ?? type),
        'category_id': categoryId,
        'categoryId': categoryId,
        'type': type,
        'price': getDoubleValue(product['price']),
        'is_active': isActive,
        'isActive': isActive,
        'is_available': isAvailable,
        'isAvailable': isAvailable,
        'rating': rating,
        'rate': rating,
        'review_count': getIntValue(product['reviewCount'] ?? product['review_count']),
        'rating_count': getIntValue(product['ratingCount'] ?? product['rating_count']),
        'isPopular': getBoolValue(product['isPopular'] ?? product['is_popular']),
        'is_popular': getBoolValue(product['isPopular'] ?? product['is_popular']),
        'sold_count': soldCount,
        'soldCount': soldCount,
        'sold': soldCount,
        'total_sold': soldCount,
        'discount_percent': discountPercent,
        'discountPercent': discountPercent,
        'is_new': getBoolValue(product['isNew'] ?? product['is_new']),
        'isNew': getBoolValue(product['isNew'] ?? product['is_new']),
        'is_best_seller': getBoolValue(product['isBestSeller'] ?? product['is_best_seller']),
        'isBestSeller': getBoolValue(product['isBestSeller'] ?? product['is_best_seller']),
        'description': product['description']?.toString() ?? '',
        'thumbnail': thumbnail,
        'imageUrl': thumbnail,
        'image_url': thumbnail,
        'images': images,
        'toppings': product['toppings'] is List ? product['toppings'] : <Map<String, dynamic>>[],
        'recommendedFoodIds': <int>[],
        'recommendedDrinkIds': <int>[],
      };
    }).where((product) {
      return product['is_active'] == true && product['is_available'] == true;
    }).toList();

    final foodIds = products
        .where((item) => item['type'] == 'food' || item['type'] == 'combo')
        .map<int>((item) => item['id'] as int)
        .toList();

    final drinkIds = products
        .where((item) => item['type'] == 'drink')
        .map<int>((item) => item['id'] as int)
        .toList();

    for (final product in products) {
      if (product['type'] == 'drink') {
        product['recommendedFoodIds'] = foodIds.take(3).toList();
        product['recommendedDrinkIds'] = <int>[];
      } else {
        product['recommendedFoodIds'] = <int>[];
        product['recommendedDrinkIds'] = drinkIds.take(3).toList();
      }
    }

    print('Load xong products từ Backend API: ${products.length}');
    return products;
  }

  Future<void> increaseSoldCount({
    required int productId,
    required int qty,
  }) async {
    // Tạm thời chưa chuyển phần tăng sold_count sang API.
    // Sau khi API tạo đơn hàng xong, backend sẽ xử lý sold_count tập trung.
    print('Skip increaseSoldCount on app. productId=$productId qty=$qty');
  }

  Future<void> increaseSoldCountFromOrderItems(
    List<Map<String, dynamic>> items,
  ) async {
    print('Skip increaseSoldCountFromOrderItems on app. items=${items.length}');
  }
}
