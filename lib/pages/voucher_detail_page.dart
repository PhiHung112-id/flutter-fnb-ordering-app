import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item_model.dart';
import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../utils/format_money.dart';

class VoucherDetailPage extends ConsumerWidget {
  final Map<String, dynamic> voucher;

  VoucherDetailPage({
    super.key,
    required this.voucher,
  });

  String get code => voucher['code']?.toString() ?? '';
  String get title => voucher['title']?.toString() ?? '';
  String get description => voucher['description']?.toString() ?? '';

  double get discount {
    final value = voucher['discount'];

    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  double get minOrder {
    final value = voucher['minOrder'];

    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  double getDoubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  Map<String, dynamic>? findProductById(
      List<Map<String, dynamic>> products,
      int productId,
      ) {
    for (final product in products) {
      if (product['id'] == productId) {
        return product;
      }
    }

    return null;
  }

  double calculateSubtotal({
    required List<Map<String, dynamic>> products,
    required List<CartItem> cartItems,
  }) {
    double subtotal = 0;

    for (final cartItem in cartItems) {
      final product = findProductById(products, cartItem.id);

      if (product == null) continue;

      final price = getDoubleValue(product['price']);

      subtotal += (price + cartItem.toppingPrice) * cartItem.qty;
    }

    return subtotal;
  }

  Color getVoucherColor(BuildContext context) {
    final lowerTitle = title.toLowerCase();
    final lowerCode = code.toLowerCase();

    if (lowerCode.contains('ship') || lowerTitle.contains('ship')) {
      return Colors.blue;
    }

    if (lowerTitle.contains('combo') || lowerCode.contains('combo')) {
      return Colors.green;
    }

    return Theme.of(context).colorScheme.primary;
  }

  IconData getVoucherIcon() {
    final lowerTitle = title.toLowerCase();
    final lowerCode = code.toLowerCase();

    if (lowerCode.contains('ship') || lowerTitle.contains('ship')) {
      return Icons.delivery_dining_rounded;
    }

    if (lowerTitle.contains('combo') || lowerCode.contains('combo')) {
      return Icons.fastfood_rounded;
    }

    return Icons.card_giftcard_rounded;
  }

  void copyCode(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: code),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã copy mã $code'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void applyVoucher({
    required BuildContext context,
    required WidgetRef ref,
    required double subtotal,
  }) {
    if (subtotal < minOrder) {
      final missing = minOrder - subtotal;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đơn hàng cần thêm ${formatMoney(missing)} để áp dụng voucher $code',
          ),
        ),
      );

      return;
    }

    ref.read(selectedVoucherProvider.notifier).selectVoucher(code);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã áp dụng voucher $code'),
        duration: Duration(seconds: 1),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = getVoucherColor(context);
    final selectedVoucher = ref.watch(selectedVoucherProvider);
    final products = ref.watch(productsProvider);
    final cartItems = ref.watch(cartItemsProvider);

    final subtotal = calculateSubtotal(
      products: products,
      cartItems: cartItems,
    );

    final isSelected = selectedVoucher == code;
    final isEligible = subtotal >= minOrder;
    final missingAmount = minOrder - subtotal;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Chi tiết voucher',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _VoucherHeroCard(
            color: color,
            icon: getVoucherIcon(),
            title: title,
            description: description,
            code: code,
            isSelected: isSelected,
            isEligible: isEligible,
          ),

          SizedBox(height: 20),

          _CartConditionCard(
            color: color,
            subtotal: subtotal,
            minOrder: minOrder,
            isEligible: isEligible,
            missingAmount: missingAmount > 0 ? missingAmount : 0,
          ),

          _InfoCard(
            icon: Icons.rule_rounded,
            title: 'Điều kiện áp dụng',
            content: minOrder <= 0
                ? 'Áp dụng cho mọi đơn hàng hợp lệ.'
                : 'Áp dụng cho đơn hàng từ ${formatMoney(minOrder)}.',
            color: color,
          ),

          _InfoCard(
            icon: Icons.payments_outlined,
            title: 'Giá trị giảm',
            content: 'Giảm ${formatMoney(discount)} khi thanh toán.',
            color: color,
          ),

          _InfoCard(
            icon: Icons.confirmation_number_outlined,
            title: 'Mã voucher',
            content: code,
            color: color,
          ),

          _InfoCard(
            icon: Icons.info_outline_rounded,
            title: 'Lưu ý',
            content:
            'Voucher chỉ được áp dụng khi đơn hàng đạt điều kiện tối thiểu. Sau khi đặt hàng thành công, voucher đang chọn sẽ được tự động bỏ chọn.',
            color: color,
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
                  : color.withOpacity(0.10),
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
                child: OutlinedButton.icon(
                  onPressed: () => copyCode(context),
                  icon: Icon(Icons.copy_rounded),
                  label: Text('Copy mã'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    minimumSize: Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isSelected || !isEligible
                        ? null
                        : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.lighten(color, 0.18),
                        color,
                        AppColors.darken(color, 0.20),
                      ],
                    ),
                    color: isSelected || !isEligible ? Colors.grey.shade600 : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!isSelected && isEligible)
                        BoxShadow(
                          color: color.withOpacity(0.22),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: isSelected
                        ? null
                        : () => applyVoucher(
                      context: context,
                      ref: ref,
                      subtotal: subtotal,
                    ),
                    icon: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : isEligible
                          ? Icons.check_circle_outline_rounded
                          : Icons.lock_outline_rounded,
                    ),
                    label: Text(
                      isSelected
                          ? 'Đã áp dụng'
                          : isEligible
                          ? 'Áp dụng'
                          : 'Chưa đủ',
                    ),
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

