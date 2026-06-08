import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import 'main_page.dart';

class OnboardingPage extends StatefulWidget {
  final bool reviewMode;

  OnboardingPage({
    super.key,
    this.reviewMode = false,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController pageController = PageController();
  int currentIndex = 0;

  static const Color brandPrimary = AppColors.orange;
  static const Color brandPrimaryDark = AppColors.orangeDark;
  static const Color brandPrimaryLight = AppColors.orangeLight;
  static const Color brandPrimarySoft = AppColors.orangeSoft;
  static const Color brandBackground = AppColors.whiteSoft;
  static const Color brandText = AppColors.black;
  static const Color brandTextSoft = Color(0xFF8D7B68);

  final pages = [
    _OnboardingData(
      icon: Icons.restaurant_menu_rounded,
      title: 'Đặt món mọi lúc',
      description:
      'Khám phá thực đơn đồ ăn, cà phê và thức uống được tối ưu cho trải nghiệm F&B hiện đại.',
      badge: 'Food Ordering',
      accentColor: AppColors.orange,
      type: _OnboardingType.normal,
    ),
    _OnboardingData(
      icon: Icons.delivery_dining_rounded,
      title: 'Giao nhanh tiện lợi',
      description:
      'Chọn vị trí giao hàng, theo dõi đơn và nhận món nhanh chóng từ hệ thống cửa hàng Chill Bites.',
      badge: 'Fast Delivery',
      accentColor: Color(0xFF2B1D16),
      type: _OnboardingType.normal,
    ),
    _OnboardingData(
      icon: Icons.card_giftcard_rounded,
      title: 'Voucher & ưu đãi',
      description:
      'Sử dụng voucher, lưu phương thức thanh toán và quản lý lịch sử đơn hàng dễ dàng.',
      badge: 'Smart Voucher',
      accentColor: Color(0xFFFF9F1C),
      type: _OnboardingType.normal,
    ),
    _OnboardingData(
      icon: Icons.workspace_premium_rounded,
      title: 'Tăng rank nhận ưu đãi',
      description:
      'Tích điểm sau mỗi đơn hàng để mở khóa Silver, Gold, Diamond và nhận ưu đãi thành viên hấp dẫn hơn.',
      badge: 'Membership Rank',
      accentColor: Color(0xFFFFC107),
      type: _OnboardingType.rank,
    ),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: MainPage(),
          );
        },
      ),
    );
  }

  void goNext() {
    if (currentIndex == pages.length - 1) {
      finishOnboarding();
      return;
    }

    pageController.nextPage(
      duration: Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void goPrevious() {
    if (currentIndex <= 0) return;

    pageController.previousPage(
      duration: Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void skip() {
    finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentIndex == pages.length - 1;
    final currentPage = pages[currentIndex];

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: brandBackground,
        primaryColor: brandPrimary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandPrimary,
          brightness: Brightness.light,
          primary: brandPrimary,
          secondary: brandPrimarySoft,
          surface: Colors.white,
        ),
      ),
      child: Scaffold(
        backgroundColor: brandBackground,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 350),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFFBF6),
                        brandBackground,
                        currentPage.accentColor.withOpacity(0.10),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: -120,
                right: -110,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 350),
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    color: currentPage.accentColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                bottom: 105,
                left: -120,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: brandPrimary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                top: 180,
                left: -55,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: brandPrimaryLight.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                    child: Row(
                      children: [
                        AppLogo(
                          size: 42,
                          showText: true,
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: skip,
                          style: TextButton.styleFrom(
                            foregroundColor: brandPrimary,
                          ),
                          child: Text(
                            'Bỏ qua',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: pages.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = pages[index];

                        return SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height * 0.58,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 280),
                                  child: item.type == _OnboardingType.rank
                                      ? _RankBenefitCard(
                                    key: ValueKey(item.title),
                                    item: item,
                                  )
                                      : _IllustrationCard(
                                    key: ValueKey(item.title),
                                    item: item,
                                  ),
                                ),

                                SizedBox(height: item.type == _OnboardingType.rank ? 18 : 30),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.accentColor.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: item.accentColor.withOpacity(0.18),
                                    ),
                                  ),
                                  child: Text(
                                    item.badge,
                                    style: TextStyle(
                                      color: item.accentColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 14),

                                Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: brandText,
                                    fontSize: item.type == _OnboardingType.rank ? 27 : 31,
                                    fontWeight: FontWeight.w900,
                                    height: 1.12,
                                    letterSpacing: -0.4,
                                  ),
                                ),

                                SizedBox(height: 12),

                                Text(
                                  item.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: brandTextSoft,
                                    fontSize: 14.5,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            pages.length,
                                (index) {
                              final isActive = currentIndex == index;

                              return AnimatedContainer(
                                duration: Duration(milliseconds: 260),
                                curve: Curves.easeOutCubic,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 30 : 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? brandPrimary
                                      : brandPrimarySoft,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 24),

                        Row(
                          children: [
                            if (currentIndex > 0)
                              InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: goPrevious,
                                child: Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: brandPrimarySoft,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    color: brandPrimary,
                                  ),
                                ),
                              )
                            else
                              SizedBox(width: 58),

                            SizedBox(width: 12),

                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      brandPrimaryLight,
                                      brandPrimary,
                                      brandPrimaryDark,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: brandPrimary.withOpacity(0.22),
                                      blurRadius: 12,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: goNext,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, 58),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isLastPage
                                            ? 'Bắt đầu trải nghiệm'
                                            : 'Tiếp tục',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        isLastPage
                                            ? Icons.check_circle_outline
                                            : Icons.arrow_forward_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

