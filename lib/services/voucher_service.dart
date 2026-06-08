import 'package:supabase_flutter/supabase_flutter.dart';

class VoucherService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getVouchers() async {
    print('Bắt đầu gọi bảng vouchers...');

    final data = await supabase
        .from('vouchers')
        .select()
        .eq('is_active', true)
        .order('id', ascending: true);

    print('Raw vouchers Supabase: $data');

    final vouchers = List<Map<String, dynamic>>.from(data).map((item) {
      return {
        'id': item['id'],
        'code': item['code']?.toString() ?? '',
        'title': item['title']?.toString() ?? '',
        'description': item['description']?.toString() ?? '',
        'discount': (item['discount'] as num?)?.toDouble() ?? 0,
        'minOrder': (item['min_order'] as num?)?.toDouble() ?? 0,
        'isActive': item['is_active'] == true,
      };
    }).toList();

    print('Load xong vouchers từ Supabase: ${vouchers.length}');

    return vouchers;
  }
}