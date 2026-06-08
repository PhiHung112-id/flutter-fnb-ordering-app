import 'package:flutter/material.dart';

import '../utils/rank_style.dart';

class RankMembershipCard extends StatelessWidget {
  final String fullName;
  final String phoneOrEmail;
  final String rank;
  final int points;
  final String avatarUrl;
  final String firstLetter;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onAvatarTap;

  RankMembershipCard({
    super.key,
    required this.fullName,
    required this.phoneOrEmail,
    required this.rank,
    required this.points,
    required this.avatarUrl,
    required this.firstLetter,
    this.compact = false,
    this.onTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final rankStyle = RankHelper.getStyle(rank);
    final progress = RankHelper.getProgress(points);
    final nextRank = RankHelper.getNextRankName(points);
    final missingPoints = RankHelper.getMissingPoints(points);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(compact ? 26 : 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: _rankBorderGradient(rankStyle.rankName),
          borderRadius: BorderRadius.circular(compact ? 28 : 34),
          boxShadow: [
            BoxShadow(
              color: rankStyle.shadow.withOpacity(0.38),
              blurRadius: compact ? 18 : 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(compact ? 15 : 20),
          decoration: BoxDecoration(
            gradient: rankStyle.gradient,
            borderRadius: BorderRadius.circular(compact ? 25 : 31),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(compact ? 23 : 29),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _GamePattern(
                  rankName: rankStyle.rankName,
                  icon: rankStyle.patternIcon,
                ),

                if (rankStyle.rankName == 'Diamond') _DiamondGameEffect(),
                if (rankStyle.rankName == 'Gold') _GoldGameEffect(),
                if (rankStyle.rankName == 'Silver') _SilverGameEffect(),
                if (rankStyle.rankName == 'Member') _MemberGameEffect(),

                compact
                    ? _CompactGameContent(
                  rankStyle: rankStyle,
                  fullName: fullName,
                  phoneOrEmail: phoneOrEmail,
                  points: points,
                  avatarUrl: avatarUrl,
                  firstLetter: firstLetter,
                  progress: progress,
                  onAvatarTap: onAvatarTap,
                )
                    : _LargeGameContent(
                  rankStyle: rankStyle,
                  fullName: fullName,
                  phoneOrEmail: phoneOrEmail,
                  points: points,
                  avatarUrl: avatarUrl,
                  firstLetter: firstLetter,
                  progress: progress,
                  nextRank: nextRank,
                  missingPoints: missingPoints,
                  onAvatarTap: onAvatarTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _rankBorderGradient(String rankName) {
    if (rankName == 'Diamond') {
      return LinearGradient(
        colors: [
          Color(0xFF7DD3FC),
          Color(0xFFFFFFFF),
          Color(0xFF38BDF8),
          Color(0xFF075985),
        ],
      );
    }

    if (rankName == 'Gold') {
      return LinearGradient(
        colors: [
          Color(0xFFFFF7AD),
          Color(0xFFFFD700),
          Color(0xFFB7791F),
          Color(0xFFFFF1A8),
        ],
      );
    }

    if (rankName == 'Silver') {
      return LinearGradient(
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFE5E7EB),
          Color(0xFF6B7280),
          Color(0xFFF9FAFB),
        ],
      );
    }

    return LinearGradient(
      colors: [
        Color(0xFF9CA3AF),
        Color(0xFF374151),
        Color(0xFF111827),
        Color(0xFF6B7280),
      ],
    );
  }
}

class _CompactGameContent extends StatelessWidget {
  final RankStyle rankStyle;
  final String fullName;
  final String phoneOrEmail;
  final int points;
  final String avatarUrl;
  final String firstLetter;
  final double progress;
  final VoidCallback? onAvatarTap;

  _CompactGameContent({
    required this.rankStyle,
    required this.fullName,
    required this.phoneOrEmail,
    required this.points,
    required this.avatarUrl,
    required this.firstLetter,
    required this.progress,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GameAvatar(
          avatarUrl: avatarUrl,
          firstLetter: firstLetter,
          rankColor: rankStyle.primary,
          rankIcon: rankStyle.icon,
          size: 78,
          onAvatarTap: onAvatarTap,
        ),

        SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RankTitleBadge(rankStyle: rankStyle),

              SizedBox(height: 7),

              Text(
                fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),

              SizedBox(height: 4),

              Text(
                phoneOrEmail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 10),

              _ExpBar(
                progress: progress,
                rankColor: rankStyle.primary,
                label: '$points EXP',
                compact: true,
              ),
            ],
          ),
        ),

        SizedBox(width: 8),

        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
            ),
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
      ],
    );
  }
}

