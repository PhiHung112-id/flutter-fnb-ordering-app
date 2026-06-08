import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/category_list.dart';
import '../widgets/products_list.dart';
import 'location_page.dart';
import 'notification_page.dart';

class HomePage extends ConsumerWidget {
  HomePage({super.key});

  void openNotification(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationPage(),
      ),
    );
  }

  int getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryLocation = ref.watch(deliveryLocationProvider);
    final isLoggedIn = ref.watch(loggedInProvider);
    final profile = ref.watch(customerProfileProvider);

    final customerName =
    profile?['full_name']?.toString().trim().isNotEmpty == true
        ? profile!['full_name'].toString()
        : 'Khách hàng Chill Bites';

    final customerRank =
    profile?['rank']?.toString().trim().isNotEmpty == true
        ? profile!['rank'].toString()
        : 'Member';

    final customerPoints = getIntValue(profile?['points']);
    final avatarUrl = profile?['avatar_url']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: AppColors.card(context),
          onRefresh: () async {
            await ref.read(bannersProvider.notifier).refreshBanners();
            await ref.read(categoriesProvider.notifier).refreshCategories();
            await ref.read(productsProvider.notifier).refreshFromSupabase();
            await ref.read(vouchersProvider.notifier).refreshVouchers();

            if (isLoggedIn) {
              await ref.read(customerProfileProvider.notifier).loadProfile();
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _HomeHeaderDelegate(
                  locationText: deliveryLocation.trim().isEmpty
                      ? 'Chọn địa chỉ giao hàng'
                      : deliveryLocation,
                  customerName: customerName,
                  customerRank: customerRank,
                  customerPoints: customerPoints,
                  avatarUrl: avatarUrl,
                  isLoggedIn: isLoggedIn,
                  onLocationTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LocationPage(),
                      ),
                    );
                  },
                  onNotificationTap: () => openNotification(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 22),
                    _PromoBannerSlider(),
                    SizedBox(height: 20),
                    _SectionHeader(
                      title: 'Danh mục',
                      actionText: 'Từ hệ thống',
                    ),
                    SizedBox(height: 10),
                    CategoryList(),
                    SizedBox(height: 20),
                    _SectionHeader(
                      title: 'Món nổi bật',
                      actionText: 'Xem tất cả',
                    ),
                    SizedBox(height: 10),
                    _FoodFilterChips(),
                    SizedBox(height: 14),
                    ProductsList(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String locationText;
  final String customerName;
  final String customerRank;
  final int customerPoints;
  final String avatarUrl;
  final bool isLoggedIn;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;

  _HomeHeaderDelegate({
    required this.locationText,
    required this.customerName,
    required this.customerRank,
    required this.customerPoints,
    required this.avatarUrl,
    required this.isLoggedIn,
    required this.onLocationTap,
    required this.onNotificationTap,
  });

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 224;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    final currentExtent = maxExtent - shrinkOffset;
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final primary = Theme.of(context).colorScheme.primary;

    final brandTop = 64 - (progress * 10);
    const brandHeight = 120.0;

    final canShowBrand = currentExtent >= brandTop + brandHeight + 10;

    final brandOpacity = canShowBrand
        ? ((currentExtent - 188) / 36).clamp(0.0, 1.0)
        : 0.0;

    final isDark = AppColors.isDark(context);

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.black,
            AppColors.blackCard,
            primary.withOpacity(0.20),
          ],
        )
            : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card(context),
            AppColors.cardSoft(context),
            primary.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30 - (progress * 14)),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border(context),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShadow(context),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30 - (progress * 14)),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: -44,
              right: -36,
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  color: primary.withOpacity(isDark ? 0.16 : 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: -48,
              left: -38,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: primary.withOpacity(isDark ? 0.10 : 0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              left: 20,
              right: 20,
              top: 10,
              height: 46,
              child: _LocationTopBar(
                locationText: locationText,
                onLocationTap: onLocationTap,
                onNotificationTap: onNotificationTap,
              ),
            ),

            if (brandOpacity > 0)
              Positioned(
                left: 20,
                right: 20,
                top: brandTop,
                height: brandHeight,
                child: IgnorePointer(
                  ignoring: progress > 0.35,
                  child: Opacity(
                    opacity: brandOpacity,
                    child: Transform.translate(
                      offset: Offset(0, -progress * 6),
                      child: _PremiumHomeBrand(
                        customerName: customerName,
                        customerRank: customerRank,
                        customerPoints: customerPoints,
                        avatarUrl: avatarUrl,
                        isLoggedIn: isLoggedIn,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) {
    return oldDelegate.locationText != locationText ||
        oldDelegate.customerName != customerName ||
        oldDelegate.customerRank != customerRank ||
        oldDelegate.customerPoints != customerPoints ||
        oldDelegate.avatarUrl != avatarUrl ||
        oldDelegate.isLoggedIn != isLoggedIn;
  }
}

class _PremiumHomeBrand extends StatelessWidget {
  final String customerName;
  final String customerRank;
  final int customerPoints;
  final String avatarUrl;
  final bool isLoggedIn;

  _PremiumHomeBrand({
    required this.customerName,
    required this.customerRank,
    required this.customerPoints,
    required this.avatarUrl,
    required this.isLoggedIn,
  });

  IconData getRankIcon(String rank) {
    switch (rank.toLowerCase()) {
      case 'diamond':
        return Icons.diamond_rounded;
      case 'gold':
        return Icons.workspace_premium_rounded;
      case 'silver':
        return Icons.military_tech_rounded;
      default:
        return Icons.local_cafe_rounded;
    }
  }

  String getRankText(String rank) {
    switch (rank.toLowerCase()) {
      case 'diamond':
        return 'Diamond';
      case 'gold':
        return 'Gold';
      case 'silver':
        return 'Silver';
      default:
        return 'Member';
    }
  }

  String getRankSubtitle(String rank) {
    switch (rank.toLowerCase()) {
      case 'diamond':
        return 'Crystal Elite Member';
      case 'gold':
        return 'Premium Gold Member';
      case 'silver':
        return 'Silver Reward Member';
      default:
        return 'Starter Reward Member';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    final rankColor = AppColors.rankMainColor(customerRank);
    final rankDarkColor = AppColors.rankDarkColor(customerRank);
    final rankLightColor = AppColors.rankLightColor(customerRank);
    final rankIcon = getRankIcon(customerRank);
    final rankText = getRankText(customerRank);
    final rankSubtitle = getRankSubtitle(customerRank);
    final hasAvatar = avatarUrl.trim().isNotEmpty;

    return Container(
      height: 120,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: AppColors.metalBorderGradientByRank(customerRank),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(isDark ? 0.36 : 0.30),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.metalCardGradientByRank(
              context,
              customerRank,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _HomeCardPatternPainter(
                    color: rankColor,
                    isDark: isDark,
                  ),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.metalGlassOverlay(),
                  ),
                ),
              ),

              Positioned(
                right: -30,
                top: -38,
                child: Icon(
                  rankIcon,
                  size: 126,
                  color: Colors.white.withOpacity(isDark ? 0.08 : 0.16),
                ),
              ),

              Positioned(
                right: 14,
                bottom: -32,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.20),
                      width: 2,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: -22,
                bottom: -28,
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            rankColor,
                            rankLightColor,
                            rankDarkColor,
                            Colors.white,
                            rankColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: rankColor.withOpacity(0.35),
                            blurRadius: 16,
                            offset: Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.blackCard : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: hasAvatar
                              ? CachedNetworkImage(
                            imageUrl: avatarUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) {
                              return AppLogo(
                                size: 54,
                                showText: false,
                              );
                            },
                          )
                              : AppLogo(
                            size: 54,
                            showText: false,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                isLoggedIn ? 'Xin chào,' : 'Chào mừng,',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.84),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                              SizedBox(width: 6),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: rankLightColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 5),

                          Text(
                            customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                              height: 1.05,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.35),
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            rankSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),

                          SizedBox(height: 6),

                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.22),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      rankIcon,
                                      color: rankLightColor,
                                      size: 13,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      rankText,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 8),

                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.26),
                                    ),
                                  ),
                                  child: Text(
                                    isLoggedIn
                                        ? '$customerPoints điểm'
                                        : 'Đăng nhập nhận ưu đãi',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8),

                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: rankDarkColor.withOpacity(0.28),
                            blurRadius: 12,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCardPatternPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  _HomeCardPatternPainter({
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(isDark ? 0.045 : 0.16)
      ..strokeWidth = 1;

    const gap = 18.0;

    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        linePaint,
      );
    }

    final dotPaint = Paint()
      ..color = color.withOpacity(isDark ? 0.13 : 0.16)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 22) {
      for (double y = 0; y < size.height; y += 22) {
        canvas.drawCircle(
          Offset(x, y),
          1.2,
          dotPaint,
        );
      }
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(isDark ? 0.32 : 0.24),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.76, size.height * 0.38),
          radius: 92,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.38),
      92,
      glowPaint,
    );

    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.34),
          Colors.white.withOpacity(0.04),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final shinePath = Path()
      ..moveTo(-20, 0)
      ..lineTo(size.width * 0.40, 0)
      ..lineTo(size.width * 0.16, size.height)
      ..lineTo(-70, size.height)
      ..close();

    canvas.drawPath(shinePath, shinePaint);
  }

  @override
  bool shouldRepaint(covariant _HomeCardPatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDark != isDark;
  }
}

