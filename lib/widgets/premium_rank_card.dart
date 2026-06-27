import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'app_logo.dart';

class PremiumRankCard extends StatelessWidget {
  final String customerName;
  final String customerRank;
  final int customerPoints;
  final String avatarUrl;
  final bool isLoggedIn;
  final Map<String, dynamic>? rankData;
  final VoidCallback? onTap;
  final IconData actionIcon;
  final bool showActionIcon;

  const PremiumRankCard({
    super.key,
    required this.customerName,
    required this.customerRank,
    required this.customerPoints,
    required this.avatarUrl,
    required this.isLoggedIn,
    this.rankData,
    this.onTap,
    this.actionIcon = Icons.restaurant_menu_rounded,
    this.showActionIcon = true,
  });

  Color colorFromHex(String? hex, Color fallback) {
    if (hex == null || hex.trim().isEmpty) {
      return fallback;
    }

    var value = hex.replaceAll('#', '').trim();

    if (value.length == 6) {
      value = 'FF$value';
    }

    try {
      return Color(int.parse(value, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  String getRankKey(String rank) {
    final value = rank.toLowerCase().trim();

    if (value == 'diamond' ||
        value == 'kim cương' ||
        value == 'kim cuong' ||
        value == 'kc') {
      return 'diamond';
    }

    if (value == 'gold' ||
        value == 'vàng' ||
        value == 'vang') {
      return 'gold';
    }

    if (value == 'silver' ||
        value == 'bạc' ||
        value == 'bac') {
      return 'silver';
    }

    if (value == 'bronze' ||
        value == 'đồng' ||
        value == 'dong') {
      return 'bronze';
    }

    return 'member';
  }

  IconData getRankIconByKey(String key) {
    final value = key.toLowerCase().trim();

    switch (value) {
      case 'diamond':
        return Icons.diamond_rounded;

      case 'workspace_premium':
      case 'gold':
        return Icons.workspace_premium_rounded;

      case 'military_tech':
      case 'silver':
        return Icons.military_tech_rounded;

      case 'local_cafe':
      case 'bronze':
      case 'member':
        return Icons.local_cafe_rounded;

      case 'star':
        return Icons.star_rounded;

      case 'crown':
        return Icons.emoji_events_rounded;

      case 'verified':
        return Icons.verified_rounded;

      default:
        return Icons.local_cafe_rounded;
    }
  }

  String getRankText(String rank) {
    final key = getRankKey(rank);

    switch (key) {
      case 'diamond':
        return 'Kim cương';
      case 'gold':
        return 'Vàng';
      case 'silver':
        return 'Bạc';
      case 'bronze':
        return 'Đồng';
      default:
        return 'Member';
    }
  }

  String getRankSubtitle(String rank) {
    final key = getRankKey(rank);

    switch (key) {
      case 'diamond':
        return 'Khách hàng cao cấp nhất của Chill Bites';
      case 'gold':
        return 'Khách hàng VIP với nhiều ưu đãi hơn';
      case 'silver':
        return 'Khách hàng thân thiết';
      case 'bronze':
        return 'Khách hàng mới của Chill Bites';
      default:
        return 'Starter Reward Member';
    }
  }

  String getTextValue(String key, String fallback) {
    final value = rankData?[key];

    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    final fallbackRankKey = getRankKey(customerRank);

    final rankKey = getTextValue(
      'code',
      fallbackRankKey,
    ).toLowerCase();

    final rankColor = colorFromHex(
      rankData?['primary_color']?.toString(),
      AppColors.rankMainColor(fallbackRankKey),
    );

    final rankDarkColor = colorFromHex(
      rankData?['dark_color']?.toString(),
      AppColors.rankDarkColor(fallbackRankKey),
    );

    final rankLightColor = colorFromHex(
      rankData?['light_color']?.toString(),
      AppColors.rankLightColor(fallbackRankKey),
    );

    final gradientStart = colorFromHex(
      rankData?['gradient_start']?.toString(),
      rankLightColor,
    );

    final gradientMiddle = colorFromHex(
      rankData?['gradient_middle']?.toString(),
      rankColor,
    );

    final gradientEnd = colorFromHex(
      rankData?['gradient_end']?.toString(),
      rankDarkColor,
    );

    final iconKey = getTextValue(
      'icon_key',
      rankKey,
    );

    final rankIcon = getRankIconByKey(iconKey);

    final rankText = getTextValue(
      'name',
      getRankText(customerRank),
    );

    final rankSubtitle = getTextValue(
      'subtitle',
      getTextValue(
        'description',
        getTextValue(
          'benefit_text',
          getRankSubtitle(customerRank),
        ),
      ),
    );

    final hasAvatar = avatarUrl.trim().isNotEmpty;

    final card = Container(
      height: 120,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            rankLightColor,
            rankColor,
            rankDarkColor,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(isDark ? 0.36 : 0.30),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientStart,
                gradientMiddle,
                gradientEnd,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: PremiumRankCardPatternPainter(
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
                            offset: const Offset(0, 7),
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

                    const SizedBox(width: 13),

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
                              const SizedBox(width: 6),
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

                          const SizedBox(height: 5),

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
                                  offset: const Offset(0, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 5),

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

                          const SizedBox(height: 6),

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
                                    const SizedBox(width: 4),
                                    Text(
                                      rankText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

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
                                    style: const TextStyle(
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

                    if (showActionIcon) ...[
                      const SizedBox(width: 8),
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
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          actionIcon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: card,
    );
  }
}

class PremiumRankCardPatternPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  PremiumRankCardPatternPainter({
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
  bool shouldRepaint(covariant PremiumRankCardPatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDark != isDark;
  }
}