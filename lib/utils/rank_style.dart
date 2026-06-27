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
  static String normalizeRank(String rank) {
    return rank.toLowerCase().trim();
  }

  static RankStyle getStyle(String rank) {
    final value = normalizeRank(rank);

    if (value == 'diamond' ||
        value == 'kim cương' ||
        value == 'kim cuong' ||
        value == 'kc') {
      return RankStyle(
        rankName: 'Diamond',
        title: 'Diamond Member',
        subtitle: 'Khách hàng cao cấp nhất của Chill Bites',
        benefitText: 'Giảm 10% mỗi đơn',
        primary: const Color(0xFF38BDF8),
        secondary: const Color(0xFF0EA5E9),
        shadow: const Color(0xFF38BDF8),
        textColor: Colors.white,
        chipTextColor: const Color(0xFF075985),
        icon: Icons.diamond_rounded,
        patternIcon: Icons.auto_awesome_rounded,
        minPoint: 2500,
        maxPoint: 999999,
        discount: 10,
        gradient: const LinearGradient(
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

    if (value == 'gold' || value == 'vàng' || value == 'vang') {
      return RankStyle(
        rankName: 'Gold',
        title: 'Gold Member',
        subtitle: 'Khách hàng VIP với nhiều ưu đãi hơn',
        benefitText: 'Giảm 5% mỗi đơn',
        primary: const Color(0xFFFFD700),
        secondary: const Color(0xFFFFB300),
        shadow: const Color(0xFFFFC107),
        textColor: Colors.white,
        chipTextColor: const Color(0xFF7A4D00),
        icon: Icons.workspace_premium_rounded,
        patternIcon: Icons.stars_rounded,
        minPoint: 1500,
        maxPoint: 2499,
        discount: 5,
        gradient: const LinearGradient(
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

    if (value == 'silver' || value == 'bạc' || value == 'bac') {
      return RankStyle(
        rankName: 'Silver',
        title: 'Silver Member',
        subtitle: 'Khách hàng thân thiết hạng bạc',
        benefitText: 'Giảm 3% mỗi đơn',
        primary: const Color(0xFFE5E7EB),
        secondary: const Color(0xFF9CA3AF),
        shadow: const Color(0xFFD1D5DB),
        textColor: Colors.white,
        chipTextColor: const Color(0xFF374151),
        icon: Icons.military_tech_rounded,
        patternIcon: Icons.shield_rounded,
        minPoint: 500,
        maxPoint: 1499,
        discount: 3,
        gradient: const LinearGradient(
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
      subtitle: 'Starter Reward Member',
      benefitText: 'Tích điểm nhận ưu đãi',
      primary: const Color(0xFFFF7A00),
      secondary: const Color(0xFFFFA726),
      shadow: const Color(0xFFFF7A00),
      textColor: Colors.white,
      chipTextColor: const Color(0xFF7C2D12),
      icon: Icons.local_cafe_rounded,
      patternIcon: Icons.restaurant_menu_rounded,
      minPoint: 0,
      maxPoint: 499,
      discount: 0,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFB15C),
          Color(0xFFFF8A1F),
          Color(0xFFFF7A00),
          Color(0xFFE85D04),
        ],
      ),
    );
  }

  static String getRankByPoints(int points) {
    if (points >= 2500) return 'Diamond';
    if (points >= 1500) return 'Gold';
    if (points >= 500) return 'Silver';
    return 'Member';
  }

  static int getDiscountByRank(String rank) {
    return getStyle(rank).discount;
  }

  static int getCurrentRankStart(int points) {
    if (points >= 2500) return 2500;
    if (points >= 1500) return 1500;
    if (points >= 500) return 500;
    return 0;
  }

  static int getNextRankPoint(int points) {
    if (points >= 2500) return 2500;
    if (points >= 1500) return 2500;
    if (points >= 500) return 1500;
    return 500;
  }

  static String getNextRankName(int points) {
    if (points >= 2500) return 'Diamond';
    if (points >= 1500) return 'Diamond';
    if (points >= 500) return 'Gold';
    return 'Silver';
  }

  static int getNextRankDiscount(int points) {
    if (points >= 2500) return 10;
    if (points >= 1500) return 10;
    if (points >= 500) return 5;
    return 3;
  }

  static int getMissingPoints(int points) {
    if (points >= 2500) return 0;

    final missing = getNextRankPoint(points) - points;

    return missing < 0 ? 0 : missing;
  }

  static double getProgress(int points) {
    if (points <= 0) return 0.0;
    if (points >= 2500) return 1.0;

    final start = getCurrentRankStart(points);
    final next = getNextRankPoint(points);

    if (next <= start) return 1.0;

    final progress = (points - start) / (next - start);

    return progress.clamp(0.0, 1.0);
  }

  static String getPointRangeText(int points) {
    if (points >= 2500) {
      return '$points điểm - MAX';
    }

    final next = getNextRankPoint(points);

    return '$points / $next điểm';
  }

  static String getProgressPercentText(int points) {
    final percent = (getProgress(points) * 100).round();

    return '$percent%';
  }

  static String getRankVietnameseName(String rank) {
    final value = normalizeRank(rank);

    if (value == 'diamond' ||
        value == 'kim cương' ||
        value == 'kim cuong' ||
        value == 'kc') {
      return 'Kim cương';
    }

    if (value == 'gold' || value == 'vàng' || value == 'vang') {
      return 'Vàng';
    }

    if (value == 'silver' || value == 'bạc' || value == 'bac') {
      return 'Bạc';
    }

    if (value == 'bronze' || value == 'đồng' || value == 'dong') {
      return 'Đồng';
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