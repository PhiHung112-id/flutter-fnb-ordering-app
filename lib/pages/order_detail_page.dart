import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_model.dart';
import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../utils/format_money.dart';
import 'review_page.dart';

String formatOrderCode(int id) {
  return id.toString().padLeft(6, '0');
}

class OrderDetailPage extends ConsumerWidget {
  final OrderModel order;

  const OrderDetailPage({
    super.key,
    required this.order,
  });

  bool isCashPayment(String paymentMethod) {
    final value = paymentMethod.toLowerCase().trim();

    return value.isEmpty ||
        value == 'cash' ||
        value.contains('tiền mặt') ||
        value.contains('tien mat') ||
        value.contains('cod') ||
        value.contains('nhận hàng') ||
        value.contains('nhan hang');
  }

  bool isSePayPayment(String paymentMethod) {
    final value = paymentMethod.toLowerCase().trim();

    return value == 'sepay' ||
        value == 'vietqr' ||
        value.contains('sepay') ||
        value.contains('vietqr') ||
        value.contains('qr');
  }

  Color getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'Chờ xác nhận':
      case 'Chờ thanh toán':
      case 'Chờ nhận làm':
      case 'Đang xử lý':
        return Theme.of(context).colorScheme.primary;
      case 'Đã xác nhận':
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
      case 'Đang xử lý':
        return Icons.hourglass_top_rounded;
      case 'Đã xác nhận':
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

