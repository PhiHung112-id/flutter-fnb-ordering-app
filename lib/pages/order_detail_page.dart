import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_model.dart';
import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../utils/format_money.dart';
import 'review_page.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';

String formatOrderCode(int id) {
  return id.toString().padLeft(6, '0');
}

class OrderDetailPage extends ConsumerWidget {
  final OrderModel order;

  OrderDetailPage({
    super.key,
    required this.order,
  });

  Color getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'Đang xử lý':
        return Theme.of(context).colorScheme.primary;
      case 'Đang chuẩn bị':
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
      case 'Đang xử lý':
        return Icons.hourglass_top_rounded;
      case 'Đang chuẩn bị':
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

  String getFormattedDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} - '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Đang xử lý':
        return 'Đang chuẩn bị';
      case 'Đang chuẩn bị':
        return 'Đang giao';
      case 'Đang giao':
        return 'Hoàn thành';
      default:
        return currentStatus;
    }
  }

  Future<void> updateOrderProgress(
      BuildContext context,
      WidgetRef ref,
      OrderModel order,
      ) async {
    if (order.status == 'Đã hủy') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đơn hàng đã hủy, không thể cập nhật trạng thái'),
        ),
      );
      return;
    }

    if (order.status == 'Hoàn thành') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đơn hàng đã hoàn thành'),
        ),
      );
      return;
    }

    final nextStatus = getNextStatus(order.status);

    await ref.read(ordersProvider.notifier).updateOrderStatus(
      order.id,
      nextStatus,
    );

    int earnedPoints = 0;

    if (nextStatus == 'Hoàn thành') {
      try {
        await ProductService().increaseSoldCountFromOrderItems(order.items);

        earnedPoints = await AuthService().addCustomerPoints(order.total);

        await ref.read(customerProfileProvider.notifier).loadProfile();
        await ref.read(productsProvider.notifier).refreshFromSupabase();
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đơn hoàn thành nhưng lỗi cập nhật dữ liệu: $e'),
          ),
        );
        return;
      }
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nextStatus == 'Hoàn thành'
              ? 'Đơn hàng đã hoàn thành! Bạn được cộng $earnedPoints điểm.'
              : 'Đã cập nhật trạng thái: $nextStatus',
        ),
      ),
    );
  }

  void reorder(BuildContext context, WidgetRef ref, OrderModel order) {
    for (final item in order.items) {
      final rawProductId = item['productId'] ?? item['product_id'];
      final rawQty = item['qty'] ?? item['quantity'] ?? 1;

      final productId = rawProductId is int
          ? rawProductId
          : int.tryParse(rawProductId.toString()) ?? 0;

      final qty = rawQty is int ? rawQty : int.tryParse(rawQty.toString()) ?? 1;

      if (productId <= 0) continue;

      for (int i = 0; i < qty; i++) {
        ref.read(cartItemsProvider.notifier).addToCart(productId);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm lại các món vào giỏ hàng'),
      ),
    );
  }

  void confirmCancelOrder(
      BuildContext context,
      WidgetRef ref,
      OrderModel order,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card(dialogContext),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Hủy đơn hàng',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(dialogContext),
            ),
          ),
          content: Text(
            'Bạn có chắc muốn hủy đơn hàng này không?',
            style: TextStyle(
              color: AppColors.textSecondary(dialogContext),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Không',
                style: TextStyle(
                  color: AppColors.textSecondary(dialogContext),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(ordersProvider.notifier)
                    .updateOrderStatus(order.id, 'Đã hủy');

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đơn hàng đã được hủy'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Hủy đơn',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (bottomSheetContext) {
        final primary = Theme.of(bottomSheetContext).colorScheme.primary;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border(bottomSheetContext),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                SizedBox(height: 18),

                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient(bottomSheetContext),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.22),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 38,
                  ),
                ),

                SizedBox(height: 14),

                Text(
                  'Hỗ trợ đơn hàng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(bottomSheetContext),
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Mã đơn #${formatOrderCode(order.id)}',
                  style: TextStyle(
                    color: AppColors.textSecondary(bottomSheetContext),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 18),

                _SupportOption(
                  icon: Icons.phone,
                  title: 'Gọi hotline',
                  subtitle: '1900 1234',
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tính năng gọi hotline sẽ kết nối sau'),
                      ),
                    );
                  },
                ),
                _SupportOption(
                  icon: Icons.chat_bubble_outline,
                  title: 'Nhắn tin hỗ trợ',
                  subtitle: 'Trao đổi với nhân viên cửa hàng',
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tính năng chat sẽ phát triển sau'),
                      ),
                    );
                  },
                ),
                _SupportOption(
                  icon: Icons.report_problem_outlined,
                  title: 'Báo sự cố đơn hàng',
                  subtitle: 'Thiếu món, giao trễ hoặc sai món',
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã ghi nhận yêu cầu hỗ trợ'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    final currentOrder = orders.firstWhere(
          (item) => item.id == order.id,
      orElse: () => order,
    );

    final statusColor = getStatusColor(context, currentOrder.status);
    final statusIcon = getStatusIcon(currentOrder.status);
    final reviews = ref.watch(reviewsProvider);
    final hasReviewed =
    reviews.any((review) => review.orderId == currentOrder.id);

    final canCancel = currentOrder.status == 'Đang xử lý';
    final canReview = currentOrder.status != 'Đã hủy' && !hasReviewed;

    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Chi tiết đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _OrderStatusCard(
            orderId: currentOrder.id,
            status: currentOrder.status,
            statusColor: statusColor,
            statusIcon: statusIcon,
            createdAt: getFormattedDate(currentOrder.createdAt),
          ),

          SizedBox(height: 14),

          _OrderActionCard(
            canCancel: canCancel,
            onCancel: () {
              confirmCancelOrder(context, ref, currentOrder);
            },
            onReorder: () {
              reorder(context, ref, currentOrder);
            },
          ),

          SizedBox(height: 14),

          _OrderProgressActionCard(
            status: currentOrder.status,
            onUpdateStatus: () async {
              await updateOrderProgress(context, ref, currentOrder);
            },
          ),

          if (hasReviewed) ...[
            SizedBox(height: 14),
            _ReviewSummaryCard(orderId: currentOrder.id),
          ],

          SizedBox(height: 14),

          _DeliveryAddressCard(),

          SizedBox(height: 14),

          _SectionCard(
            title: 'Danh sách món',
            child: Column(
              children: currentOrder.items.map((item) {
                return _OrderProductItem(item: item);
              }).toList(),
            ),
          ),

          SizedBox(height: 14),

          _SectionCard(
            title: 'Thanh toán',
            child: Column(
              children: [
                _PriceRow(
                  title: 'Tạm tính',
                  value: formatMoney(currentOrder.total),
                ),
                _PriceRow(
                  title: 'Phí giao hàng',
                  value: 'Đã bao gồm',
                ),
                _PriceRow(
                  title: 'Voucher',
                  value: 'Đã áp dụng nếu có',
                ),
                Divider(
                  color: AppColors.border(context),
                ),
                _PriceRow(
                  title: 'Tổng thanh toán',
                  value: formatMoney(currentOrder.total),
                  isTotal: true,
                ),
              ],
            ),
          ),

          SizedBox(height: 14),

          _OrderTimelineCard(
            status: currentOrder.status,
            createdAt: getFormattedDate(currentOrder.createdAt),
          ),

          SizedBox(height: 90),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          border: Border(
            top: BorderSide(
              color: AppColors.border(context),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.isDark(context)
                  ? Colors.black.withOpacity(0.50)
                  : primary.withOpacity(0.10),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => showSupport(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary),
                    minimumSize: Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Hỗ trợ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SizedBox(width: 10),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: canReview ? AppColors.primaryGradient(context) : null,
                    color: canReview ? null : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (canReview)
                        BoxShadow(
                          color: primary.withOpacity(0.22),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: canReview
                        ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ReviewPage(order: currentOrder),
                        ),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: Colors.grey.shade300,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      minimumSize: Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      currentOrder.status == 'Đã hủy'
                          ? 'Không thể đánh giá'
                          : hasReviewed
                          ? 'Đã đánh giá'
                          : 'Đánh giá',
                      style: TextStyle(fontWeight: FontWeight.bold),
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

class _OrderStatusCard extends StatelessWidget {
  final int orderId;
  final String status;
  final Color statusColor;
  final IconData statusIcon;
  final String createdAt;

  _OrderStatusCard({
    required this.orderId,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    required this.createdAt,
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
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.22),
                ),
              ),
              child: Icon(
                statusIcon,
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
                    'Đơn #${orderId.toString().padLeft(6, '0')}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    createdAt,
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderActionCard extends StatelessWidget {
  final bool canCancel;
  final VoidCallback onCancel;
  final VoidCallback onReorder;

  _OrderActionCard({
    required this.canCancel,
    required this.onCancel,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return _PlainCard(
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: canCancel ? onCancel : null,
              icon: Icon(Icons.cancel_outlined),
              label: Text('Hủy đơn'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                disabledForegroundColor: Colors.grey,
                side: BorderSide(
                  color: canCancel ? Colors.red : AppColors.border(context),
                ),
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.18),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onReorder,
                icon: Icon(Icons.refresh),
                label: Text('Mua lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderProgressActionCard extends StatelessWidget {
  final String status;
  final VoidCallback onUpdateStatus;

  _OrderProgressActionCard({
    required this.status,
    required this.onUpdateStatus,
  });

  bool get canUpdate {
    return status != 'Đã hủy' && status != 'Hoàn thành';
  }

  String get buttonText {
    if (status == 'Đã hủy') return 'Đơn đã hủy';
    if (status == 'Hoàn thành') return 'Đã hoàn thành';
    return 'Cập nhật';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return _PlainCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: canUpdate
                ? primary.withOpacity(
              AppColors.isDark(context) ? 0.22 : 0.13,
            )
                : AppColors.cardSoft(context),
            child: Icon(
              Icons.update,
              color: canUpdate ? primary : AppColors.textSecondary(context),
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'Trạng thái: $status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: canUpdate ? AppColors.primaryGradient(context) : null,
              color: canUpdate ? null : Colors.grey.shade600,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              onPressed: canUpdate ? onUpdateStatus : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.transparent,
                disabledForegroundColor: Colors.grey.shade300,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryAddressCard extends StatelessWidget {
  _DeliveryAddressCard();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return _SectionCard(
      title: 'Địa chỉ giao hàng',
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primary.withOpacity(
              AppColors.isDark(context) ? 0.22 : 0.13,
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: primary,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '123 Nguyễn Văn Tiết, Thuận An, Bình Dương',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainCard extends StatelessWidget {
  final Widget child;

  _PlainCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _OrderProductItem extends StatelessWidget {
  final Map<String, dynamic> item;

  _OrderProductItem({
    required this.item,
  });

  double getDoubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return 0;
  }

  int getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String getImageUrl() {
    final thumbnail = item['thumbnail'] ?? item['product_thumbnail'] ?? '';
    return thumbnail.toString();
  }

  String getTitle() {
    return (item['title'] ?? item['product_title'] ?? 'Món ăn').toString();
  }

  @override
  Widget build(BuildContext context) {
    final price = getDoubleValue(item['price']);
    final qty = getIntValue(item['qty'] ?? item['quantity'] ?? 1);
    final total = price * qty;
    final imageUrl = getImageUrl();
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: primary.withOpacity(
                  AppColors.isDark(context) ? 0.20 : 0.12,
                ),
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
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient(context),
                    ),
                    child: Icon(
                      Icons.fastfood,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTitle(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '${formatMoney(price)} x $qty',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Text(
            formatMoney(total),
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isTotal;

  _PriceRow({
    required this.title,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor = isTotal
        ? Theme.of(context).colorScheme.primary
        : AppColors.textPrimary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 17 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textSecondary(context),
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: isTotal ? 17 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTimelineCard extends StatelessWidget {
  final String status;
  final String createdAt;

  _OrderTimelineCard({
    required this.status,
    required this.createdAt,
  });

  int getCurrentStepIndex() {
    switch (status) {
      case 'Đang xử lý':
        return 1;
      case 'Đang chuẩn bị':
        return 2;
      case 'Đang giao':
        return 3;
      case 'Hoàn thành':
        return 4;
      case 'Đã hủy':
        return -1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = getCurrentStepIndex();

    if (status == 'Đã hủy') {
      return _SectionCard(
        title: 'Tiến trình đơn hàng',
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Đơn hàng đã bị hủy',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _SectionCard(
      title: 'Tiến trình đơn hàng',
      child: Column(
        children: [
          _TimelineItem(
            title: 'Đơn hàng đã được tạo',
            subtitle: createdAt,
            isActive: currentStep >= 1,
            isLast: false,
          ),
          _TimelineItem(
            title: 'Cửa hàng đang xử lý',
            subtitle: 'Nhân viên đang xác nhận đơn',
            isActive: currentStep >= 1,
            isLast: false,
          ),
          _TimelineItem(
            title: 'Đang chuẩn bị món',
            subtitle: 'Món đang được chuẩn bị tại cửa hàng',
            isActive: currentStep >= 2,
            isLast: false,
          ),
          _TimelineItem(
            title: 'Đang giao hàng',
            subtitle: 'Shipper đang giao món đến bạn',
            isActive: currentStep >= 3,
            isLast: false,
          ),
          _TimelineItem(
            title: 'Hoàn thành',
            subtitle: 'Đơn hàng đã hoàn tất',
            isActive: currentStep >= 4,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isLast;

  _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final lineColor = isActive ? primary : AppColors.border(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: lineColor,
              child: isActive
                  ? Icon(
                Icons.check,
                color: Colors.white,
                size: 13,
              )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: lineColor,
              ),
          ],
        ),

        SizedBox(width: 12),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isActive
                        ? AppColors.textPrimary(context)
                        : AppColors.textSecondary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SupportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _SupportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: primary.withOpacity(
          AppColors.isDark(context) ? 0.22 : 0.13,
        ),
        child: Icon(
          icon,
          color: primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary(context),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary(context),
      ),
    );
  }
}

class _ReviewSummaryCard extends ConsumerWidget {
  final int orderId;

  _ReviewSummaryCard({
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final review = ref.read(reviewsProvider.notifier).getReviewByOrderId(orderId);

    if (review == null) {
      return SizedBox.shrink();
    }

    return _SectionCard(
      title: 'Đánh giá của bạn',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) {
              final isSelected = index < review.rating;

              return Icon(
                isSelected ? Icons.star : Icons.star_border,
                color: Colors.amber.shade700,
                size: 22,
              );
            }),
          ),
          SizedBox(height: 10),
          Text(
            review.comment,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}