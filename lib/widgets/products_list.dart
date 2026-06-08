import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import 'product_card.dart';

class ProductsList extends ConsumerWidget {
  ProductsList({super.key});

  double getDoubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final selectedFilter = ref.watch(homeFilterProvider);

    final filteredProducts = products.where((product) {
      final type = product['type']?.toString() ?? '';
      final category = product['category']?.toString().toLowerCase() ?? '';
      final isPopular = product['isPopular'] == true;
      final price = getDoubleValue(product['price']);

      switch (selectedFilter) {
        case 'Gợi ý':
          return true;

        case 'Tất cả':
          return true;

        case 'Đồ uống':
          return type == 'drink';

        case 'Đồ ăn':
          return type == 'food';

        case 'Bán chạy':
          return isPopular;

        case 'Giá tốt':
          return price <= 45000;

        default:
          return category == selectedFilter.toLowerCase();
      }
    }).toList();

    if (filteredProducts.isEmpty) {
      return _EmptyProducts(
        selectedFilter: selectedFilter,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 20.0;
        const spacing = 14.0;

        final itemWidth =
            (constraints.maxWidth - horizontalPadding * 2 - spacing) / 2;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Wrap(
            spacing: spacing,
            runSpacing: 14,
            children: filteredProducts.map<Widget>((product) {
              return SizedBox(
                width: itemWidth,
                child: ProductCard(product: product),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  final String selectedFilter;

  _EmptyProducts({
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
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
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColors.blackOrangeGradient()
                    : AppColors.orangeGradient(),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(
                      isDark ? 0.20 : 0.18,
                    ),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.no_food_rounded,
                color: Colors.white,
                size: 46,
              ),
            ),

            SizedBox(height: 16),

            Text(
              'Chưa có món thuộc "$selectedFilter"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Bạn có thể chọn danh mục khác để xem thêm món.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                height: 1.4,
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
                color: AppColors.orangeChip(context),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.orange.withOpacity(0.22),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 17,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Thử danh mục khác',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
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
    );
  }
}