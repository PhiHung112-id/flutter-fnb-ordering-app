import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../utils/format_money.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends ConsumerWidget {
  OrderHistoryPage({super.key});

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String formatOrderCode(int id) {
    return 'Đơn #${id.toString().padLeft(6, '0')}';
  }

  Color getStatusColor(String status, BuildContext context) {
    switch (status) {
      case 'Chờ xác nhận':
      case 'Chờ thanh toán':
      case 'Chờ nhận làm':
      case 'Chờ xác nhận':
      case 'Chờ thanh toán':
      case 'Chờ nhận làm':
      case 'Đang xử lý':
        return Theme.of(context).colorScheme.primary;
      case 'Đã thanh toán':
      case 'Đang chuẩn bị':
      case 'Đang làm':
        return Colors.purple;
      case 'Đang giao':
        return Colors.blue;
      case 'Hoàn thành':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Chờ xác nhận':
      case 'Chờ thanh toán':
      case 'Chờ nhận làm':
      case 'Chờ xác nhận':
      case 'Chờ thanh toán':
      case 'Chờ nhận làm':
      case 'Đang xử lý':
        return Icons.hourglass_top_rounded;
      case 'Đã thanh toán':
      case 'Đang chuẩn bị':
      case 'Đang làm':
        return Icons.restaurant_menu_rounded;
      case 'Đang giao':
        return Icons.delivery_dining_rounded;
      case 'Hoàn thành':
        return Icons.check_circle_rounded;
      case 'Đã hủy':
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  String getImageUrl(Map<String, dynamic> item) {
    final thumbnail = item['thumbnail'] ?? item['product_thumbnail'] ?? '';
    return thumbnail.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Lịch sử đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: orders.isEmpty
          ? _EmptyOrders()
          : RefreshIndicator(
        color: primary,
        backgroundColor: AppColors.card(context),
        onRefresh: () async {
          await ref.read(ordersProvider.notifier).loadOrdersFromSupabase();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _OrderHistoryHeader(
                totalOrders: orders.length,
              );
            }

            final order = orders[index - 1];
            final statusColor = getStatusColor(order.status, context);
            final statusIcon = getStatusIcon(order.status);

            return _OrderHistoryCard(
              orderCode: formatOrderCode(order.id),
              status: order.status,
              statusColor: statusColor,
              statusIcon: statusIcon,
              createdAt: formatDate(order.createdAt),
              itemCount: order.items.length,
              total: order.total,
              items: order.items,
              getImageUrl: getImageUrl,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderDetailPage(order: order),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _OrderHistoryHeader extends StatelessWidget {
  final int totalOrders;

  _OrderHistoryHeader({
    required this.totalOrders,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: BorderRadius.circular(29),
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
          borderRadius: BorderRadius.circular(26),
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
                Icons.receipt_long_rounded,
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
                    'Đơn hàng của bạn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Bạn đã có $totalOrders đơn hàng tại Chill Bites.',
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
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

class _OrderHistoryCard extends StatelessWidget {
  final String orderCode;
  final String status;
  final Color statusColor;
  final IconData statusIcon;
  final String createdAt;
  final int itemCount;
  final double total;
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic> item) getImageUrl;
  final VoidCallback onTap;

  _OrderHistoryCard({
    required this.orderCode,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    required this.createdAt,
    required this.itemCount,
    required this.total,
    required this.items,
    required this.getImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.border(context),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    orderCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),

                SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(
                      AppColors.isDark(context) ? 0.18 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.22),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 14,
                      ),
                      SizedBox(width: 5),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 9),

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary(context),
                ),
                SizedBox(width: 5),
                Text(
                  createdAt,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            if (items.isNotEmpty)
              SizedBox(
                height: 58,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (context, itemIndex) {
                    final item = items[itemIndex];
                    final imageUrl = getImageUrl(item);

                    return _OrderItemImage(
                      imageUrl: imageUrl,
                    );
                  },
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardSoft(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.border(context),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: primary,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đơn hàng chưa có chi tiết món',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 12),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(
                      AppColors.isDark(context) ? 0.20 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primary.withOpacity(0.24),
                    ),
                  ),
                  child: Text(
                    '$itemCount món',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),

                Spacer(),

                Text(
                  formatMoney(total),
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),

                SizedBox(width: 4),

                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemImage extends StatelessWidget {
  final String imageUrl;

  _OrderItemImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: primary.withOpacity(
            AppColors.isDark(context) ? 0.20 : 0.12,
          ),
          border: Border.all(
            color: AppColors.border(context),
          ),
          borderRadius: BorderRadius.circular(13),
        ),
        child: imageUrl.isEmpty
            ? Icon(
          Icons.fastfood,
          color: primary,
        )
            : CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) {
            return Container(
              color: primary.withOpacity(
                AppColors.isDark(context) ? 0.20 : 0.12,
              ),
              child: Icon(
                Icons.fastfood,
                color: primary,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(
                        AppColors.isDark(context) ? 0.24 : 0.20,
                      ),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.white,
                  size: 56,
                ),
              ),

              SizedBox(height: 20),

              Text(
                'Chưa có đơn hàng nào',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Khi bạn đặt món thành công, lịch sử đơn hàng sẽ xuất hiện tại đây.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}