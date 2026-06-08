import 'package:supabase_flutter/supabase_flutter.dart';

class AddressService {
  final supabase = Supabase.instance.client;

  String getCurrentUserId() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Báº¡n cáº§n Ä‘Äƒng nháº­p');
    }

    return user.id;
  }

  Future<List<String>> getAddresses() async {
    final userId = getCurrentUserId();

    final data = await supabase
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(data).map((item) {
      return item['address'].toString();
    }).toList();
  }

  Future<void> addAddress(String address) async {
    final userId = getCurrentUserId();

    await supabase.from('addresses').insert({
      'user_id': userId,
      'title': 'Äá»‹a chá»‰ giao hÃ ng',
      'address': address,
    });
  }

  Future<void> deleteAddressByText(String address) async {
    final userId = getCurrentUserId();

    await supabase
        .from('addresses')
        .delete()
        .eq('user_id', userId)
        .eq('address', address);
  }
}


