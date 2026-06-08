import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../utils/format_money.dart';
import 'voucher_detail_page.dart';

class VoucherPage extends ConsumerStatefulWidget {
  VoucherPage({super.key});

  @override
  ConsumerState<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends ConsumerState<VoucherPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(vouchersProvider.notifier).loadVouchers();
    });
  }

  double getCartSubtotal({
    required List cartItems,
    required List<Map<String, dynamic>> products,
  }) {
    double total = 0;

    for (final cartItem in cartItems) {
      try {
        final product = products.firstWhere(
              (item) => item['id'] == cartItem.id,
        );

        final price = (product['price'] as num?)?.toDouble() ?? 0;
        final toppingPrice = cartItem.toppingPrice;
        final qty = cartItem.qty;

        total += (price + toppingPrice) * qty;
      } catch (_) {}
    }

    return total;
  }

  bool canUseVoucher({
    required Map<String, dynamic> voucher,
    required double subtotal,
  }) {
    final minOrder = (voucher['minOrder'] as num?)?.toDouble() ?? 0;
    return subtotal >= minOrder;
  }

  @override
  Widget build(BuildContext context) {
    final vouchers = ref.watch(vouchersProvider);
    final selectedVoucher = ref.watch(selectedVoucherProvider);
    final cartItems = ref.watch(cartItemsProvider);
    final products = ref.watch(productsProvider);
    final primary = Theme.of(context).colorScheme.primary;

    final subtotal = getCartSubtotal(
      cartItems: cartItems,
      products: products,
    );

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Voucher',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            color: primary,
            onPressed: () async {
              await ref.read(vouchersProvider.notifier).refreshVouchers();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã tải lại voucher'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primary,
        backgroundColor: AppColors.card(context),
        onRefresh: () async {
          await ref.read(vouchersProvider.notifier).refreshVouchers();
        },
        child: vouchers.isEmpty
            ? _EmptyVoucher()
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _VoucherHeader(subtotal: subtotal),

            SizedBox(height: 18),

            Row(
              children: [
                Text(
                  'Danh sách voucher',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Spacer(),
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
                      color: primary.withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    '${vouchers.length} ưu đãi',
                    style: TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            ...vouchers.map((voucher) {
              final code = voucher['code']?.toString() ?? '';
              final isSelected = selectedVoucher == code;
              final isEligible = canUseVoucher(
                voucher: voucher,
                subtotal: subtotal,
              );

              return _VoucherCard(
                voucher: voucher,
                subtotal: subtotal,
                isSelected: isSelected,
                isEligible: isEligible,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VoucherDetailPage(
                        voucher: voucher,
                      ),
                    ),
                  );
                },
                onUse: () {
                  if (!isEligible) {
                    final minOrder =
                        (voucher['minOrder'] as num?)?.toDouble() ?? 0;
                    final missing = minOrder - subtotal;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đơn hàng cần thêm ${formatMoney(missing)} để dùng voucher $code',
                        ),
                      ),
                    );

                    return;
                  }

                  ref
                      .read(selectedVoucherProvider.notifier)
                      .selectVoucher(code);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã chọn voucher $code'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _VoucherHeader extends StatelessWidget {
  final double subtotal;

  _VoucherHeader({
    required this.subtotal,
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
                Icons.confirmation_number_outlined,
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
                    'Ưu đãi Chill Bites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtotal <= 0
                        ? 'Thêm món vào giỏ hàng để kiểm tra voucher có thể áp dụng.'
                        : 'Tạm tính đơn hàng: ${formatMoney(subtotal)}',
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

class _VoucherCard extends StatelessWidget {
  final Map<String, dynamic> voucher;
  final double subtotal;
  final bool isSelected;
  final bool isEligible;
  final VoidCallback onTap;
  final VoidCallback onUse;

  _VoucherCard({
    required this.voucher,
    required this.subtotal,
    required this.isSelected,
    required this.isEligible,
    required this.onTap,
    required this.onUse,
  });

  Color getVoucherColor(BuildContext context, String code, String title) {
    final lowerCode = code.toLowerCase();
    final lowerTitle = title.toLowerCase();

    if (lowerCode.contains('ship') || lowerTitle.contains('ship')) {
      return Colors.blue;
    }

    if (lowerCode.contains('combo') || lowerTitle.contains('combo')) {
      return Colors.green;
    }

    return Theme.of(context).colorScheme.primary;
  }

  IconData getVoucherIcon(String code, String title) {
    final lowerCode = code.toLowerCase();
    final lowerTitle = title.toLowerCase();

    if (lowerCode.contains('ship') || lowerTitle.contains('ship')) {
      return Icons.delivery_dining_rounded;
    }

    if (lowerCode.contains('combo') || lowerTitle.contains('combo')) {
      return Icons.fastfood_rounded;
    }

    return Icons.local_offer_rounded;
  }

  double getDoubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final code = voucher['code']?.toString() ?? '';
    final title = voucher['title']?.toString() ?? '';
    final description = voucher['description']?.toString() ?? '';
    final discount = getDoubleValue(voucher['discount']);
    final minOrder = getDoubleValue(voucher['minOrder']);

    final color = getVoucherColor(context, code, title);
    final icon = getVoucherIcon(code, title);

    final missing = minOrder - subtotal;
    final canShowMissing = !isEligible && missing > 0;

    return Opacity(
      opacity: isEligible ? 1 : 0.65,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? color : AppColors.border(context),
            width: isSelected ? 1.7 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withOpacity(0.14)
                  : AppColors.shadow(context),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: color.withOpacity(
                      AppColors.isDark(context) ? 0.20 : 0.14,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withOpacity(0.22),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 34,
                  ),
                ),

                SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        code,
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      SizedBox(height: 3),

                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        description.isEmpty
                            ? 'Ưu đãi đang hoạt động tại Chill Bites'
                            : description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          height: 1.3,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(
                            AppColors.isDark(context) ? 0.18 : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: color.withOpacity(0.20),
                          ),
                        ),
                        child: Text(
                          'Giảm ${formatMoney(discount)} • Tối thiểu ${formatMoney(minOrder)}',
                          style: TextStyle(
                            color: color,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (canShowMissing) ...[
                        SizedBox(height: 6),
                        Text(
                          'Mua thêm ${formatMoney(missing)} để dùng voucher',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: 10),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: color,
                      )
                    else
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary(context),
                      ),

                    SizedBox(height: 10),

                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onUse,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(
                            AppColors.isDark(context) ? 0.20 : 0.14,
                          )
                              : isEligible
                              ? color
                              : AppColors.cardSoft(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? color.withOpacity(0.28)
                                : isEligible
                                ? color
                                : AppColors.border(context),
                          ),
                        ),
                        child: Text(
                          isSelected
                              ? 'Đã chọn'
                              : isEligible
                              ? 'Dùng'
                              : 'Chưa đủ',
                          style: TextStyle(
                            color: isSelected
                                ? color
                                : isEligible
                                ? Colors.white
                                : AppColors.textSecondary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyVoucher extends ConsumerWidget {
  _EmptyVoucher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        SizedBox(height: 80),

        Container(
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
                  Icons.confirmation_number_outlined,
                  color: Colors.white,
                  size: 58,
                ),
              ),

              SizedBox(height: 20),

              Text(
                'Chưa có voucher',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Voucher sẽ được hiển thị từ dữ liệu Supabase khi có ưu đãi đang hoạt động.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 18),

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
                  onPressed: () {
                    ref.read(vouchersProvider.notifier).refreshVouchers();
                  },
                  icon: Icon(Icons.refresh_rounded),
                  label: Text('Tải lại voucher'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}