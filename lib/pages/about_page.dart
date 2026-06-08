import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/app_logo.dart';

class AboutPage extends StatelessWidget {
  AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Giới thiệu ứng dụng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            color: primary,
            onPressed: () {},
            icon: Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _AboutHeader(),

          SizedBox(height: 24),

          _InfoCard(
            icon: Icons.flag_rounded,
            title: 'Mục tiêu ứng dụng',
            content:
            'Chill Bites là ứng dụng đặt đồ ăn và đồ uống, giúp khách hàng xem menu, tìm kiếm món, thêm vào giỏ hàng, áp dụng voucher và đặt hàng nhanh chóng.',
          ),

          _InfoCard(
            icon: Icons.widgets_rounded,
            title: 'Chức năng chính',
            content:
            'Ứng dụng có các chức năng: xem danh sách món, lọc theo danh mục, tìm kiếm, yêu thích, giỏ hàng, thanh toán, lịch sử đơn hàng, địa chỉ giao hàng và voucher.',
          ),

          _InfoCard(
            icon: Icons.cloud_done_rounded,
            title: 'Công nghệ sử dụng',
            content:
            'Ứng dụng sử dụng Flutter cho giao diện mobile, Riverpod để quản lý trạng thái và Supabase để lưu dữ liệu như sản phẩm, đơn hàng, tài khoản, voucher và địa chỉ.',
          ),

          _InfoCard(
            icon: Icons.rocket_launch_rounded,
            title: 'Hướng phát triển',
            content:
            'Trong tương lai, app có thể tích hợp thanh toán online, thông báo thời gian thực, hệ thống quản trị cửa hàng và AI nhận diện khách hàng thân thiết.',
          ),

          SizedBox(height: 18),

          _VersionCard(),
        ],
      ),
    );
  }
}

class _AboutHeader extends StatelessWidget {
  _AboutHeader();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: BorderRadius.circular(33),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(
              AppColors.isDark(context) ? 0.28 : 0.22,
            ),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(context),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -42,
                right: -36,
                child: Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                bottom: -48,
                left: -38,
                child: Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                right: -4,
                bottom: 8,
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color: Colors.white.withOpacity(0.10),
                  size: 120,
                ),
              ),

              Column(
                children: [
                  Container(
                    width: 116,
                    height: 116,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: AppLogo(
                        size: 86,
                        showText: false,
                      ),
                    ),
                  ),

                  SizedBox(height: 18),

                  Text(
                    'Chill Bites',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.22),
                          offset: Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                      ),
                    ),
                    child: Text(
                      'Food & Drink Ordering App',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  SizedBox(height: 14),

                  Text(
                    'Đặt món nhanh • Ưu đãi mỗi ngày • Trải nghiệm hiện đại',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: primary.withOpacity(
              AppColors.isDark(context) ? 0.22 : 0.13,
            ),
            child: Icon(
              icon,
              color: primary,
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
                    color: primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  content,
                  style: TextStyle(
                    height: 1.5,
                    color: AppColors.textSecondary(context),
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

class _VersionCard extends StatelessWidget {
  _VersionCard();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(
          AppColors.isDark(context) ? 0.20 : 0.12,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: primary.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(
              AppColors.isDark(context) ? 0.10 : 0.08,
            ),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.18),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.verified_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phiên bản 1.0.0',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ứng dụng demo phục vụ đồ án và phát triển hệ thống F&B.',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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