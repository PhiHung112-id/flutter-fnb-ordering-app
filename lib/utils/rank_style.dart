import 'package:flutter/material.dart';

class RankStyle {
  final String rankName;
  final String title;
  final String subtitle;
  final String benefitText;

  final LinearGradient gradient;
  final Color primary;
  final Color secondary;
  final Color shadow;
  final Color textColor;
  final Color chipTextColor;

  final IconData icon;
  final IconData patternIcon;

  final int minPoint;
  final int maxPoint;
  final int discount;

  RankStyle({
    required this.rankName,
    required this.title,
    required this.subtitle,
    required this.benefitText,
    required this.gradient,
    required this.primary,
    required this.secondary,
    required this.shadow,
    required this.textColor,
    required this.chipTextColor,
    required this.icon,
    required this.patternIcon,
    required this.minPoint,
    required this.maxPoint,
    required this.discount,
  });
}

class RankHelper {
  static RankStyle getStyle(String rank) {
    final value = rank.toLowerCase().trim();

    if (value == 'diamond' ||
        value == 'kim cương' ||
        value == 'kc' ||
        value == 'kim cuong') {
      return RankStyle(
        rankName: 'Diamond',
        title: 'Diamond Member',
        subtitle: 'Khách hàng thân thiết cao cấp',
        benefitText: 'Giảm 8% mỗi đơn',
        primary: Color(0xFF38BDF8),
        secondary: Color(0xFF0EA5E9),
        shadow: Color(0xFF38BDF8),
        textColor: Colors.white,
        chipTextColor: Color(0xFF075985),
        icon: Icons.diamond_rounded,
        patternIcon: Icons.auto_awesome_rounded,
        minPoint: 2000,
        maxPoint: 2000,
        discount: 8,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF031B2E),
            Color(0xFF075985),
            Color(0xFF0EA5E9),
            Color(0xFF7DD3FC),
          ],
        ),
      );
    }

    if (value == 'gold' ||
        value == 'vàng' ||
        value == 'vang') {
      return RankStyle(
        rankName: 'Gold',
        title: 'Gold Member',
        subtitle: 'Khách hàng thân thiết hạng vàng',
        benefitText: 'Giảm 5% mỗi đơn',
        primary: Color(0xFFFFD700),
        secondary: Color(0xFFFFB300),
        shadow: Color(0xFFFFC107),
        textColor: Colors.white,
        chipTextColor: Color(0xFF7A4D00),
        icon: Icons.workspace_premium_rounded,
        patternIcon: Icons.stars_rounded,
        minPoint: 1000,
        maxPoint: 1999,
        discount: 5,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B1A00),
            Color(0xFF7A4D00),
            Color(0xFFD99A00),
            Color(0xFFFFD700),
          ],
        ),
      );
    }

    if (value == 'silver' ||
        value == 'bạc' ||
        value == 'bac') {
      return RankStyle(
        rankName: 'Silver',
        title: 'Silver Member',
        subtitle: 'Khách hàng thân thiết hạng bạc',
        benefitText: 'Giảm 3% mỗi đơn',
        primary: Color(0xFFE5E7EB),
        secondary: Color(0xFF9CA3AF),
        shadow: Color(0xFFD1D5DB),
        textColor: Colors.white,
        chipTextColor: Color(0xFF374151),
        icon: Icons.military_tech_rounded,
        patternIcon: Icons.shield_rounded,
        minPoint: 500,
        maxPoint: 999,
        discount: 3,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F2937),
            Color(0xFF4B5563),
            Color(0xFF9CA3AF),
            Color(0xFFE5E7EB),
          ],
        ),
      );
    }

    return RankStyle(
      rankName: 'Member',
      title: 'Member',
      subtitle: 'Thành viên cơ bản',
      benefitText: 'Tích điểm nhận ưu đãi',
      primary: Color(0xFF9CA3AF),
      secondary: Color(0xFF6B7280),
      shadow: Color(0xFF4B5563),
      textColor: Colors.white,
      chipTextColor: Color(0xFF1F2937),
      icon: Icons.person_rounded,
      patternIcon: Icons.local_cafe_rounded,
      minPoint: 0,
      maxPoint: 499,
      discount: 0,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF111827),
          Color(0xFF1F2937),
          Color(0xFF374151),
          Color(0xFF6B7280),
        ],
      ),
    );
  }

  static String getRankByPoints(int points) {
    if (points >= 2000) return 'Diamond';
    if (points >= 1000) return 'Gold';
    if (points >= 500) return 'Silver';
    return 'Member';
  }

  static int getDiscountByRank(String rank) {
    return getStyle(rank).discount;
  }

  static int getCurrentRankStart(int points) {
    if (points >= 2000) return 2000;
    if (points >= 1000) return 1000;
    if (points >= 500) return 500;
    return 0;
  }

  static int getNextRankPoint(int points) {
    if (points >= 2000) return 2000;
    if (points >= 1000) return 2000;
    if (points >= 500) return 1000;
    return 500;
  }

  static String getNextRankName(int points) {
    if (points >= 2000) return 'Diamond';
    if (points >= 1000) return 'Diamond';
    if (points >= 500) return 'Gold';
    return 'Silver';
  }

  static int getNextRankDiscount(int points) {
    if (points >= 2000) return 8;
    if (points >= 1000) return 8;
    if (points >= 500) return 5;
    return 3;
  }

  static int getMissingPoints(int points) {
    if (points >= 2000) return 0;
    return getNextRankPoint(points) - points;
  }

  static double getProgress(int points) {
    if (points >= 2000) return 1;

    final start = getCurrentRankStart(points);
    final next = getNextRankPoint(points);

    if (next == start) return 1;

    final progress = (points - start) / (next - start);
    return progress.clamp(0.0, 1.0);
  }

  static String getPointRangeText(int points) {
    if (points >= 2000) {
      return '2000+ điểm';
    }

    final start = getCurrentRankStart(points);
    final next = getNextRankPoint(points);

    return '$start / $next điểm';
  }

  static String getRankVietnameseName(String rank) {
    final value = rank.toLowerCase().trim();

    if (value == 'diamond' ||
        value == 'kim cương' ||
        value == 'kc' ||
        value == 'kim cuong') {
      return 'Kim cương';
    }

    if (value == 'gold' ||
        value == 'vàng' ||
        value == 'vang') {
      return 'Vàng';
    }

    if (value == 'silver' ||
        value == 'bạc' ||
        value == 'bac') {
      return 'Bạc';
    }

    return 'Thành viên';
  }

  static String getRankBenefitText(String rank) {
    return getStyle(rank).benefitText;
  }

  static String getRankSubtitle(String rank) {
    return getStyle(rank).subtitle;
  }
}