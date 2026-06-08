import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

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

  Future<List<Map<String, dynamic>>> getProducts() async {
    print('Bắt đầu gọi bảng categories...');
    final categoriesData = await supabase.from('categories').select();

    print('Bắt đầu gọi bảng products...');
    final productsData = await supabase
        .from('products')
        .select()
        .order('id', ascending: true);

    print('Bắt đầu gọi bảng product_images...');
    final imagesData = await supabase.from('product_images').select();

    print('Bắt đầu gọi bảng toppings...');
    final toppingsData = await supabase.from('toppings').select();

    print('Bắt đầu gọi bảng product_toppings...');
    final productToppingsData = await supabase
        .from('product_toppings')
        .select();

    print('Bắt đầu gọi bảng reviews...');
    final reviewsData = await supabase
        .from('reviews')
        .select('product_id, rating');

    final Map<int, String> categoryMap = {};
    final Map<int, Map<String, dynamic>> toppingMap = {};
    final Map<int, List<String>> imagesByProduct = {};
    final Map<int, List<Map<String, dynamic>>> toppingsByProduct = {};

    final Map<int, double> ratingTotalByProduct = {};
    final Map<int, int> ratingCountByProduct = {};

    for (final item in categoriesData) {
      final id = getIntValue(item['id']);

      if (id <= 0) continue;

      categoryMap[id] = item['name']?.toString() ?? '';
    }

    for (final item in toppingsData) {
      final id = getIntValue(item['id']);

      if (id <= 0) continue;

      toppingMap[id] = {
        'id': id,
        'name': item['name']?.toString() ?? '',
        'price': getDoubleValue(item['price']),
        'image': item['image_url']?.toString() ?? '',
        'image_url': item['image_url']?.toString() ?? '',
      };
    }

    for (final image in imagesData) {
      final productId = getIntValue(image['product_id']);
      final imageUrl = image['image_url']?.toString() ?? '';

      if (productId <= 0 || imageUrl.trim().isEmpty) continue;

      imagesByProduct.putIfAbsent(productId, () => []);
      imagesByProduct[productId]!.add(imageUrl);
    }

    for (final item in productToppingsData) {
      final productId = getIntValue(item['product_id']);
      final toppingId = getIntValue(item['topping_id']);

      final topping = toppingMap[toppingId];

      if (productId <= 0 || topping == null) continue;

      toppingsByProduct.putIfAbsent(productId, () => []);
      toppingsByProduct[productId]!.add(topping);
    }

    for (final review in reviewsData) {
      final productId = getIntValue(review['product_id']);
      final rating = getDoubleValue(review['rating']);

      if (productId <= 0 || rating <= 0) continue;

      ratingTotalByProduct[productId] =
          (ratingTotalByProduct[productId] ?? 0) + rating;

      ratingCountByProduct[productId] =
          (ratingCountByProduct[productId] ?? 0) + 1;
    }

    final List<Map<String, dynamic>> products = productsData.map((product) {
      final int id = getIntValue(product['id']);

      final int? categoryId = product['category_id'] == null
          ? null
          : getIntValue(product['category_id']);

      final String thumbnail = product['thumbnail']?.toString() ?? '';

      final List<String> images =
      imagesByProduct[id] == null || imagesByProduct[id]!.isEmpty
          ? thumbnail.trim().isEmpty
          ? <String>[]
          : <String>[thumbnail]
          : imagesByProduct[id]!;

      final int soldCount = getIntValue(product['sold_count']);
      final int discountPercent = getIntValue(product['discount_percent']);

      final int reviewCount = ratingCountByProduct[id] ?? 0;

      final double rating = reviewCount > 0
          ? double.parse(
        ((ratingTotalByProduct[id] ?? 0) / reviewCount)
            .toStringAsFixed(1),
      )
          : 0;

      return {
        'id': id,
        'title': product['title']?.toString() ?? '',
        'category': categoryMap[categoryId] ??
            product['type']?.toString() ??
            '',
        'category_id': categoryId,
        'type': product['type']?.toString() ?? '',
        'price': getDoubleValue(product['price']),

        // Rating tính từ bảng reviews, không gắn cứng 4.8
        'rating': rating,
        'rate': rating,
        'review_count': reviewCount,
        'rating_count': reviewCount,

        'isPopular': product['is_popular'] == true,
        'is_popular': product['is_popular'] == true,

        'sold_count': soldCount,
        'soldCount': soldCount,
        'sold': soldCount,
        'total_sold': soldCount,

        'discount_percent': discountPercent,
        'discountPercent': discountPercent,
        'is_new': product['is_new'] == true,
        'isNew': product['is_new'] == true,
        'is_best_seller': product['is_best_seller'] == true,
        'isBestSeller': product['is_best_seller'] == true,

        'description': product['description']?.toString() ?? '',
        'thumbnail': thumbnail,
        'image_url': thumbnail,
        'images': images,
        'toppings': toppingsByProduct[id] ?? [],
        'recommendedFoodIds': <int>[],
        'recommendedDrinkIds': <int>[],
      };
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

    for (final product in products.take(5)) {
      print(
        'PRODUCT: id=${product['id']} '
            'title=${product['title']} '
            'rating=${product['rating']} '
            'review_count=${product['review_count']} '
            'sold_count=${product['sold_count']}',
      );
    }

    print('Load xong products từ Supabase: ${products.length}');
    return products;
  }

  Future<void> increaseSoldCount({
    required int productId,
    required int qty,
  }) async {
    if (productId <= 0 || qty <= 0) return;

    print('CALL RPC increase_product_sold_count productId=$productId qty=$qty');

    final result = await supabase.rpc(
      'increase_product_sold_count',
      params: {
        'p_product_id': productId,
        'p_qty': qty,
      },
    );

    print('RPC SOLD RESULT: $result');

    final check = await supabase
        .from('products')
        .select('id, title, sold_count')
        .eq('id', productId)
        .maybeSingle();

    print('AFTER SOLD UPDATE: $check');
  }

  Future<void> increaseSoldCountFromOrderItems(
      List<Map<String, dynamic>> items,
      ) async {
    print('ORDER ITEMS TO INCREASE SOLD: $items');

    for (final item in items) {
      final rawProductId = item['productId'] ??
          item['product_id'] ??
          item['id'];

      final rawQty = item['qty'] ??
          item['quantity'] ??
          1;

      final productId = getIntValue(rawProductId);
      final qty = getIntValue(rawQty, defaultValue: 1);

      print('ITEM raw=$item');
      print('PARSED productId=$productId qty=$qty');

      if (productId <= 0 || qty <= 0) continue;

      await increaseSoldCount(
        productId: productId,
        qty: qty,
      );
    }
  }
}