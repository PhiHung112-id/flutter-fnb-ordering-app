import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../widgets/rank_membership_card.dart';

import 'about_page.dart';
import 'address_page.dart';
import 'login_page.dart';
import 'notification_page.dart';
import 'order_history_page.dart';
import 'payment_method_page.dart';
import 'profile_page.dart';
import 'register_page.dart';
import 'support_page.dart';
import 'voucher_page.dart';
import 'rank_theme_page.dart';
import 'onboarding_page.dart';

class AccountPage extends ConsumerWidget {
  AccountPage({super.key});

  Future<void> logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card(dialogContext),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Đăng xuất',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(dialogContext),
            ),
          ),
          content: Text(
            'Bạn có chắc muốn đăng xuất khỏi tài khoản hiện tại không?',
            style: TextStyle(
              color: AppColors.textSecondary(dialogContext),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Không',
                style: TextStyle(
                  color: AppColors.textSecondary(dialogContext),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.18),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ref.read(loggedInProvider.notifier).logout();

      ref.read(customerProfileProvider.notifier).clearProfile();
      ref.read(ordersProvider.notifier).clearOrders();
      ref.read(favoritesProvider.notifier).clearFavorites();
      ref.read(savedAddressesProvider.notifier).clearAddresses();
      ref.read(paymentMethodsProvider.notifier).clearPaymentMethods();
      ref.read(cartItemsProvider.notifier).clearCart();
      ref.read(selectedVoucherProvider.notifier).clearVoucher();
      ref.read(selectedPaymentProvider.notifier).clearPayment();
      ref.read(deliveryLocationProvider.notifier).clearLocation();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã đăng xuất. Bạn đang dùng app với tư cách khách.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng xuất: $e'),
        ),
      );
    }
  }

  void goLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginPage(),
      ),
    );
  }

  void goRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterPage(),
      ),
    );
  }

  void requireLogin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vui lòng đăng nhập để sử dụng chức năng này'),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginPage(),
      ),
    );
  }

  int getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String getFirstLetter(String name) {
    final value = name.trim();

    if (value.isEmpty) return 'C';

    return value.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(loggedInProvider);

    final profile = ref.watch(customerProfileProvider);
    final orders = ref.watch(ordersProvider);
    final favorites = ref.watch(favoritesProvider);
    final vouchers = ref.watch(vouchersProvider);
    final selectedLocation = ref.watch(deliveryLocationProvider);
    final paymentMethods = ref.watch(paymentMethodsProvider);
    final selectedPaymentId = ref.watch(selectedPaymentProvider);
    final themeMode = ref.watch(themeModeProvider);

    final isDarkMode = themeMode == ThemeMode.dark;

    final fullName =
    profile?['full_name']?.toString().trim().isNotEmpty == true
        ? profile!['full_name'].toString()
        : 'Khách hàng Chill Bites';

    final phone = profile?['phone']?.toString().trim().isNotEmpty == true
        ? profile!['phone'].toString()
        : 'Chưa có số điện thoại';

    final rank = profile?['rank']?.toString().trim().isNotEmpty == true
        ? profile!['rank'].toString()
        : 'Member';

    final points = getIntValue(profile?['points'] ?? 0);
    final avatarUrl = profile?['avatar_url']?.toString() ?? '';

    final selectedPayment = paymentMethods.isEmpty
        ? null
        : paymentMethods.firstWhere(
          (method) => method.id == selectedPaymentId,
      orElse: () => paymentMethods.first,
    );

    final paymentSubtitle = selectedPayment == null
        ? 'Chưa có phương thức thanh toán'
        : '${selectedPayment.title} • ${selectedPayment.subtitle}';

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: AppColors.card(context),
        onRefresh: () async {
          if (isLoggedIn) {
            await ref.read(customerProfileProvider.notifier).loadProfile();
            await ref.read(ordersProvider.notifier).loadOrdersFromSupabase();
            await ref.read(favoritesProvider.notifier).loadFavorites();
            await ref.read(savedAddressesProvider.notifier).loadAddresses();
            await ref.read(paymentMethodsProvider.notifier).loadPaymentMethods();
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (isLoggedIn)
              RankMembershipCard(
                fullName: fullName,
                phoneOrEmail: phone,
                rank: rank,
                points: points,
                avatarUrl: avatarUrl,
                firstLetter: getFirstLetter(fullName),
                compact: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(),
                    ),
                  );
                },
              )
            else
              _GuestHeader(
                onLogin: () => goLogin(context),
                onRegister: () => goRegister(context),
              ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.receipt_long,
                    title: isLoggedIn ? '${orders.length}' : '0',
                    subtitle: 'Đơn hàng',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.favorite,
                    title: isLoggedIn ? '${favorites.length}' : '0',
                    subtitle: 'Yêu thích',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.card_giftcard,
                    title: '${vouchers.length}',
                    subtitle: 'Voucher',
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            Text(
              'Cài đặt nhanh',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            SizedBox(height: 12),

            _AccountItem(
              icon: Icons.person_outline,
              title: 'Thông tin cá nhân',
              subtitle: isLoggedIn
                  ? '$fullName • $phone'
                  : 'Đăng nhập để quản lý hồ sơ',
              locked: !isLoggedIn,
              onTap: () {
                if (!isLoggedIn) {
                  requireLogin(context);
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(),
                  ),
                );
              },
            ),

            _AccountItem(
              icon: Icons.location_on_outlined,
              title: 'Địa chỉ giao hàng',
              subtitle: !isLoggedIn
                  ? 'Đăng nhập để lưu địa chỉ'
                  : selectedLocation.trim().isEmpty
                  ? 'Chưa có địa chỉ giao hàng'
                  : selectedLocation,
              locked: !isLoggedIn,
              onTap: () {
                if (!isLoggedIn) {
                  requireLogin(context);
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddressPage(),
                  ),
                );
              },
            ),

            _AccountItem(
              icon: Icons.payment,
              title: 'Phương thức thanh toán',
              subtitle: !isLoggedIn
                  ? 'Đăng nhập để lưu phương thức thanh toán'
                  : paymentSubtitle,
              locked: !isLoggedIn,
              onTap: () {
                if (!isLoggedIn) {
                  requireLogin(context);
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentMethodPage(),
                  ),
                );
              },
            ),

            _AccountItem(
              icon: Icons.receipt_long_outlined,
              title: 'Lịch sử đơn hàng',
              subtitle: !isLoggedIn
                  ? 'Đăng nhập để xem đơn đã đặt'
                  : 'Theo dõi và xem lại đơn đã đặt',
              badgeText: isLoggedIn && orders.isNotEmpty
                  ? orders.length.toString()
                  : null,
              locked: !isLoggedIn,
              onTap: () {
                if (!isLoggedIn) {
                  requireLogin(context);
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderHistoryPage(),
                  ),
                );
              },
            ),

            _AccountItem(
              icon: Icons.confirmation_number_outlined,
              title: 'Voucher của tôi',
              subtitle: 'Mã giảm giá và ưu đãi đang có',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VoucherPage(),
                  ),
                );
              },
            ),

            _AccountItem(
              icon: Icons.notifications_none,
              title: 'Thông báo',
              subtitle: isLoggedIn
                  ? 'Ưu đãi và cập nhật mới nhất'
                  : 'Đăng nhập để nhận thông báo cá nhân',
              locked: !isLoggedIn,
              onTap: () {
                if (!isLoggedIn) {
                  requireLogin(context);
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NotificationPage(),
                  ),
                );
              },
            ),

            _ThemeSwitchItem(
              isDarkMode: isDarkMode,
              onChanged: (_) {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
            ),

            _AccountItem(
              icon: Icons.palette_outlined,
              title: 'Chủ đề rank',
              subtitle: 'Mở khóa và đổi màu app theo cấp bậc',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RankThemePage(),
                  ),
                );
              },
            ),

            _AccountItem(
              icon: Icons.slideshow_rounded,
              title: 'Xem lại hướng dẫn',
              subtitle: 'Xem lại màn hình giới thiệu khi mới vào app',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OnboardingPage(
                      reviewMode: true,
                    ),
                  ),
                );
              },
            ),

            _AccountItem(
              icon: Icons.support_agent,
              title: 'Hỗ trợ khách hàng',
              subtitle: 'Câu hỏi thường gặp và liên hệ hỗ trợ',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SupportPage(),
                  ),
                );
              },
            ),

            _AccountItem(
              icon: Icons.info_outline,
              title: 'Về Chill Bites',
              subtitle: 'Thông tin ứng dụng và phiên bản',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AboutPage(),
                  ),
                );
              },
            ),

            SizedBox(height: 18),

            if (isLoggedIn)
              OutlinedButton.icon(
                onPressed: () => logout(context, ref),
                icon: Icon(Icons.logout),
                label: Text('Đăng xuất'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  minimumSize: Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.22),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => goLogin(context),
                  icon: Icon(Icons.login),
                  label: Text('Đăng nhập để đặt hàng'),
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
                ),
              ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwitchItem extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  _ThemeSwitchItem({
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
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
            backgroundColor: isDarkMode
                ? primary.withOpacity(0.95)
                : primary.withOpacity(0.14),
            child: Icon(
              isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDarkMode ? Colors.white : primary,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chế độ giao diện',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isDarkMode ? 'Đang dùng chế độ tối' : 'Đang dùng chế độ sáng',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDarkMode,
            activeColor: primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _GuestHeader extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  _GuestHeader({
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.18),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient(context),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.22),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khách vãng lai',
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Đăng nhập để đặt món, lưu yêu thích và xem lịch sử đơn hàng.',
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
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      onPressed: onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        minimumSize: Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Đăng nhập',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRegister,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary),
                      minimumSize: Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Đăng ký',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  _SummaryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
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
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primary.withOpacity(
                AppColors.isDark(context) ? 0.20 : 0.12,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: primary.withOpacity(0.22),
              ),
            ),
            child: Icon(
              icon,
              color: primary,
              size: 22,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badgeText;
  final bool locked;
  final VoidCallback onTap;

  _AccountItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeText,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final iconBgColor = locked
        ? Colors.grey.withOpacity(0.18)
        : primary.withOpacity(AppColors.isDark(context) ? 0.22 : 0.13);

    final iconColor = locked ? Colors.grey : primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(20),
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
                backgroundColor: iconBgColor,
                child: Icon(
                  locked ? Icons.lock_outline : icon,
                  color: iconColor,
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
                        color: locked
                            ? Colors.grey
                            : AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeText != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient(context),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.18),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Icon(
                locked ? Icons.login_rounded : Icons.chevron_right,
                color: locked ? Colors.grey : AppColors.textSecondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}