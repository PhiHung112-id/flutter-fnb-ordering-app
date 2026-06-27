import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_client.dart';

class AddressService {
  final supabase = Supabase.instance.client;

  String getCurrentUserId() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập');
    }

    return user.id;
  }

  Future<List<String>> getAddresses() async {
    final userId = getCurrentUserId();
    final data = await ApiClient.getList('/api/customers/$userId/addresses');

    return data
        .map((item) => item['address']?.toString() ?? '')
        .where((address) => address.trim().isNotEmpty)
        .toList();
  }

  Future<void> addAddress(String address) async {
    final userId = getCurrentUserId();

    await ApiClient.post(
      '/api/customers/$userId/addresses',
      body: {
        'title': 'Địa chỉ giao hàng',
        'address': address.trim(),
      },
    );
  }

  Future<void> deleteAddressByText(String address) async {
    final userId = getCurrentUserId();

    await ApiClient.delete(
      '/api/customers/$userId/addresses',
      queryParameters: {
        'address': address.trim(),
      },
    );
  }
}
