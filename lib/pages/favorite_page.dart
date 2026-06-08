import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../widgets/product_card.dart';

class FavoritePage extends ConsumerWidget {
  FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final favorites = ref.watch(favoritesProvider);

    final favoriteProducts = products.where((product) {
      return favorites.contains(product['id']);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Món yêu thích',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: favoriteProducts.isEmpty
          ? _EmptyFavorite()
          : LayoutBuilder(
        builder: (context, constraints) {
          const horizontalPadding = 18.0;
          const spacing = 14.0;

          final itemWidth =
              (constraints.maxWidth - horizontalPadding * 2 - spacing) /
                  2;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FavoriteHeader(
                  count: favoriteProducts.length,
                ),

                SizedBox(height: 16),

                Wrap(
                  spacing: spacing,
                  runSpacing: 14,
                  children: favoriteProducts.map<Widget>((product) {
                    return SizedBox(
                      width: itemWidth,
                      child: ProductCard(product: product),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteHeader extends StatelessWidget {
  final int count;

  _FavoriteHeader({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = AppColors.isDark(context);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(isDark ? 0.25 : 0.18),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(
                      isDark ? 0.24 : 0.22,
                    ),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),

            SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count món đã lưu',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Các món bạn yêu thích được lưu tại đây',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary.withOpacity(isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: primary.withOpacity(0.22),
                ),
              ),
              child: Icon(
                Icons.bookmark_rounded,
                color: primary,
                size: 19,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorite extends StatelessWidget {
  _EmptyFavorite();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = AppColors.isDark(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.border(context),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 108,
                height: 108,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(
                        isDark ? 0.24 : 0.20,
                      ),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient(context),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Icon(
                    Icons.favorite_border_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),

              SizedBox(height: 20),

              Text(
                'Chưa có món yêu thích',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Hãy nhấn vào biểu tượng trái tim ở món bạn thích để lưu lại và đặt nhanh hơn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  height: 1.45,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: primary.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: primary,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Bấm tim để lưu món',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
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