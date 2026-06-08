import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/app_logo.dart';
import '../utils/app_globals.dart';
import 'onboarding_page.dart';
import 'main_page.dart';
class SplashPage extends StatefulWidget {
  SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> fadeAnimation;
  late final Animation<double> scaleAnimation;
  late final Animation<Offset> slideAnimation;
  late final Animation<double> progressAnimation;

  // 4 màu rank cố định cho Splash
  static const Color rankOrange = Color(0xFFFF7A00);
  static const Color rankOrangeDark = Color(0xFFE85D04);

  static const Color rankSilver = Color(0xFFD6DCE3);
  static const Color rankSilverDark = Color(0xFF9CA3AF);

  static const Color rankGold = Color(0xFFFFC83D);
  static const Color rankGoldDark = Color(0xFFC98200);

  static const Color rankDiamond = Color(0xFF55C7FF);
  static const Color rankDiamondDark = Color(0xFF0284C7);

  static const Color brandBackground = Color(0xFFFFF8F0);
  static const Color brandText = Color(0xFF0F0F0F);
  static const Color brandTextSoft = Color(0xFF8D7B68);

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );

    scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
      ),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    animationController.forward();
    checkOnboardingStatus();
  }

  Future<void> checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (isPasswordRecoveryMode) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: hasSeenOnboarding ? MainPage() : OnboardingPage(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  LinearGradient get rankBackgroundGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFBF6),
        Color(0xFFFFF3E6),
        Color(0xFFF7FAFF),
        Color(0xFFEAF8FF),
      ],
      stops: [0.0, 0.38, 0.72, 1.0],
    );
  }

  LinearGradient get rankBorderGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        rankOrange,
        rankSilver,
        rankGold,
        rankDiamond,
      ],
      stops: [0.0, 0.34, 0.66, 1.0],
    );
  }

  LinearGradient get rankProgressGradient {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        rankOrange,
        rankSilver,
        rankGold,
        rankDiamond,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: brandBackground,
        primaryColor: rankOrange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: rankOrange,
          brightness: Brightness.light,
          primary: rankOrange,
          secondary: rankDiamond,
          surface: Colors.white,
        ),
      ),
      child: Scaffold(
        backgroundColor: brandBackground,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: rankBackgroundGradient,
                  ),
                ),
              ),

              Positioned(
                top: -95,
                right: -72,
                child: _BlurCircle(
                  size: 235,
                  color: rankOrange.withOpacity(0.14),
                ),
              ),

              Positioned(
                bottom: -115,
                left: -85,
                child: _BlurCircle(
                  size: 270,
                  color: rankDiamond.withOpacity(0.18),
                ),
              ),

              Positioned(
                top: 118,
                left: -58,
                child: _BlurCircle(
                  size: 128,
                  color: rankSilver.withOpacity(0.34),
                ),
              ),

              Positioned(
                right: 24,
                bottom: 155,
                child: _BlurCircle(
                  size: 92,
                  color: rankGold.withOpacity(0.22),
                ),
              ),

              Center(
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3.2),
                              decoration: BoxDecoration(
                                gradient: rankBorderGradient,
                                borderRadius: BorderRadius.circular(42),
                                boxShadow: [
                                  BoxShadow(
                                    color: rankOrange.withOpacity(0.15),
                                    blurRadius: 26,
                                    offset: const Offset(0, 12),
                                  ),
                                  BoxShadow(
                                    color: rankDiamond.withOpacity(0.12),
                                    blurRadius: 28,
                                    offset: const Offset(0, 14),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(38),
                                ),
                                child: AppLogo(
                                  size: 84,
                                  showText: true,
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            const Text(
                              'Chill Bites',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: brandText,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    rankOrange.withOpacity(0.12),
                                    rankGold.withOpacity(0.13),
                                    rankDiamond.withOpacity(0.12),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: rankOrange.withOpacity(0.18),
                                ),
                              ),
                              child: const Text(
                                'Food & Beverage Ordering',
                                style: TextStyle(
                                  color: rankOrangeDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Text(
                              'Đặt món nhanh • Ưu đãi mỗi ngày',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: brandTextSoft,
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 22),

                            const _RankMiniRow(),

                            const SizedBox(height: 30),

                            AnimatedBuilder(
                              animation: progressAnimation,
                              builder: (context, child) {
                                return SizedBox(
                                  width: 178,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: rankOrange.withOpacity(0.12),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: FractionallySizedBox(
                                          widthFactor: progressAnimation.value,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: rankProgressGradient,
                                              borderRadius:
                                              BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            Text(
                              'Đang khởi động ứng dụng...',
                              style: TextStyle(
                                color: brandTextSoft.withOpacity(0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 22,
                child: Text(
                  'Chill Bites • Version 1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: brandTextSoft.withOpacity(0.72),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _RankMiniRow extends StatelessWidget {
  const _RankMiniRow();

  static const ranks = [
    _RankDotData(
      name: 'Member',
      color: Color(0xFFFF7A00),
      shadow: Color(0xFFFFA726),
    ),
    _RankDotData(
      name: 'Silver',
      color: Color(0xFFD6DCE3),
      shadow: Color(0xFF9CA3AF),
    ),
    _RankDotData(
      name: 'Gold',
      color: Color(0xFFFFC83D),
      shadow: Color(0xFFD89A00),
    ),
    _RankDotData(
      name: 'Diamond',
      color: Color(0xFF55C7FF),
      shadow: Color(0xFF0284C7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: ranks.map((rank) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: rank.color.withOpacity(0.38),
            ),
            boxShadow: [
              BoxShadow(
                color: rank.shadow.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: rank.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                rank.name,
                style: TextStyle(
                  color: rank.name == 'Silver'
                      ? const Color(0xFF6B7280)
                      : rank.shadow,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RankDotData {
  final String name;
  final Color color;
  final Color shadow;

  const _RankDotData({
    required this.name,
    required this.color,
    required this.shadow,
  });
}