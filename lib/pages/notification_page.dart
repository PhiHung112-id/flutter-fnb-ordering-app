import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../utils/app_colors.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Map<String, dynamic>>> notificationsFuture;

  @override
  void initState() {
    super.initState();
    notificationsFuture = NotificationService().getNotifications();
  }

  Future<void> refreshNotifications() async {
    setState(() {
      notificationsFuture = NotificationService().getNotifications();
    });

    await notificationsFuture;
  }

  Color getNotificationColor(
      BuildContext context,
      String type,
      ) {
    final primary = Theme.of(context).colorScheme.primary;

    switch (type) {
      case 'voucher':
        return primary;
      case 'delivery':
        return Colors.blue;
      case 'combo':
        return Colors.green;
      case 'order':
        return Colors.purple;
      default:
        return primary;
    }
  }

  IconData getNotificationIcon(String iconName, String type) {
    switch (iconName) {
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'delivery_dining':
        return Icons.delivery_dining;
      case 'fastfood':
        return Icons.fastfood;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'local_offer':
        return Icons.local_offer_rounded;
      case 'notifications':
        return Icons.notifications_rounded;
      default:
        switch (type) {
          case 'voucher':
            return Icons.card_giftcard;
          case 'delivery':
            return Icons.delivery_dining;
          case 'combo':
            return Icons.fastfood;
          case 'order':
            return Icons.receipt_long;
          default:
            return Icons.notifications_rounded;
        }
    }
  }

  String formatTime(dynamic rawDate) {
    if (rawDate == null) return '';

    try {
      final date = DateTime.parse(rawDate.toString()).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) {
        return 'Vừa xong';
      }

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} phút trước';
      }

      if (diff.inHours < 24) {
        return '${diff.inHours} giờ trước';
      }

      if (diff.inDays == 1) {
        return 'Hôm qua';
      }

      if (diff.inDays < 7) {
        return '${diff.inDays} ngày trước';
      }

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return '$day/$month/$year';
    } catch (_) {
      return rawDate.toString();
    }
  }

  Future<void> showNotificationDetail(
      BuildContext context,
      Map<String, dynamic> notification,
      ) async {
    final id = notification['id'];
    final type = notification['type']?.toString() ?? 'general';
    final iconName = notification['icon']?.toString() ?? 'notifications';
    final color = getNotificationColor(context, type);
    final icon = getNotificationIcon(iconName, type);

    if (id is int && notification['is_read'] != true) {
      try {
        await NotificationService().markAsRead(id);
        await refreshNotifications();
      } catch (_) {}
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (bottomSheetContext) {
        final primary = Theme.of(bottomSheetContext).colorScheme.primary;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border(bottomSheetContext),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                SizedBox(height: 22),

                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.95),
                        color.withOpacity(0.65),
                        AppColors.darken(color, 0.20),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.22),
                        blurRadius: 16,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  notification['title']?.toString() ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(bottomSheetContext),
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  notification['content']?.toString() ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary(bottomSheetContext),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  formatTime(notification['created_at']),
                  style: TextStyle(
                    color: AppColors.textSecondary(bottomSheetContext),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 22),

                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient(bottomSheetContext),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.22),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(bottomSheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      minimumSize: Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Đã hiểu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int countUnread(List<Map<String, dynamic>> notifications) {
    return notifications.where((item) => item['is_read'] != true).length;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Thông báo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return _NotificationError(
              error: snapshot.error.toString(),
              onRetry: refreshNotifications,
            );
          }

          final notifications = snapshot.data ?? [];
          final unreadCount = countUnread(notifications);

          if (notifications.isEmpty) {
            return RefreshIndicator(
              color: primary,
              backgroundColor: AppColors.card(context),
              onRefresh: refreshNotifications,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SizedBox(height: 80),
                  _EmptyNotification(),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: primary,
            backgroundColor: AppColors.card(context),
            onRefresh: refreshNotifications,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _NotificationHeader(
                  unreadCount: unreadCount,
                ),

                SizedBox(height: 18),

                Text(
                  'Mới nhất',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
                ),

                SizedBox(height: 12),

                ...notifications.map((notification) {
                  final type = notification['type']?.toString() ?? 'general';
                  final iconName =
                      notification['icon']?.toString() ?? 'notifications';
                  final color = getNotificationColor(context, type);
                  final icon = getNotificationIcon(iconName, type);
                  final isRead = notification['is_read'] == true;

                  return _NotificationItem(
                    notification: notification,
                    icon: icon,
                    color: color,
                    isRead: isRead,
                    timeText: formatTime(notification['created_at']),
                    onTap: () => showNotificationDetail(
                      context,
                      notification,
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  final int unreadCount;

  _NotificationHeader({
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(
              AppColors.isDark(context) ? 0.28 : 0.22,
            ),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient(context),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.22),
                ),
              ),
              child: Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 34,
              ),
            ),

            SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cập nhật mới từ Chill Bites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    unreadCount > 0
                        ? 'Bạn có $unreadCount thông báo chưa đọc.'
                        : 'Bạn đã xem hết thông báo mới.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  final IconData icon;
  final Color color;
  final bool isRead;
  final String timeText;
  final VoidCallback onTap;

  _NotificationItem({
    required this.notification,
    required this.icon,
    required this.color,
    required this.isRead,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRead
                ? AppColors.border(context)
                : primary.withOpacity(0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: isRead
                  ? AppColors.shadow(context)
                  : primary.withOpacity(0.12),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(
                  AppColors.isDark(context) ? 0.20 : 0.12,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.22),
                ),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),

            SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title']?.toString() ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.35),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 5),

                  Text(
                    notification['content']?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    timeText,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8),

            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotification extends StatelessWidget {
  _EmptyNotification();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 26),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.border(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.22),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 54,
            ),
          ),

          SizedBox(height: 18),

          Text(
            'Chưa có thông báo',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Khi có ưu đãi, cập nhật đơn hàng hoặc thông tin mới, thông báo sẽ xuất hiện tại đây.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationError extends StatelessWidget {
  final String error;
  final Future<void> Function() onRetry;

  _NotificationError({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border(context),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 14),
              Text(
                'Không tải được thông báo',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  height: 1.35,
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.22),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: Icon(Icons.refresh_rounded),
                  label: Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}