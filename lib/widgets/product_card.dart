import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/product_detail_page.dart';
import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../utils/format_money.dart';

class ProductCard extends ConsumerWidget {
  final Map<String, dynamic> product;

  const ProductCard({
    super.key,
    required this.product,
  });

  int getProductId() {
    final value = product['id'];

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  String getTitle() {
    final value = product['title'] ??
        product['name'] ??
        product['product_name'] ??
        'Sản phẩm';

    return value.toString();
  }

  String getImageUrl() {
    final value = product['thumbnail'] ??
        product['image_url'] ??
        product['imageUrl'] ??
        product['image'] ??
        '';

    return value.toString();
  }

  double getPrice() {
    final value = product['price'];

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  double getRating() {
    final value = product['rating'] ?? product['rate'];

    if (value == null) return 0;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  int getReviewCount() {
    final value = product['review_count'] ??
        product['rating_count'] ??
        product['reviews_count'] ??
        0;

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  int getSoldCount() {
    final value = product['sold_count'] ??
        product['soldCount'] ??
        product['sold'] ??
        product['total_sold'] ??
        0;

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  int getDiscountPercent() {
    final value = product['discount_percent'] ??
        product['discountPercent'] ??
        product['discount'] ??
        0;

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  bool isNewProduct() {
    final value = product['is_new'] ?? product['isNew'] ?? false;

    if (value is bool) return value;

    return value.toString() == 'true' || value.toString() == '1';
  }

  bool isBestSeller() {
    final value = product['is_best_seller'] ??
        product['isBestSeller'] ??
        product['best_seller'] ??
        false;

    if (value is bool) return value;

    return value.toString() == 'true' || value.toString() == '1';
  }

  String? getBadgeText() {
    final discount = getDiscountPercent();
    final sold = getSoldCount();

    if (discount > 0) return 'Giảm $discount%';
    if (isBestSeller() || sold >= 100) return 'Bán chạy';
    if (isNewProduct()) return 'New';

    return null;
  }

  Color getBadgeColor(BuildContext context) {
    final badge = getBadgeText();
    final primary = Theme.of(context).colorScheme.primary;

    if (badge == null) return primary;
    if (badge.startsWith('Giảm')) return Colors.red;
    if (badge == 'Bán chạy') return primary;
    if (badge == 'New') return Colors.green;

    return primary;
  }

  String getSoldText() {
    final sold = getSoldCount();

    if (sold <= 0) return 'Mới mở bán';

    if (sold >= 1000) {
      final value = sold / 1000;

      if (sold % 1000 == 0) {
        return 'Đã bán ${value.toInt()}k';
      }

      return 'Đã bán ${value.toStringAsFixed(1)}k';
    }

    return 'Đã bán $sold';
  }

  void openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(
          product: product,
        ),
      ),
    );
  }

  void addToCart(BuildContext context, WidgetRef ref) {
    final id = getProductId();

    if (id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy sản phẩm'),
        ),
      );
      return;
    }

    ref.read(cartItemsProvider.notifier).addToCart(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${getTitle()} vào giỏ hàng'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void toggleFavorite(WidgetRef ref) {
    final id = getProductId();

    if (id <= 0) return;

    ref.read(favoritesProvider.notifier).toggleFavorite(id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;

    final id = getProductId();
    final title = getTitle();
    final imageUrl = getImageUrl();
    final price = getPrice();
    final rating = getRating();
    final reviewCount = getReviewCount();
    final badgeText = getBadgeText();
    final badgeColor = getBadgeColor(context);

    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(id);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border(context),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 13,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImageSection(
              imageUrl: imageUrl,
              badgeText: badgeText,
              badgeColor: badgeColor,
              isFavorite: isFavorite,
              onFavoriteTap: () => toggleFavorite(ref),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 14.5,
                      height: 1.22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: primary,
                        size: 15,
                      ),
                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          getSoldText(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      if (rating > 0 && reviewCount > 0) ...[
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.star_border_rounded,
                          color: AppColors.textSecondary(context)
                              .withOpacity(0.55),
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Chưa có',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _PriceText(
                          price: price,
                          color: primary,
                        ),
                      ),

                      _AddButton(
                        onTap: () => addToCart(context, ref),
                      ),
                    ],
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

class _ProductImageSection extends StatelessWidget {
  final String imageUrl;
  final String? badgeText;
  final Color badgeColor;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const _ProductImageSection({
    required this.imageUrl,
    required this.badgeText,
    required this.badgeColor,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          child: AspectRatio(
            aspectRatio: 1.16,
            child: imageUrl.isEmpty
                ? const _ImageFallback()
                : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) {
                return Container(
                  color: AppColors.cardSoft(context),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorWidget: (_, __, ___) {
                return const _ImageFallback();
              },
            ),
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.transparent,
                    Colors.black.withOpacity(0.18),
                  ],
                ),
              ),
            ),
          ),
        ),

        if (badgeText != null)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withOpacity(0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                badgeText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

        Positioned(
          top: 9,
          right: 9,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onFavoriteTap,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.28),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.20),
                ),
              ),
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite ? Colors.redAccent : Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
      ),
      child: const Icon(
        Icons.fastfood_rounded,
        color: Colors.white,
        size: 46,
      ),
    );
  }
}

class _PriceText extends StatelessWidget {
  final double price;
  final Color color;

  const _PriceText({
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      formatMoney(price),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: 16.5,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.24),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 27,
        ),
      ),
    );
  }
}