class _VoucherHeroCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String description;
  final String code;
  final bool isSelected;
  final bool isEligible;

  _VoucherHeroCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
    required this.code,
    required this.isSelected,
    required this.isEligible,
  });

  @override
  Widget build(BuildContext context) {
    final darkColor = AppColors.darken(color, 0.22);
    final lightColor = AppColors.lighten(color, 0.18);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            lightColor,
            color,
            darkColor,
          ],
        ),
        borderRadius: BorderRadius.circular(33),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(
              AppColors.isDark(context) ? 0.26 : 0.24,
            ),
            blurRadius: 20,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                darkColor,
                color,
                lightColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -42,
                right: -36,
                child: Container(
                  width: 126,
                  height: 126,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.09),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -36,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: -8,
                bottom: 16,
                child: Icon(
                  icon,
                  color: Colors.white.withOpacity(0.10),
                  size: 130,
                ),
              ),

              Column(
                children: [
                  Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.16),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),

                  SizedBox(height: 18),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.24),
                          offset: Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    description.isEmpty
                        ? 'Ưu đãi đang được áp dụng tại Chill Bites.'
                        : description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      code,
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.24)
                          : isEligible
                          ? Colors.white.withOpacity(0.17)
                          : Colors.red.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                      ),
                    ),
                    child: Text(
                      isSelected
                          ? 'Đang áp dụng'
                          : isEligible
                          ? 'Có thể áp dụng'
                          : 'Chưa đủ điều kiện',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartConditionCard extends StatelessWidget {
  final Color color;
  final double subtotal;
  final double minOrder;
  final bool isEligible;
  final double missingAmount;

  _CartConditionCard({
    required this.color,
    required this.subtotal,
    required this.minOrder,
    required this.isEligible,
    required this.missingAmount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = minOrder <= 0 ? 1.0 : (subtotal / minOrder).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isEligible ? color.withOpacity(0.45) : AppColors.border(context),
          width: isEligible ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isEligible ? color.withOpacity(0.12) : AppColors.shadow(context),
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
              CircleAvatar(
                backgroundColor: isEligible
                    ? color.withOpacity(AppColors.isDark(context) ? 0.20 : 0.13)
                    : Colors.red.withOpacity(0.12),
                child: Icon(
                  isEligible ? Icons.verified_rounded : Icons.lock_outline_rounded,
                  color: isEligible ? color : Colors.red,
                ),
              ),

              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEligible
                          ? 'Đơn hàng đủ điều kiện'
                          : 'Đơn hàng chưa đủ điều kiện',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      isEligible
                          ? 'Bạn có thể áp dụng voucher này cho đơn hiện tại.'
                          : 'Mua thêm ${formatMoney(missingAmount)} để dùng voucher này.',
                      style: TextStyle(
                        color: isEligible
                            ? AppColors.textSecondary(context)
                            : Colors.red,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.cardSoft(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                isEligible ? color : Colors.red,
              ),
            ),
          ),

          SizedBox(height: 10),

          Row(
            children: [
              Text(
                'Tạm tính: ${formatMoney(subtotal)}',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Spacer(),
              Text(
                'Cần: ${formatMoney(minOrder)}',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(
              AppColors.isDark(context) ? 0.20 : 0.13,
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
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  content,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
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