  String getFormattedDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} - '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
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
      const SnackBar(
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
              onPressed: () async {
                await ref
                    .read(ordersProvider.notifier)
                    .cancelOrder(order.id);

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
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
              child: const Text(
                'Hủy đơn',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSupport(BuildContext context, OrderModel currentOrder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
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
                const SizedBox(height: 18),
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
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Hỗ trợ đơn hàng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(bottomSheetContext),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mã đơn #${formatOrderCode(currentOrder.id)}',
                  style: TextStyle(
                    color: AppColors.textSecondary(bottomSheetContext),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                _SupportOption(
                  icon: Icons.phone,
                  title: 'Gọi hotline',
                  subtitle: '1900 1234',
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
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
                      const SnackBar(
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
                      const SnackBar(
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
    final hasReviewed = reviews.any(
          (review) => review.orderId == currentOrder.id,
    );

    final paymentMethod = currentOrder.paymentMethod.trim().isEmpty
        ? 'cash'
        : currentOrder.paymentMethod;

    final isCash = isCashPayment(paymentMethod);
    final isOnline = !isCash;

    final canCancel = currentOrder.status == 'Chờ xác nhận' || currentOrder.status == 'Chờ thanh toán' || currentOrder.status == 'Đang xử lý';
    final canReview = currentOrder.status == 'Hoàn thành' && !hasReviewed;

    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: primary,
        backgroundColor: AppColors.card(context),
        onRefresh: () async {
          await ref.read(ordersProvider.notifier).loadOrdersFromSupabase();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _OrderStatusCard(
              orderId: currentOrder.id,
              status: currentOrder.status,
              statusColor: statusColor,
              statusIcon: statusIcon,
              createdAt: getFormattedDate(currentOrder.createdAt),
            ),

            const SizedBox(height: 14),

            _PaymentNoticeCard(
              isCash: isCash,
              isOnline: isOnline,
              paymentMethod: paymentMethod,
              orderStatus: currentOrder.status,
            ),

            const SizedBox(height: 14),

            _OrderActionCard(
              canCancel: canCancel,
              onCancel: () {
                confirmCancelOrder(context, ref, currentOrder);
              },
              onReorder: () {
                reorder(context, ref, currentOrder);
              },
            ),

            if (hasReviewed) ...[
              const SizedBox(height: 14),
              _ReviewSummaryCard(orderId: currentOrder.id),
            ],

            const SizedBox(height: 14),

            _DeliveryAddressCard(
              customerName: currentOrder.customerName,
              phone: currentOrder.phone,
              address: currentOrder.address,
              note: currentOrder.note,
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: 'Danh sách món',
              child: currentOrder.items.isEmpty
                  ? _EmptyOrderItems()
                  : Column(
                children: currentOrder.items.map((item) {
                  return _OrderProductItem(item: item);
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: 'Chi phí đơn hàng',
              child: Column(
                children: [
                  _PriceRow(
                    title: 'Tạm tính',
                    value: formatMoney(
                      currentOrder.subtotal > 0
                          ? currentOrder.subtotal
                          : currentOrder.total,
                    ),
                  ),
                  _PriceRow(
                    title: 'Phí giao hàng',
                    value: currentOrder.shippingFee > 0
                        ? formatMoney(currentOrder.shippingFee)
                        : 'Đã bao gồm',
                  ),
                  _PriceRow(
                    title: 'Voucher',
                    value: currentOrder.discount > 0
                        ? '-${formatMoney(currentOrder.discount)}'
                        : 'Không áp dụng',
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

            const SizedBox(height: 14),

            _PaymentInfoCard(
              paymentMethod: paymentMethod,
              orderStatus: currentOrder.status,
            ),

            const SizedBox(height: 14),

            _OrderTimelineCard(
              status: currentOrder.status,
              createdAt: getFormattedDate(currentOrder.createdAt),
              paymentMethod: currentOrder.paymentMethod,
            ),

            const SizedBox(height: 90),
          ],
        ),
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
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => showSupport(context, currentOrder),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Hỗ trợ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient:
                    canReview ? AppColors.primaryGradient(context) : null,
                    color: canReview ? null : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (canReview)
                        BoxShadow(
                          color: primary.withOpacity(0.22),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: canReview
                        ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReviewPage(
                            order: currentOrder,
                          ),
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
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      currentOrder.status == 'Đã hủy'
                          ? 'Không thể đánh giá'
                          : hasReviewed
                          ? 'Đã đánh giá'
                          : currentOrder.status != 'Hoàn thành'
                          ? 'Chờ hoàn thành'
                          : 'Đánh giá',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

class _PaymentNoticeCard extends StatelessWidget {
  final bool isCash;
  final bool isOnline;
  final String paymentMethod;
  final String orderStatus;

  const _PaymentNoticeCard({
    required this.isCash,
    required this.isOnline,
    required this.paymentMethod,
    required this.orderStatus,
  });

  bool get isCancelled => orderStatus == 'Đã hủy';

  @override
  Widget build(BuildContext context) {
    final color = isCancelled
        ? Colors.red
        : isCash
        ? Colors.orange
        : Colors.teal;

    final icon = isCancelled
        ? Icons.cancel_outlined
        : isCash
        ? Icons.local_shipping_outlined
        : Icons.verified_rounded;

    final title = isCancelled
        ? 'Đơn hàng đã hủy'
        : isCash
        ? 'Thanh toán khi giao hàng'
        : 'Đã thanh toán online';

    final description = isCancelled
        ? 'Đơn hàng này đã bị hủy, thanh toán không còn hiệu lực.'
        : isCash
        ? 'Bạn chỉ cần thanh toán tiền mặt cho shipper khi nhận món.'
        : 'Thanh toán QR đã được xác nhận. Cửa hàng sẽ tiếp tục xử lý và giao đơn.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(
          AppColors.isDark(context) ? 0.18 : 0.10,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.28),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(
              AppColors.isDark(context) ? 0.26 : 0.14,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  const _OrderStatusCard({
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
            offset: const Offset(0, 8),
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn #${orderId.toString().padLeft(6, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    createdAt,
                    style: const TextStyle(
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

  const _OrderActionCard({
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
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Hủy đơn'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                disabledForegroundColor: Colors.grey,
                side: BorderSide(
                  color: canCancel ? Colors.red : AppColors.border(context),
                ),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onReorder,
                icon: const Icon(Icons.refresh),
                label: const Text('Mua lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 48),
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

class _DeliveryAddressCard extends StatelessWidget {
  final String customerName;
  final String phone;
  final String address;
  final String note;

  const _DeliveryAddressCard({
    required this.customerName,
    required this.phone,
    required this.address,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final displayName =
    customerName.trim().isEmpty ? 'Khách hàng Chill Bites' : customerName;
    final displayPhone = phone.trim().isEmpty ? 'Chưa có số điện thoại' : phone;
    final displayAddress =
    address.trim().isEmpty ? 'Chưa có địa chỉ giao hàng' : address;

    return _SectionCard(
      title: 'Thông tin nhận hàng',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_outline,
            iconColor: primary,
            title: 'Người nhận',
            value: displayName,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.phone_outlined,
            iconColor: primary,
            title: 'Số điện thoại',
            value: displayPhone,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.location_on_outlined,
            iconColor: primary,
            title: 'Địa chỉ giao hàng',
            value: displayAddress,
          ),
          if (note.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.notes_outlined,
              iconColor: primary,
              title: 'Ghi chú',
              value: note,
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentInfoCard extends StatelessWidget {
  final String paymentMethod;
  final String orderStatus;

  const _PaymentInfoCard({
    required this.paymentMethod,
    required this.orderStatus,
  });

  bool isCashPayment() {
    final value = paymentMethod.toLowerCase().trim();

    return value.isEmpty ||
        value == 'cash' ||
        value.contains('tiền mặt') ||
        value.contains('tien mat') ||
        value.contains('cod') ||
        value.contains('nhận hàng') ||
        value.contains('nhan hang');
  }

  bool isSePayPayment() {
    final value = paymentMethod.toLowerCase().trim();

    return value == 'sepay' ||
        value == 'vietqr' ||
        value.contains('sepay') ||
        value.contains('vietqr') ||
        value.contains('qr');
  }

  String getPaymentTitle() {
    if (isCashPayment()) {
      return 'Tiền mặt';
    }

    if (isSePayPayment()) {
      return 'SePay VietQR';
    }

    switch (paymentMethod) {
      case 'wallet':
        return 'Ví điện tử';
      case 'visa':
        return 'Thẻ Visa';
      default:
        return paymentMethod.trim().isEmpty ? 'Tiền mặt' : paymentMethod;
    }
  }

  String getPaymentStatus() {
    if (orderStatus == 'Đã hủy') {
      return 'Đã hủy';
    }

    if (isCashPayment()) {
      return 'Thanh toán khi giao hàng';
    }

    return 'Đã thanh toán online';
  }

  String getPaymentNote() {
    if (orderStatus == 'Đã hủy') {
      return 'Đơn đã hủy nên thanh toán không còn hiệu lực.';
    }

    if (isCashPayment()) {
      return 'Bạn thanh toán trực tiếp cho shipper khi nhận món.';
    }

    return 'Đơn đã được xác nhận thanh toán. Cửa hàng tiếp tục xử lý và giao hàng.';
  }

  IconData getPaymentIcon() {
    if (isCashPayment()) {
      return Icons.local_shipping_outlined;
    }

    if (isSePayPayment()) {
      return Icons.qr_code_2_rounded;
    }

    if (paymentMethod == 'visa') {
      return Icons.credit_card;
    }

    if (paymentMethod == 'wallet') {
      return Icons.account_balance_wallet_outlined;
    }

    return Icons.payments_outlined;
  }

  Color getPaymentColor(BuildContext context) {
    if (orderStatus == 'Đã hủy') {
      return Colors.red;
    }

    if (isCashPayment()) {
      return Colors.orange;
    }

    if (isSePayPayment()) {
      return Colors.teal;
    }

    if (paymentMethod == 'visa') {
      return Colors.blue;
    }

    if (paymentMethod == 'wallet') {
      return Colors.purple;
    }

    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final color = getPaymentColor(context);

    return _SectionCard(
      title: 'Thông tin thanh toán',
      child: Column(
        children: [
          _InfoRow(
            icon: getPaymentIcon(),
            iconColor: color,
            title: 'Phương thức',
            value: getPaymentTitle(),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: orderStatus == 'Đã hủy'
                ? Icons.cancel_outlined
                : isCashPayment()
                ? Icons.schedule_rounded
                : Icons.check_circle_outline,
            iconColor: color,
            title: 'Trạng thái thanh toán',
            value: getPaymentStatus(),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.info_outline,
            iconColor: color,
            title: 'Ghi chú',
            value: getPaymentNote(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: iconColor.withOpacity(
            AppColors.isDark(context) ? 0.22 : 0.13,
          ),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlainCard extends StatelessWidget {
  final Widget child;

  const _PlainCard({
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
            offset: const Offset(0, 5),
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

  const _SectionCard({
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
            offset: const Offset(0, 5),
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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _EmptyOrderItems extends StatelessWidget {
  const _EmptyOrderItems();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSoft(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(context),
        ),
      ),
      child: Text(
        'Đơn hàng chưa có chi tiết món.',
        style: TextStyle(
          color: AppColors.textSecondary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OrderProductItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _OrderProductItem({
    required this.item,
  });

  double getDoubleValue(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  int getIntValue(dynamic value) {
    if (value == null) return 0;
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

  List<String> getToppings() {
    final rawToppings = item['toppings'];

    if (rawToppings == null) return [];

    if (rawToppings is List) {
      return rawToppings.map((e) {
        if (e is Map) {
          final name = e['name'] ?? e['title'] ?? e['topping_name'];
          return name?.toString() ?? '';
        }

        return e.toString();
      }).where((e) {
        return e.trim().isNotEmpty;
      }).toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final price = getDoubleValue(item['price']);
    final qty = getIntValue(item['qty'] ?? item['quantity'] ?? 1);
    final total = price * qty;
    final imageUrl = getImageUrl();
    final toppings = getToppings();

    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: const Icon(
                      Icons.fastfood,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                if (toppings.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Topping: ${toppings.join(', ')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 5),
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
          const SizedBox(width: 8),
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

  const _PriceRow({
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
          const Spacer(),
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
  final String paymentMethod;

  const _OrderTimelineCard({
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
  });

  bool isCashPayment() {
    final value = paymentMethod.toLowerCase().trim();

    return value.isEmpty ||
        value == 'cash' ||
        value.contains('tiền mặt') ||
        value.contains('tien mat') ||
        value.contains('cod') ||
        value.contains('nhận hàng') ||
        value.contains('nhan hang');
  }

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
    final cash = isCashPayment();

    if (status == 'Đã hủy') {
      return _SectionCard(
        title: 'Tiến trình đơn hàng',
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
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
            subtitle: cash
                ? 'Nhân viên đang xác nhận đơn, bạn sẽ thanh toán khi nhận hàng'
                : 'Thanh toán đã xác nhận, nhân viên đang xử lý đơn',
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
            subtitle: cash
                ? 'Shipper đang giao món đến bạn, vui lòng thanh toán khi nhận hàng'
                : 'Shipper đang giao món đến bạn',
            isActive: currentStep >= 3,
            isLast: false,
          ),
          _TimelineItem(
            title: 'Hoàn thành',
            subtitle: cash
                ? 'Đơn hàng hoàn tất sau khi giao và thu tiền'
                : 'Đơn hàng đã hoàn tất',
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

  const _TimelineItem({
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
                  ? const Icon(
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
        const SizedBox(width: 12),
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
                const SizedBox(height: 4),
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

  const _SupportOption({
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

  const _ReviewSummaryCard({
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final review =
    ref.read(reviewsProvider.notifier).getReviewByOrderId(orderId);

    if (review == null) {
      return const SizedBox.shrink();
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
          const SizedBox(height: 10),
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