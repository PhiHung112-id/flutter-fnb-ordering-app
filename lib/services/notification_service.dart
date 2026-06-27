import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_client.dart';

class NotificationService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final data = await ApiClient.getList('/api/customers/${user.id}/notifications');

    return data.map((item) {
      final type = item['type']?.toString() ?? item['notification_type']?.toString() ?? 'info';

      return {
        'id': item['id']?.toString() ?? item['notification_id']?.toString() ?? '',
        'notification_id': item['notification_id']?.toString() ?? item['id']?.toString() ?? '',
        'title': item['title']?.toString() ?? '',
        'body': item['body']?.toString() ?? '',
        'type': type,
        'notification_type': item['notification_type']?.toString() ?? type,
        'icon': item['icon']?.toString() ?? 'notifications',
        'order_id': item['order_id']?.toString() ?? '',
        'is_read': item['is_read'] == true,
        'created_at': item['created_at']?.toString() ?? '',
      };
    }).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    final user = supabase.auth.currentUser;

    if (user == null || notificationId.trim().isEmpty) return;

    await ApiClient.patch(
      '/api/customers/${user.id}/notifications/$notificationId/read',
    );
  }
}
