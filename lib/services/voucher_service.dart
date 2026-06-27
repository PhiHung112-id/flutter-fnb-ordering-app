import 'api_client.dart';

class VoucherService {
  double getDoubleValue(dynamic value, {double defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? defaultValue;
  }

  Future<List<Map<String, dynamic>>> getVouchers() async {
    final data = await ApiClient.getList('/api/vouchers');

    return data.map((item) {
      return {
        'id': item['id'],
        'code': item['code']?.toString() ?? '',
        'title': item['title']?.toString() ?? '',
        'description': item['description']?.toString() ?? '',
        'discount': getDoubleValue(item['discount']),
        'minOrder': getDoubleValue(item['minOrder'] ?? item['min_order']),
        'min_order': getDoubleValue(item['minOrder'] ?? item['min_order']),
        'isActive': item['isActive'] == true || item['is_active'] == true,
        'is_active': item['isActive'] == true || item['is_active'] == true,
      };
    }).toList();
  }
}
