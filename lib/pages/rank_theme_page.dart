import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';

class RankThemePage extends ConsumerWidget {
  RankThemePage({super.key});

  int getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(customerProfileProvider);
    final selectedTheme = ref.watch(selectedRankThemeProvider);
    final points = getIntValue(profile?['points']);

    final themes = [
      _RankThemeData(
        keyName: 'default',
        title: 'Mặc định',
        subtitle: 'Cam ánh kim',
        description: 'Chủ đề cơ bản của Chill Bites, dùng được cho mọi tài khoản.',
        requiredPoints: 0,
        color: const Color(0xFFFF7A00),
        darkColor: const Color(0xFF7A3100),
        lightColor: const Color(0xFFFFD2A1),
        icon: Icons.local_cafe_rounded,
      ),
      _RankThemeData(
        keyName: 'silver',
        title: 'Silver',
        subtitle: 'Bạc kim loại',
        description: 'Mở khóa khi đạt 500 điểm tích lũy.',
        requiredPoints: 500,
        color: const Color(0xFFCBD5E1),
        darkColor: const Color(0xFF475569),
        lightColor: const Color(0xFFFFFFFF),
        icon: Icons.military_tech_rounded,
      ),
      _RankThemeData(
        keyName: 'gold',
        title: 'Gold',
        subtitle: 'Vàng hoàng kim',
        description: 'Mở khóa khi đạt 1000 điểm tích lũy.',
        requiredPoints: 1000,
        color: const Color(0xFFFFC107),
        darkColor: const Color(0xFF7A4D00),
        lightColor: const Color(0xFFFFF4C7),
        icon: Icons.workspace_premium_rounded,
      ),
      _RankThemeData(
        keyName: 'diamond',
        title: 'Diamond',
        subtitle: 'Kim cương xanh',
        description: 'Mở khóa khi đạt 2000 điểm tích lũy.',
        requiredPoints: 2000,
        color: const Color(0xFF38BDF8),
        darkColor: const Color(0xFF075985),
        lightColor: const Color(0xFFE0F7FF),
        icon: Icons.diamond_rounded,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Chủ đề theo rank',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(
            points: points,
            selectedTheme: selectedTheme,
          ),

          const SizedBox(height: 18),

          Text(
            'Bộ sưu tập chủ đề',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Rank cao có thể dùng lại chủ đề rank thấp. Chủ đề chưa đủ điểm sẽ bị khóa.',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          ...themes.map((theme) {
            final unlocked = points >= theme.requiredPoints;
            final selected = selectedTheme == theme.keyName;

            return _RankThemeCard(
              theme: theme,
              unlocked: unlocked,
              selected: selected,
              points: points,
              onUse: () {
                if (!unlocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Bạn cần ${theme.requiredPoints} điểm để mở khóa ${theme.title}',
                      ),
                    ),
                  );
                  return;
                }

                ref
                    .read(selectedRankThemeProvider.notifier)
                    .selectTheme(theme.keyName);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã áp dụng ${theme.subtitle}'),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int points;
  final String selectedTheme;

  _HeaderCard({
    required this.points,
    required this.selectedTheme,
  });

  String getThemeText(String value) {
    switch (value) {
      case 'silver':
        return 'Bạc kim loại';
      case 'gold':
        return 'Vàng hoàng kim';
      case 'diamond':
        return 'Kim cương xanh';
      default:
        return 'Cam mặc định';
    }
  }

  IconData getThemeIcon(String value) {
    switch (value) {
      case 'silver':
        return Icons.military_tech_rounded;
      case 'gold':
        return Icons.workspace_premium_rounded;
      case 'diamond':
        return Icons.diamond_rounded;
      default:
        return Icons.local_cafe_rounded;
    }
  }

  List<Color> getHeaderColors(String value) {
    switch (value) {
      case 'silver':
        return [
          const Color(0xFF0F172A),
          const Color(0xFF475569),
          const Color(0xFFCBD5E1),
          const Color(0xFFFFFFFF),
        ];
      case 'gold':
        return [
          const Color(0xFF2A1700),
          const Color(0xFF8A5D00),
          const Color(0xFFFFC107),
          const Color(0xFFFFF4C7),
        ];
      case 'diamond':
        return [
          const Color(0xFF082F49),
          const Color(0xFF075985),
          const Color(0xFF38BDF8),
          const Color(0xFFE0F7FF),
        ];
      default:
        return [
          const Color(0xFF3A1600),
          const Color(0xFF7A3100),
          const Color(0xFFFF7A00),
          const Color(0xFFFFD2A1),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = getHeaderColors(selectedTheme);
    final icon = getThemeIcon(selectedTheme);

    return Container(
      width: double.infinity,
      height: 142,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[3],
            Colors.white,
            colors[2],
            colors[1],
            colors[3],
          ],
          stops: const [0.0, 0.18, 0.42, 0.72, 1.0],
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: colors[2].withOpacity(
              AppColors.isDark(context) ? 0.32 : 0.26,
            ),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(31),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors[0],
                colors[1],
                colors[2],
                colors[3],
              ],
              stops: const [0.0, 0.32, 0.70, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MetalPatternPainter(
                    color: colors[2],
                  ),
                ),
              ),

              Positioned(
                right: -38,
                top: -45,
                child: Icon(
                  icon,
                  size: 165,
                  color: Colors.white.withOpacity(0.11),
                ),
              ),

              Positioned(
                right: 18,
                bottom: -52,
                child: Container(
                  width: 135,
                  height: 135,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.16),
                      width: 2,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: -36,
                bottom: -44,
                child: Container(
                  width: 115,
                  height: 115,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.26),
                        Colors.white.withOpacity(0.04),
                        Colors.transparent,
                        Colors.black.withOpacity(0.10),
                      ],
                      stops: const [0.0, 0.28, 0.58, 1.0],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Row(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            colors[2],
                            colors[3],
                            colors[1],
                            colors[3],
                            colors[2],
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors[2].withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.46),
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bộ sưu tập chủ đề',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.24),
                                  offset: const Offset(0, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.22),
                                  ),
                                ),
                                child: Text(
                                  '$points điểm',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.20),
                                  ),
                                ),
                                child: Text(
                                  getThemeText(selectedTheme),
                                  style: TextStyle(
                                    color: colors[3],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Chọn giao diện theo cấp bậc đã mở khóa',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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

class _RankThemeCard extends StatelessWidget {
  final _RankThemeData theme;
  final bool unlocked;
  final bool selected;
  final int points;
  final VoidCallback onUse;

  _RankThemeCard({
    required this.theme,
    required this.unlocked,
    required this.selected,
    required this.points,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final missingPoints = theme.requiredPoints - points;
    final progress = theme.requiredPoints == 0
        ? 1.0
        : (points / theme.requiredPoints).clamp(0.0, 1.0);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: unlocked ? 1 : 0.45,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: unlocked
              ? _metalBorderGradient(theme)
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade400,
              Colors.grey.shade700,
              Colors.grey.shade500,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (unlocked)
              BoxShadow(
                color: theme.color.withOpacity(selected ? 0.34 : 0.18),
                blurRadius: selected ? 22 : 14,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(27),
          child: Container(
            decoration: BoxDecoration(
              gradient: unlocked
                  ? _metalCardGradient(theme, context)
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.card(context),
                  AppColors.cardSoft(context),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MetalPatternPainter(
                      color: unlocked ? theme.color : Colors.grey,
                    ),
                  ),
                ),

                Positioned(
                  right: -26,
                  top: -28,
                  child: Icon(
                    theme.icon,
                    size: 112,
                    color: Colors.white.withOpacity(unlocked ? 0.12 : 0.06),
                  ),
                ),

                Positioned(
                  right: 12,
                  bottom: -35,
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      _RankIconBox(
                        theme: theme,
                        unlocked: unlocked,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    theme.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: unlocked
                                          ? Colors.white
                                          : AppColors.textPrimary(context),
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                if (selected) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.36),
                                      ),
                                    ),
                                    child: Text(
                                      'Đang dùng',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 4),

                            Text(
                              theme.subtitle,
                              style: TextStyle(
                                color: unlocked
                                    ? theme.lightColor
                                    : AppColors.textSecondary(context),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              unlocked
                                  ? theme.description
                                  : 'Còn thiếu $missingPoints điểm để mở khóa.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: unlocked
                                    ? Colors.white.withOpacity(0.78)
                                    : AppColors.textSecondary(context),
                                fontSize: 12.5,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 10),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: unlocked
                                    ? Colors.black.withOpacity(0.25)
                                    : AppColors.border(context),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  unlocked ? theme.lightColor : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      SizedBox(
                        width: 86,
                        child: ElevatedButton(
                          onPressed: unlocked && !selected ? onUse : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: unlocked
                                ? Colors.white.withOpacity(0.92)
                                : Colors.grey.shade500,
                            foregroundColor:
                            unlocked ? theme.darkColor : Colors.white,
                            disabledBackgroundColor: selected
                                ? Colors.white.withOpacity(0.32)
                                : Colors.grey.shade500,
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            selected
                                ? 'Đã bật'
                                : unlocked
                                ? 'Bật'
                                : 'Khóa',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _metalBorderGradient(_RankThemeData theme) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.lightColor,
        Colors.white,
        theme.color,
        theme.darkColor,
        theme.lightColor,
      ],
      stops: const [0.0, 0.22, 0.48, 0.72, 1.0],
    );
  }

  LinearGradient _metalCardGradient(
      _RankThemeData theme,
      BuildContext context,
      ) {
    final isDark = AppColors.isDark(context);

    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.black,
          theme.darkColor,
          theme.color.withOpacity(0.72),
        ],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.darkColor,
        theme.color,
        theme.lightColor,
      ],
    );
  }
}

class _RankIconBox extends StatelessWidget {
  final _RankThemeData theme;
  final bool unlocked;

  _RankIconBox({
    required this.theme,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: unlocked
            ? SweepGradient(
          colors: [
            theme.color,
            theme.lightColor,
            theme.darkColor,
            theme.lightColor,
            theme.color,
          ],
        )
            : SweepGradient(
          colors: [
            Colors.grey,
            Colors.grey.shade300,
            Colors.grey.shade700,
            Colors.grey.shade300,
            Colors.grey,
          ],
        ),
        boxShadow: [
          if (unlocked)
            BoxShadow(
              color: theme.color.withOpacity(0.32),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.25),
          border: Border.all(
            color: Colors.white.withOpacity(0.42),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              theme.icon,
              color: Colors.white,
              size: 35,
            ),
            if (!unlocked)
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.50),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetalPatternPainter extends CustomPainter {
  final Color color;

  _MetalPatternPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;

    const gap = 18.0;

    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        linePaint,
      );
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.32),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.78, size.height * 0.35),
          radius: 110,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.35),
      110,
      glowPaint,
    );

    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.35),
          Colors.white.withOpacity(0.02),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final shinePath = Path()
      ..moveTo(-30, 0)
      ..lineTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.12, size.height)
      ..lineTo(-70, size.height)
      ..close();

    canvas.drawPath(shinePath, shinePaint);
  }

  @override
  bool shouldRepaint(covariant _MetalPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _RankThemeData {
  final String keyName;
  final String title;
  final String subtitle;
  final String description;
  final int requiredPoints;
  final Color color;
  final Color darkColor;
  final Color lightColor;
  final IconData icon;

  _RankThemeData({
    required this.keyName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.requiredPoints,
    required this.color,
    required this.darkColor,
    required this.lightColor,
    required this.icon,
  });
}