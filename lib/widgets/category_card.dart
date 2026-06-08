import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String type;
  final String iconName;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.type,
    required this.iconName,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  String getEmoji() {
    final name = title.toLowerCase().trim();
    final icon = iconName.toLowerCase().trim();
    final categoryType = type.toLowerCase().trim();

    if (name.contains('tất') || icon == 'all' || categoryType == 'all') {
      return '🍽️';
    }

    if (name.contains('cà phê') ||
        name.contains('coffee') ||
        icon.contains('coffee') ||
        icon.contains('cafe')) {
      return '☕';
    }

    if (name.contains('trà') ||
        name.contains('tea') ||
        name.contains('milk') ||
        icon.contains('tea') ||
        icon.contains('milk')) {
      return '🧋';
    }

    if (name.contains('nước') ||
        name.contains('drink') ||
        name.contains('juice') ||
        categoryType == 'drink') {
      return '🥤';
    }

    if (name.contains('burger') ||
        name.contains('sandwich') ||
        icon.contains('burger') ||
        icon.contains('sandwich')) {
      return '🍔';
    }

    if (name.contains('pizza') || icon.contains('pizza')) {
      return '🍕';
    }

    if (name.contains('bánh') ||
        name.contains('cake') ||
        name.contains('dessert') ||
        icon.contains('cake')) {
      return '🍰';
    }

    if (name.contains('combo') || categoryType == 'combo') {
      return '🍱';
    }

    if (name.contains('gà') || name.contains('chicken')) {
      return '🍗';
    }

    if (categoryType == 'food') {
      return '🍜';
    }

    return '🍽️';
  }

  LinearGradient selectedGradient(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.lighten(primary, 0.16),
        primary,
        AppColors.darken(primary, 0.14),
      ],
    );
  }

  LinearGradient normalGradient(BuildContext context) {
    if (AppColors.isDark(context)) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.blackCard,
          AppColors.blackSoft,
        ],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Color(0xFFFFFAF5),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final emoji = getEmoji();

    return SizedBox(
      width: 82,
      height: 104,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          scale: isSelected ? 1.04 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 230),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(7, 7, 7, 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? selectedGradient(context)
                  : normalGradient(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withOpacity(0.34)
                    : AppColors.border(context),
                width: isSelected ? 1.3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? primary.withOpacity(
                    AppColors.isDark(context) ? 0.30 : 0.22,
                  )
                      : AppColors.shadow(context),
                  blurRadius: isSelected ? 16 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (isSelected)
                  Positioned(
                    top: -18,
                    right: -18,
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                if (isSelected)
                  Positioned(
                    bottom: -24,
                    left: -18,
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CategoryImageBox(
                      imageUrl: imageUrl,
                      emoji: emoji,
                      isSelected: isSelected,
                      primary: primary,
                    ),

                    const SizedBox(height: 4),

                    SizedBox(
                      height: 30,
                      child: Center(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary(context),
                            fontSize: 11.4,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (isSelected)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.14),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: primary,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryImageBox extends StatelessWidget {
  final String imageUrl;
  final String emoji;
  final bool isSelected;
  final Color primary;

  const _CategoryImageBox({
    required this.imageUrl,
    required this.emoji,
    required this.isSelected,
    required this.primary,
  });

  bool get hasImage => imageUrl.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 3,
            child: Container(
              width: 34,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.black.withOpacity(0.15)
                    : Colors.black.withOpacity(0.08),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.white.withOpacity(0.18)
                  : primary.withOpacity(
                AppColors.isDark(context) ? 0.14 : 0.08,
              ),
            ),
          ),

          Positioned(
            top: 0,
            child: hasImage
                ? _Category3DImage(
              imageUrl: imageUrl,
              emoji: emoji,
              primary: primary,
            )
                : _EmojiFallback(
              emoji: emoji,
            ),
          ),
        ],
      ),
    );
  }
}

class _Category3DImage extends StatelessWidget {
  final String imageUrl;
  final String emoji;
  final Color primary;

  const _Category3DImage({
    required this.imageUrl,
    required this.emoji,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return _EmojiFallback(emoji: emoji);
        },
      );
    }

    return Image.network(
      imageUrl,
      width: 48,
      height: 48,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            color: primary,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (_, __, ___) {
        return _EmojiFallback(emoji: emoji);
      },
    );
  }
}

class _EmojiFallback extends StatelessWidget {
  final String emoji;

  const _EmojiFallback({
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: const TextStyle(
        fontSize: 34,
        height: 1,
      ),
    );
  }
}