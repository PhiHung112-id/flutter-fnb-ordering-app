import 'package:flutter/material.dart';

class AppColors {
  // =========================
  // MÀU GỐC CỦA APP
  // =========================
  static const Color orange = Color(0xFFFF7A00);
  static const Color orangeDark = Color(0xFFE85D04);
  static const Color orangeLight = Color(0xFFFFA726);
  static const Color orangeSoft = Color(0xFFFFE0B5);

  static const Color black = Color(0xFF0F0F0F);
  static const Color blackCard = Color(0xFF1A1A1A);
  static const Color blackSoft = Color(0xFF242424);

  static const Color white = Colors.white;
  static const Color whiteSoft = Color(0xFFFFF8F0);

  // =========================
  // MÀU RANK KIM LOẠI
  // =========================

  // Member / Default - cam đồng
  static const Color memberMain = Color(0xFFFF7A00);
  static const Color memberDark = Color(0xFF7A3100);
  static const Color memberDeep = Color(0xFF3A1600);
  static const Color memberLight = Color(0xFFFFD2A1);
  static const Color memberHighlight = Color(0xFFFFF0D6);

  // Silver - bạc kim loại
  static const Color silverMain = Color(0xFFBFC7D5);
  static const Color silverDark = Color(0xFF475569);
  static const Color silverDeep = Color(0xFF1E293B);
  static const Color silverLight = Color(0xFFE5E7EB);
  static const Color silverHighlight = Color(0xFFFFFFFF);

  // Gold - vàng kim loại
  static const Color goldMain = Color(0xFFFFC107);
  static const Color goldDark = Color(0xFF8A5D00);
  static const Color goldDeep = Color(0xFF3B2200);
  static const Color goldLight = Color(0xFFFFE08A);
  static const Color goldHighlight = Color(0xFFFFF8D6);
  static const Color goldCopper = Color(0xFFC88400);

  // Diamond - kim cương xanh
  static const Color diamondMain = Color(0xFF38BDF8);
  static const Color diamondDark = Color(0xFF075985);
  static const Color diamondDeep = Color(0xFF082F49);
  static const Color diamondLight = Color(0xFF67E8F9);
  static const Color diamondHighlight = Color(0xFFFFFFFF);

