import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final response = await supabase
        .from('notifications')
        .select()
        .or('customer_id.is.null,customer_id.eq.${user.id}')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markAsRead(int notificationId) async {
    await supabase
        .from('notifications')
        .update({
      'is_read': true,
    })
        .eq('id', notificationId);
  }
}