class _IllustrationCard extends StatelessWidget {
  final _OnboardingData item;

  _IllustrationCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      height: 270,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            item.accentColor.withOpacity(0.30),
            item.accentColor.withOpacity(0.62),
          ],
        ),
        borderRadius: BorderRadius.circular(45),
        boxShadow: [
          BoxShadow(
            color: item.accentColor.withOpacity(0.18),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(42),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -34,
                top: -34,
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: item.accentColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                left: -40,
                bottom: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: brandSoftColor.withOpacity(0.75),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                right: 24,
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3E8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: item.accentColor.withOpacity(0.12),
                    ),
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    color: item.accentColor,
                    size: 24,
                  ),
                ),
              ),

              Center(
                child: Container(
                  width: 144,
                  height: 144,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.lighten(item.accentColor, 0.15),
                        item.accentColor,
                        AppColors.darken(item.accentColor, 0.18),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: item.accentColor.withOpacity(0.24),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    color: Colors.white,
                    size: 78,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const Color brandSoftColor = AppColors.orangeSoft;
}

class _RankBenefitCard extends StatelessWidget {
  final _OnboardingData item;

  _RankBenefitCard({
    super.key,
    required this.item,
  });

  static final ranks = [
    _RankIntroData(
      title: 'Member',
      point: '0+ điểm',
      benefit: 'Tích điểm mỗi đơn',
      icon: Icons.local_cafe_rounded,
      colors: [
        Color(0xFF7A3100),
        Color(0xFFFF7A00),
        Color(0xFFFFD2A1),
      ],
    ),
    _RankIntroData(
      title: 'Silver',
      point: '500+ điểm',
      benefit: 'Giảm 3%',
      icon: Icons.military_tech_rounded,
      colors: [
        Color(0xFF334155),
        Color(0xFFCBD5E1),
        Color(0xFFFFFFFF),
      ],
    ),
    _RankIntroData(
      title: 'Gold',
      point: '1000+ điểm',
      benefit: 'Giảm 5%',
      icon: Icons.workspace_premium_rounded,
      colors: [
        Color(0xFF7A4D00),
        Color(0xFFFFC107),
        Color(0xFFFFF4C7),
      ],
    ),
    _RankIntroData(
      title: 'Diamond',
      point: '2000+ điểm',
      benefit: 'Giảm 8%',
      icon: Icons.diamond_rounded,
      colors: [
        Color(0xFF075985),
        Color(0xFF38BDF8),
        Color(0xFFE0F7FF),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFFFF4C7),
            Color(0xFFFFC107),
            Color(0xFF8A5D00),
          ],
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFFC107).withOpacity(0.24),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(31),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A1700),
                Color(0xFF8A5D00),
                Color(0xFFFFC107),
                Color(0xFFFFF4C7),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -38,
                top: -44,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 150,
                  color: Colors.white.withOpacity(0.10),
                ),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.24),
                          ),
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hệ thống rank',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ăn ngon hơn, ưu đãi nhiều hơn',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.76),
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  ...ranks.map((rank) {
                    return _RankIntroTile(rank: rank);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankIntroTile extends StatelessWidget {
  final _RankIntroData rank;

  _RankIntroTile({
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = rank.colors[1];

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: rank.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                rank.icon,
                color: Colors.white,
                size: 21,
              ),
            ),

            SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rank.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    rank.point,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                rank.benefit,
                style: TextStyle(
                  color: mainColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final String badge;
  final Color accentColor;
  final _OnboardingType type;

  _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
    required this.accentColor,
    required this.type,
  });
}

class _RankIntroData {
  final String title;
  final String point;
  final String benefit;
  final IconData icon;
  final List<Color> colors;

  _RankIntroData({
    required this.title,
    required this.point,
    required this.benefit,
    required this.icon,
    required this.colors,
  });
}

enum _OnboardingType {
  normal,
  rank,
}