  // =========================
  // CHECK DARK MODE
  // =========================
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // =========================
  // PRIMARY THEO THEME HIỆN TẠI
  // =========================
  static Color primary(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color primarySoft(BuildContext context) {
    return primary(context).withOpacity(
      isDark(context) ? 0.22 : 0.14,
    );
  }

  static Color primaryBorder(BuildContext context) {
    return primary(context).withOpacity(
      isDark(context) ? 0.34 : 0.26,
    );
  }

  static Color primaryShadow(BuildContext context) {
    return primary(context).withOpacity(
      isDark(context) ? 0.34 : 0.24,
    );
  }

  // =========================
  // BACKGROUND / CARD / TEXT
  // =========================
  static Color background(BuildContext context) {
    if (isDark(context)) return black;

    final p = primary(context);

    if (p.value == goldMain.value) {
      return const Color(0xFFFFF7DF);
    }

    if (p.value == silverMain.value || p.value == const Color(0xFF94A3B8).value) {
      return const Color(0xFFF5F7FA);
    }

    if (p.value == diamondMain.value) {
      return const Color(0xFFEFFAFF);
    }

    return whiteSoft;
  }

  static Color card(BuildContext context) {
    return isDark(context) ? blackCard : white;
  }

  static Color cardSoft(BuildContext context) {
    if (isDark(context)) return blackSoft;

    final p = primary(context);

    if (p.value == goldMain.value) {
      return const Color(0xFFFFEFB8);
    }

    if (p.value == silverMain.value || p.value == const Color(0xFF94A3B8).value) {
      return const Color(0xFFE9EEF5);
    }

    if (p.value == diamondMain.value) {
      return const Color(0xFFDDF7FF);
    }

    return const Color(0xFFFFF3E8);
  }

  static Color textPrimary(BuildContext context) {
    return isDark(context) ? white : black;
  }

  static Color textSecondary(BuildContext context) {
    return isDark(context) ? Colors.white70 : const Color(0xFF8D7B68);
  }

  static Color border(BuildContext context) {
    if (isDark(context)) {
      return Colors.white.withOpacity(0.08);
    }

    return primary(context).withOpacity(0.18);
  }

  static Color shadow(BuildContext context) {
    return isDark(context)
        ? Colors.black.withOpacity(0.35)
        : Colors.black.withOpacity(0.055);
  }

  static Color orangeChip(BuildContext context) {
    return isDark(context) ? const Color(0xFF3A2415) : orangeSoft;
  }

  static Color primaryChip(BuildContext context) {
    return primary(context).withOpacity(
      isDark(context) ? 0.24 : 0.16,
    );
  }

  // =========================
  // RANK COLOR
  // =========================
  static Color rankMainColor(String rank) {
    switch (rank.toLowerCase()) {
      case 'diamond':
        return diamondMain;
      case 'gold':
        return goldMain;
      case 'silver':
        return silverMain;
      default:
        return memberMain;
    }
  }

  static Color rankDarkColor(String rank) {
    switch (rank.toLowerCase()) {
      case 'diamond':
        return diamondDark;
      case 'gold':
        return goldDark;
      case 'silver':
        return silverDark;
      default:
        return memberDark;
    }
  }

  static Color rankDeepColor(String rank) {
    switch (rank.toLowerCase()) {
      case 'diamond':
        return diamondDeep;
      case 'gold':
        return goldDeep;
      case 'silver':
        return silverDeep;
      default:
        return memberDeep;
    }
  }

  static Color rankLightColor(String rank) {
    switch (rank.toLowerCase()) {
      case 'diamond':
        return diamondLight;
      case 'gold':
        return goldLight;
      case 'silver':
        return silverLight;
      default:
        return memberLight;
    }
  }

  static Color rankHighlightColor(String rank) {
    switch (rank.toLowerCase()) {
      case 'diamond':
        return diamondHighlight;
      case 'gold':
        return goldHighlight;
      case 'silver':
        return silverHighlight;
      default:
        return memberHighlight;
    }
  }

  static IconData rankIcon(String rank) {
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

  // =========================
  // GRADIENT CŨ
  // =========================
  static LinearGradient orangeGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFD2A1),
        Color(0xFFFFA726),
        Color(0xFFFF7A00),
        Color(0xFFE85D04),
      ],
      stops: [0.0, 0.30, 0.66, 1.0],
    );
  }

  static LinearGradient blackOrangeGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        black,
        blackCard,
        orange,
      ],
    );
  }

  // =========================
  // GRADIENT THEO PRIMARY
  // =========================
  static LinearGradient primaryGradient(BuildContext context) {
    final p = primary(context);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        lighten(p, 0.30),
        p,
        darken(p, 0.26),
      ],
    );
  }

  static LinearGradient primaryDarkGradient(BuildContext context) {
    final p = primary(context);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        black,
        blackCard,
        p,
      ],
    );
  }

  // =========================
  // GOLD METALLIC - QUAN TRỌNG
  // =========================
  static LinearGradient goldMetalGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2A1700),
        Color(0xFF6B3F00),
        Color(0xFFC88400),
        Color(0xFFFFC107),
        Color(0xFFFFE08A),
        Color(0xFFFFFFFF),
        Color(0xFFFFF4C7),
        Color(0xFFFFC107),
        Color(0xFF8A5D00),
        Color(0xFF3B2200),
      ],
      stops: [
        0.00,
        0.10,
        0.22,
        0.34,
        0.45,
        0.52,
        0.60,
        0.72,
        0.88,
        1.00,
      ],
    );
  }

  static LinearGradient goldMetalBorderGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFFFF4C7),
        Color(0xFFFFC107),
        Color(0xFFC88400),
        Color(0xFF6B3F00),
        Color(0xFFFFE08A),
        Color(0xFFFFFFFF),
      ],
      stops: [0.0, 0.16, 0.32, 0.52, 0.70, 0.88, 1.0],
    );
  }

  static LinearGradient goldDarkMetalGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0F0800),
        Color(0xFF2A1700),
        Color(0xFF6B3F00),
        Color(0xFFC88400),
        Color(0xFFFFC107),
      ],
      stops: [0.0, 0.22, 0.48, 0.75, 1.0],
    );
  }

  // =========================
  // SILVER METALLIC
  // =========================
  static LinearGradient silverMetalGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1E293B),
        Color(0xFF475569),
        Color(0xFF94A3B8),
        Color(0xFFE5E7EB),
        Color(0xFFFFFFFF),
        Color(0xFFCBD5E1),
        Color(0xFF64748B),
        Color(0xFF334155),
      ],
      stops: [0.0, 0.14, 0.28, 0.42, 0.52, 0.66, 0.82, 1.0],
    );
  }

  static LinearGradient silverMetalBorderGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFE5E7EB),
        Color(0xFF94A3B8),
        Color(0xFF475569),
        Color(0xFFCBD5E1),
        Color(0xFFFFFFFF),
      ],
      stops: [0.0, 0.20, 0.42, 0.62, 0.82, 1.0],
    );
  }

  // =========================
  // DIAMOND METALLIC
  // =========================
  static LinearGradient diamondMetalGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF082F49),
        Color(0xFF075985),
        Color(0xFF0EA5E9),
        Color(0xFF38BDF8),
        Color(0xFF67E8F9),
        Color(0xFFFFFFFF),
        Color(0xFFBAE6FD),
        Color(0xFF38BDF8),
        Color(0xFF075985),
      ],
      stops: [0.0, 0.13, 0.26, 0.38, 0.48, 0.56, 0.66, 0.80, 1.0],
    );
  }

  static LinearGradient diamondMetalBorderGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFBAE6FD),
        Color(0xFF38BDF8),
        Color(0xFF075985),
        Color(0xFF67E8F9),
        Color(0xFFFFFFFF),
      ],
      stops: [0.0, 0.18, 0.38, 0.58, 0.78, 1.0],
    );
  }

  // =========================
  // METALLIC THEO RANK
  // =========================
  static LinearGradient metalBorderGradientByRank(String rank) {
    switch (rank.toLowerCase()) {
      case 'gold':
        return goldMetalBorderGradient();
      case 'silver':
        return silverMetalBorderGradient();
      case 'diamond':
        return diamondMetalBorderGradient();
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF0D6),
            Color(0xFFFFB347),
            Color(0xFFFF7A00),
            Color(0xFF7A3100),
            Color(0xFFFFD2A1),
          ],
        );
    }
  }

  static LinearGradient metalCardGradientByRank(
      BuildContext context,
      String rank,
      ) {
    final darkMode = isDark(context);

    switch (rank.toLowerCase()) {
      case 'gold':
        return darkMode ? goldDarkMetalGradient() : goldMetalGradient();

      case 'silver':
        return silverMetalGradient();

      case 'diamond':
        return diamondMetalGradient();

      default:
        return orangeGradient();
    }
  }

  static LinearGradient metallicTextGradient(String rank) {
    switch (rank.toLowerCase()) {
      case 'gold':
        return goldMetalGradient();
      case 'silver':
        return silverMetalGradient();
      case 'diamond':
        return diamondMetalGradient();
      default:
        return orangeGradient();
    }
  }

  // =========================
  // HIGHLIGHT PHỦ BÓNG
  // =========================
  static LinearGradient metalShineOverlay() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.42),
        Colors.white.withOpacity(0.08),
        Colors.transparent,
        Colors.white.withOpacity(0.16),
      ],
      stops: const [0.0, 0.22, 0.55, 1.0],
    );
  }

  static LinearGradient metalGlassOverlay() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.32),
        Colors.white.withOpacity(0.06),
        Colors.black.withOpacity(0.10),
      ],
      stops: const [0.0, 0.45, 1.0],
    );
  }

  // =========================
  // HÀM PHỤ
  // =========================
  static Color lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }

  static Color darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }
}