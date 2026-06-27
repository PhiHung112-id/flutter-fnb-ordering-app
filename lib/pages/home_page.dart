import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../widgets/category_list.dart';
import '../widgets/premium_rank_card.dart';
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

  Map<String, dynamic>? getRankData(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
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
        : profile?['rank_name']?.toString().trim().isNotEmpty == true
        ? profile!['rank_name'].toString()
        : profile?['customer_rank']?.toString().trim().isNotEmpty ==
        true
        ? profile!['customer_rank'].toString()
        : 'Member';

    final customerPoints = getIntValue(
      profile?['points'] ??
          profile?['point'] ??
          profile?['total_points'] ??
          profile?['reward_points'] ??
          0,
    );

    final avatarUrl = profile?['avatar_url']?.toString() ?? '';

    final rankData = getRankData(profile?['rank_data']);

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
                  rankData: rankData,
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
                    const SizedBox(height: 22),
                    _PromoBannerSlider(),
                    const SizedBox(height: 20),
                    _SectionHeader(
                      title: 'Danh mục',
                      actionText: 'Từ hệ thống',
                    ),
                    const SizedBox(height: 10),
                    CategoryList(),
                    const SizedBox(height: 20),
                    _SectionHeader(
                      title: 'Món nổi bật',
                      actionText: 'Xem tất cả',
                    ),
                    const SizedBox(height: 10),
                    _FoodFilterChips(),
                    const SizedBox(height: 14),
                    ProductsList(),
                    const SizedBox(height: 20),
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
  final Map<String, dynamic>? rankData;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;

  _HomeHeaderDelegate({
    required this.locationText,
    required this.customerName,
    required this.customerRank,
    required this.customerPoints,
    required this.avatarUrl,
    required this.isLoggedIn,
    required this.rankData,
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
            offset: const Offset(0, 7),
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
                      child: PremiumRankCard(
                        customerName: customerName,
                        customerRank: customerRank,
                        customerPoints: customerPoints,
                        avatarUrl: avatarUrl,
                        isLoggedIn: isLoggedIn,
                        rankData: rankData,
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
        oldDelegate.isLoggedIn != isLoggedIn ||
        oldDelegate.rankData != rankData;
  }
}

class _LocationTopBar extends StatelessWidget {
  final String locationText;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;

  const _LocationTopBar({
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
                  const SizedBox(width: 6),
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
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary(context),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                          offset: const Offset(0, 2),
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
  const _PromoBannerSlider();

  @override
  ConsumerState<_PromoBannerSlider> createState() => _PromoBannerSliderState();
}

class _PromoBannerSliderState extends ConsumerState<_PromoBannerSlider> {
  final PageController controller = PageController(viewportFraction: 0.90);
  int currentIndex = 0;
  Timer? timer;

  Color hexToColor(String hex) {
    var value = hex.replaceAll('#', '').trim();

    if (value.length == 6) {
      value = 'FF$value';
    }

    try {
      return Color(int.parse(value, radix: 16));
    } catch (_) {
      return const Color(0xFFFF7A00);
    }
  }

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final banners = ref.read(bannersProvider);

      if (!mounted || banners.isEmpty || !controller.hasClients) return;

      final nextIndex =
      currentIndex == banners.length - 1 ? 0 : currentIndex + 1;

      controller.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 350),
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
                      offset: const Offset(0, 9),
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
                            return const SizedBox.shrink();
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 230,
                            child: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const Spacer(),
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
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
                (index) {
              final isActive = currentIndex == index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
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
  const _BannerLoading();

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

  const _SectionHeader({
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
          const Spacer(),
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
  const _FoodFilterChips();

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
        separatorBuilder: (_, __) => const SizedBox(width: 10),
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
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient(context) : null,
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
                    offset: const Offset(0, 4),
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
                  const SizedBox(width: 6),
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