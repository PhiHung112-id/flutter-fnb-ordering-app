import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final supabase = Supabase.instance.client;

  String getCurrentUserId() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Báº¡n cáº§n Ä‘Äƒng nháº­p');
    }

    return user.id;
  }

  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final userId = getCurrentUserId();

    final data = await supabase
        .from('payment_methods')
        .select()
        .eq('user_id', userId)
        .order('id', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> addPaymentMethod({
    required String type,
    required String title,
    required String subtitle,
  }) async {
    final userId = getCurrentUserId();

    await supabase.from('payment_methods').insert({
      'user_id': userId,
      'type': type,
      'title': title,
      'subtitle': subtitle,
    });
  }

  Future<void> deletePaymentMethod(int id) async {
    await supabase.from('payment_methods').delete().eq('id', id);
  }
}