class _LocationTopBar extends StatelessWidget {
  final String locationText;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;

  _LocationTopBar({
    required this.locationText,
    required this.onLocationTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 46,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onLocationTap,
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: primary,
                    size: 21,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      locationText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary(context),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: onNotificationTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.cardSoft(context),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: AppColors.border(context),
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 9,
                  child: Container(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBannerSlider extends ConsumerStatefulWidget {
  _PromoBannerSlider();

  @override
  ConsumerState<_PromoBannerSlider> createState() => _PromoBannerSliderState();
}

class _PromoBannerSliderState extends ConsumerState<_PromoBannerSlider> {
  final PageController controller = PageController(viewportFraction: 0.90);
  int currentIndex = 0;
  Timer? timer;

  Color hexToColor(String hex) {
    var value = hex.replaceAll('#', '');

    if (value.length == 6) {
      value = 'FF$value';
    }

    return Color(int.parse(value, radix: 16));
  }

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: 4), (_) {
      final banners = ref.read(bannersProvider);

      if (!mounted || banners.isEmpty || !controller.hasClients) return;

      final nextIndex =
      currentIndex == banners.length - 1 ? 0 : currentIndex + 1;

      controller.animateToPage(
        nextIndex,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = ref.watch(bannersProvider);
    final primary = Theme.of(context).colorScheme.primary;

    if (banners.isEmpty) {
      return _BannerLoading();
    }

    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: controller,
            itemCount: banners.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = banners[index];

              final title = banner['title']?.toString() ?? '';
              final subtitle = banner['subtitle']?.toString() ?? '';
              final imageUrl = banner['imageUrl']?.toString() ?? '';
              final color = hexToColor(
                banner['colorHex']?.toString() ?? '#FF7A00',
              );

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.24),
                      blurRadius: 18,
                      offset: Offset(0, 9),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    if (imageUrl.isNotEmpty)
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.30),
                          colorBlendMode: BlendMode.darken,
                          errorWidget: (_, __, ___) {
                            return SizedBox.shrink();
                          },
                        ),
                      ),
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Container(
                        width: 118,
                        height: 118,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(42),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          SizedBox(
                            width: 230,
                            child: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Đặt ngay',
                              style: TextStyle(
                                color: color,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
                (index) {
              final isActive = currentIndex == index;

              return AnimatedContainer(
                duration: Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? primary
                      : primary.withOpacity(
                    AppColors.isDark(context) ? 0.35 : 0.28,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BannerLoading extends StatelessWidget {
  _BannerLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.border(context),
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;

  _SectionHeader({
    required this.title,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          Spacer(),
          Text(
            actionText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodFilterChips extends ConsumerWidget {
  _FoodFilterChips();

  static const filters = [
    {
      'title': 'Gợi ý',
      'icon': Icons.auto_awesome,
    },
    {
      'title': 'Bán chạy',
      'icon': Icons.local_fire_department,
    },
    {
      'title': 'Đồ uống',
      'icon': Icons.local_drink,
    },
    {
      'title': 'Đồ ăn',
      'icon': Icons.lunch_dining,
    },
    {
      'title': 'Giá tốt',
      'icon': Icons.sell_outlined,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(homeFilterProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final title = filter['title'] as String;
          final isSelected = selectedFilter == title;

          return InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              ref.read(homeFilterProvider.notifier).selectFilter(title);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppColors.primaryGradient(context)
                    : null,
                color: isSelected ? null : AppColors.card(context),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? primary : AppColors.border(context),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? primary.withOpacity(0.18)
                        : AppColors.shadow(context),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 17,
                    color: isSelected ? Colors.white : primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}