class _LargeGameContent extends StatelessWidget {
  final RankStyle rankStyle;
  final String fullName;
  final String phoneOrEmail;
  final int points;
  final String avatarUrl;
  final String firstLetter;
  final double progress;
  final String nextRank;
  final int missingPoints;
  final VoidCallback? onAvatarTap;

  _LargeGameContent({
    required this.rankStyle,
    required this.fullName,
    required this.phoneOrEmail,
    required this.points,
    required this.avatarUrl,
    required this.firstLetter,
    required this.progress,
    required this.nextRank,
    required this.missingPoints,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _RankTitleBadge(rankStyle: rankStyle),
            Spacer(),
            _LevelBadge(
              rankStyle: rankStyle,
              points: points,
            ),
          ],
        ),

        SizedBox(height: 18),

        _GameAvatar(
          avatarUrl: avatarUrl,
          firstLetter: firstLetter,
          rankColor: rankStyle.primary,
          rankIcon: rankStyle.icon,
          size: 134,
          onAvatarTap: onAvatarTap,
        ),

        SizedBox(height: 18),

        Text(
          fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),

        SizedBox(height: 5),

        Text(
          phoneOrEmail,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 8),

        Text(
          rankStyle.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 18),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 9,
          runSpacing: 8,
          children: [
            _GameChip(
              icon: rankStyle.icon,
              text: rankStyle.title,
              rankColor: rankStyle.primary,
              filled: false,
              maxWidth: 165,
            ),
            _GameChip(
              icon: Icons.stars_rounded,
              text: '$points EXP',
              rankColor: rankStyle.primary,
              filled: true,
              maxWidth: 135,
            ),
            _GameChip(
              icon: Icons.bolt_rounded,
              text: rankStyle.benefitText,
              rankColor: rankStyle.primary,
              filled: false,
              maxWidth: 180,
            ),
          ],
        ),

        SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: rankStyle.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      points >= 2000
                          ? 'MAX LEVEL - Bạn đã đạt hạng cao nhất'
                          : 'Cần $missingPoints EXP để lên $nextRank',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              _ExpBar(
                progress: progress,
                rankColor: rankStyle.primary,
                label: RankHelper.getPointRangeText(points),
                compact: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankTitleBadge extends StatelessWidget {
  final RankStyle rankStyle;

  _RankTitleBadge({
    required this.rankStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            rankStyle.icon,
            color: rankStyle.primary,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            rankStyle.rankName.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final RankStyle rankStyle;
  final int points;

  _LevelBadge({
    required this.rankStyle,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final level = (points ~/ 100).clamp(1, 99);

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.22),
        border: Border.all(
          color: rankStyle.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: rankStyle.primary.withOpacity(0.30),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'LV',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          Text(
            level.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameAvatar extends StatelessWidget {
  final String avatarUrl;
  final String firstLetter;
  final Color rankColor;
  final IconData rankIcon;
  final double size;
  final VoidCallback? onAvatarTap;

  _GameAvatar({
    required this.avatarUrl,
    required this.firstLetter,
    required this.rankColor,
    required this.rankIcon,
    required this.size,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl.trim().isNotEmpty;
    final innerSize = size - 16;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size - 2,
            height: size - 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  rankColor,
                  Colors.white,
                  rankColor.withOpacity(0.65),
                  Colors.white,
                  rankColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: rankColor.withOpacity(0.42),
                  blurRadius: 22,
                  offset: Offset(0, 8),
                ),
              ],
            ),
          ),

          Container(
            width: innerSize,
            height: innerSize,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.22),
              border: Border.all(
                color: Colors.white.withOpacity(0.80),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: hasAvatar
                  ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) {
                  return _AvatarFallback(
                    letter: firstLetter,
                    color: rankColor,
                    fontSize: size >= 100 ? 40 : 24,
                  );
                },
              )
                  : _AvatarFallback(
                letter: firstLetter,
                color: rankColor,
                fontSize: size >= 100 ? 40 : 24,
              ),
            ),
          ),

          Positioned(
            bottom: 4,
            right: 4,
            child: InkWell(
              onTap: onAvatarTap,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: size >= 100 ? 42 : 28,
                height: size >= 100 ? 42 : 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: rankColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  onAvatarTap == null ? rankIcon : Icons.camera_alt_rounded,
                  color: rankColor,
                  size: size >= 100 ? 20 : 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String letter;
  final Color color;
  final double fontSize;

  _AvatarFallback({
    required this.letter,
    required this.color,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _GameChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color rankColor;
  final bool filled;
  final double maxWidth;

  _GameChip({
    required this.icon,
    required this.text,
    required this.rankColor,
    required this.filled,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.black.withOpacity(0.22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: filled ? Colors.transparent : Colors.white.withOpacity(0.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: filled ? rankColor : Colors.white,
              size: 14,
            ),
            SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: filled ? rankColor : Colors.white,
                  fontSize: 12,
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

class _ExpBar extends StatelessWidget {
  final double progress;
  final Color rankColor;
  final String label;
  final bool compact;

  _ExpBar({
    required this.progress,
    required this.rankColor,
    required this.label,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      compact ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.bolt_rounded,
              color: rankColor,
              size: compact ? 14 : 16,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Container(
          height: compact ? 8 : 10,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(rankColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _GamePattern extends StatelessWidget {
  final String rankName;
  final IconData icon;

  _GamePattern({
    required this.rankName,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PixelGridPainter(),
              ),
            ),
            Positioned(
              top: -46,
              right: -36,
              child: Container(
                width: 138,
                height: 138,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -58,
              left: -44,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 18,
              bottom: 18,
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.10),
                size: rankName == 'Diamond' ? 108 : 92,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiamondGameEffect extends StatelessWidget {
  _DiamondGameEffect();

  @override
  Widget build(BuildContext context) {
    return _SparkleLayer(
      items: [
        _SparkleItem(top: 18, left: 22, size: 22),
        _SparkleItem(top: 58, right: 32, size: 16),
        _SparkleItem(bottom: 36, right: 82, size: 18),
        _SparkleItem(bottom: 72, left: 34, size: 14),
      ],
    );
  }
}

class _GoldGameEffect extends StatelessWidget {
  _GoldGameEffect();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -30,
              left: -70,
              child: Transform.rotate(
                angle: -0.45,
                child: Container(
                  width: 88,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(90),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 24,
              top: 30,
              child: Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white.withOpacity(0.12),
                size: 88,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SilverGameEffect extends StatelessWidget {
  _SilverGameEffect();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              left: 18,
              right: 18,
              top: 16,
              child: Container(
                height: 1.2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: Container(
                height: 1.2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.32),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberGameEffect extends StatelessWidget {
  _MemberGameEffect();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _MemberGridPainter(),
        ),
      ),
    );
  }
}

class _SparkleLayer extends StatelessWidget {
  final List<_SparkleItem> items;

  _SparkleLayer({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: items,
        ),
      ),
    );
  }
}

class _SparkleItem extends StatelessWidget {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double size;

  _SparkleItem({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white.withOpacity(0.34),
        size: size,
      ),
    );
  }
}

class _PixelGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..style = PaintingStyle.fill;

    const step = 18.0;

    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, 2, 2),
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MemberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..strokeWidth = 1;

    const step = 22.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}