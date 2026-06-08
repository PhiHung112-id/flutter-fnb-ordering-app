import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../services/review_service.dart';
import '../utils/app_colors.dart';
import '../utils/format_money.dart';
import '../widgets/product_card.dart';
import '../widgets/topping_item_card.dart';
import 'login_page.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  final PageController imageController = PageController();
  int selectedImageIndex = 0;

  final List<Map<String, dynamic>> selectedToppings = [];
  late Future<List<Map<String, dynamic>>> reviewsFuture;
  double? currentRating;

  @override
  void initState() {
    super.initState();

    currentRating = getDoubleValue(widget.product['rating']);
    reviewsFuture = loadReviews();
  }

  @override
  void dispose() {
    imageController.dispose();
    super.dispose();
  }

  static int getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static double getDoubleValue(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  String getTitle() {
    return widget.product['title']?.toString() ??
        widget.product['name']?.toString() ??
        'Sản phẩm';
  }

  String getCategory() {
    return widget.product['category']?.toString() ??
        widget.product['type']?.toString() ??
        'Danh mục';
  }

  String getDescription() {
    return widget.product['description']?.toString() ?? '';
  }

  int getSoldCount() {
    final value = widget.product['sold_count'] ??
        widget.product['soldCount'] ??
        widget.product['sold'] ??
        widget.product['total_sold'] ??
        0;

    return getIntValue(value);
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

  List<String> getImages() {
    final images = widget.product['images'];

    if (images is List && images.isNotEmpty) {
      final result = images
          .map((e) => e.toString())
          .where((url) => url.trim().isNotEmpty)
          .toList();

      if (result.isNotEmpty) return result;
    }

    final thumbnail = widget.product['thumbnail']?.toString() ?? '';

    return [thumbnail];
  }

  List<Map<String, dynamic>> getToppings() {
    final toppings = widget.product['toppings'];

    if (toppings is List) {
      return toppings.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }

  double getToppingPrice() {
    double total = 0;

    for (final topping in selectedToppings) {
      total += getDoubleValue(topping['price']);
    }

    return total;
  }

  double getAverageRatingFromReviews(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) {
      return getDoubleValue(widget.product['rating']);
    }

    double total = 0;

    for (final review in reviews) {
      total += getDoubleValue(review['rating']);
    }

    final average = total / reviews.length;

    return double.parse(average.toStringAsFixed(1));
  }

  Future<List<Map<String, dynamic>>> loadReviews() async {
    final reviews = await ReviewService().getReviewsByProductId(
      getIntValue(widget.product['id']),
    );

    if (reviews.isNotEmpty) {
      final average = getAverageRatingFromReviews(reviews);

      if (mounted) {
        setState(() {
          currentRating = average;
        });
      } else {
        currentRating = average;
      }
    }

    return reviews;
  }

  double getFinalPrice() {
    return getDoubleValue(widget.product['price']) + getToppingPrice();
  }

  bool isToppingSelected(Map<String, dynamic> topping) {
    return selectedToppings.any((item) => item['name'] == topping['name']);
  }

  void toggleTopping(Map<String, dynamic> topping) {
    setState(() {
      if (isToppingSelected(topping)) {
        selectedToppings.removeWhere(
              (item) => item['name'] == topping['name'],
        );
      } else {
        selectedToppings.add(topping);
      }
    });
  }

  List<Map<String, dynamic>> getRecommendedProducts(
      List<Map<String, dynamic>> products,
      ) {
    final type = widget.product['type'];

    final ids = type == 'drink'
        ? widget.product['recommendedFoodIds']
        : widget.product['recommendedDrinkIds'];

    if (ids is! List || ids.isEmpty) {
      return products.where((item) {
        if (item['id'] == widget.product['id']) return false;

        if (type == 'drink') {
          return item['type'] == 'food' || item['type'] == 'combo';
        }

        return item['type'] == 'drink';
      }).take(4).toList();
    }

    return products.where((item) {
      return ids.contains(item['id']);
    }).toList();
  }

  void addToCart() {
    final isLoggedIn = ref.read(loggedInProvider);

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thêm món vào giỏ hàng'),
        ),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginPage(),
        ),
      );

      return;
    }

    final toppingNames = selectedToppings.map((item) {
      return item['name'].toString();
    }).toList();

    ref.read(cartItemsProvider.notifier).addToCart(
      widget.product['id'],
      toppings: toppingNames,
      toppingPrice: getToppingPrice(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${getTitle()} vào giỏ hàng'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> toggleFavorite() async {
    final isLoggedIn = ref.read(loggedInProvider);

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để lưu món yêu thích'),
        ),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginPage(),
        ),
      );

      return;
    }

    final productId = getIntValue(widget.product['id']);
    final isFavorite = ref.read(favoritesProvider).contains(productId);

    try {
      await ref.read(favoritesProvider.notifier).toggleFavorite(productId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? 'Đã bỏ khỏi món yêu thích'
                : 'Đã thêm vào món yêu thích',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không lưu được yêu thích: $e'),
        ),
      );
    }
  }

  void showAllReviews() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: reviewsFuture,
              builder: (context, snapshot) {
                final reviews = snapshot.data ?? [];

                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Tất cả đánh giá',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(bottomSheetContext);
                            },
                            icon: Icon(
                              Icons.close,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: _RatingSummaryBox(
                        rating: getAverageRatingFromReviews(reviews),
                        reviewCount: reviews.length,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                          : reviews.isEmpty
                          ? const _EmptyReviewBox()
                          : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          8,
                          18,
                          24,
                        ),
                        itemCount: reviews.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _ReviewCard(
                            review: reviews[index],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = getImages();
    final toppings = getToppings();
    final products = ref.watch(productsProvider);
    final favorites = ref.watch(favoritesProvider);

    final productId = getIntValue(widget.product['id']);
    final isFavorite = favorites.contains(productId);

    final recommendedProducts = getRecommendedProducts(products);
    final isDrink = widget.product['type'] == 'drink';

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        slivers: [
          _ProductImageAppBar(
            images: images,
            productId: productId,
            imageController: imageController,
            selectedImageIndex: selectedImageIndex,
            isFavorite: isFavorite,
            rating: currentRating ?? getDoubleValue(widget.product['rating']),
            soldText: getSoldText(),
            onBack: () => Navigator.pop(context),
            onFavoriteTap: toggleFavorite,
            onImageChanged: (index) {
              setState(() {
                selectedImageIndex = index;
              });
            },
            onThumbnailTap: (index) {
              imageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -4),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProductInfoCard(
                      title: getTitle(),
                      category: getCategory(),
                      description: getDescription(),
                      rating: currentRating ?? getDoubleValue(widget.product['rating']),
                      soldText: getSoldText(),
                      price: getDoubleValue(widget.product['price']),
                    ),
                    const SizedBox(height: 18),
                    _SectionHeader(
                      title: 'Đánh giá khách hàng',
                      actionText: 'Xem tất cả',
                      onTap: showAllReviews,
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: reviewsFuture,
                      builder: (context, snapshot) {
                        final reviews = snapshot.data ?? [];

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        }

                        if (reviews.isEmpty) {
                          return const _EmptyReviewBox();
                        }

                        return Column(
                          children: [
                            _RatingSummaryBox(
                              rating: getAverageRatingFromReviews(reviews),
                              reviewCount: reviews.length,
                            ),
                            const SizedBox(height: 12),
                            _ReviewCard(review: reviews.first),
                          ],
                        );
                      },
                    ),
                    if (isDrink && toppings.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Chọn topping',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (selectedToppings.isNotEmpty)
                            _SelectedToppingBadge(
                              text: '+${formatMoney(getToppingPrice())}',
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 158,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: toppings.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final topping = toppings[index];
                            final isSelected = isToppingSelected(topping);

                            return ToppingItemCard(
                              topping: topping,
                              isSelected: isSelected,
                              onTap: () => toggleTopping(topping),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Text(
                      isDrink ? 'Gợi ý ăn kèm' : 'Gợi ý nước uống',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 310,
                      child: recommendedProducts.isEmpty
                          ? Center(
                        child: Text(
                          'Chưa có gợi ý phù hợp',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                          : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommendedProducts.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 170,
                            child: ProductCard(
                              product: recommendedProducts[index],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 170),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomAddToCartBar(
        totalPrice: getFinalPrice(),
        toppingCount: selectedToppings.length,
        onAddToCart: addToCart,
      ),
    );
  }
}

class _ProductImageAppBar extends StatelessWidget {
  final List<String> images;
  final int productId;
  final PageController imageController;
  final int selectedImageIndex;
  final bool isFavorite;
  final double rating;
  final String soldText;
  final VoidCallback onBack;
  final VoidCallback onFavoriteTap;
  final ValueChanged<int> onImageChanged;
  final ValueChanged<int> onThumbnailTap;

  const _ProductImageAppBar({
    required this.images,
    required this.productId,
    required this.imageController,
    required this.selectedImageIndex,
    required this.isFavorite,
    required this.rating,
    required this.soldText,
    required this.onBack,
    required this.onFavoriteTap,
    required this.onImageChanged,
    required this.onThumbnailTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: images.length > 1 ? 350 : 300,
      pinned: false,
      floating: false,
      snap: false,
      toolbarHeight: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: imageController,
              itemCount: images.length,
              onPageChanged: onImageChanged,
              itemBuilder: (context, index) {
                final imageUrl = images[index];

                return Hero(
                  tag: productId,
                  child: imageUrl.trim().isEmpty
                      ? _ProductImageFallback()
                      : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.cardSoft(context),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) {
                      return _ProductImageFallback();
                    },
                  ),
                );
              },
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.42),
                        Colors.transparent,
                        Colors.black.withOpacity(0.34),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: images.length > 1 ? 76 : 24,
              child: Row(
                children: [
                  _ImageBadge(
                    icon: Icons.star_rounded,
                    text: rating.toStringAsFixed(1),
                  ),
                  const SizedBox(width: 8),
                  _ImageBadge(
                    icon: Icons.local_fire_department_rounded,
                    text: soldText,
                  ),
                ],
              ),
            ),

            if (images.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: SizedBox(
                  height: 54,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 9),
                    itemBuilder: (context, index) {
                      final isSelected = selectedImageIndex == index;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => onThumbnailTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 54,
                          height: 54,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.28),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white.withOpacity(0.22),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: CachedNetworkImage(
                              imageUrl: images[index],
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) {
                                return Container(
                                  color: AppColors.cardSoft(context),
                                  child: Icon(
                                    Icons.image_rounded,
                                    color: AppColors.textSecondary(context),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Row(
                  children: [
                    _GlassCircleButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: onBack,
                    ),
                    const Spacer(),
                    _GlassCircleButton(
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: isFavorite ? Colors.redAccent : Colors.white,
                      onTap: onFavoriteTap,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductInfoCard extends StatelessWidget {
  final String title;
  final String category;
  final String description;
  final double rating;
  final String soldText;
  final double price;

  const _ProductInfoCard({
    required this.title,
    required this.category,
    required this.description,
    required this.rating,
    required this.soldText,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.border(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.restaurant_menu_rounded,
                text: category,
              ),
              _InfoChip(
                icon: Icons.star_rounded,
                text: rating.toStringAsFixed(1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 27,
              height: 1.08,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: primary,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                soldText,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            formatMoney(price),
            style: TextStyle(
              color: primary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (description.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              description,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                height: 1.5,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomAddToCartBar extends StatelessWidget {
  final double totalPrice;
  final int toppingCount;
  final VoidCallback onAddToCart;

  const _BottomAddToCartBar({
    required this.totalPrice,
    required this.toppingCount,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        border: Border(
          top: BorderSide(
            color: AppColors.border(context),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.isDark(context)
                ? Colors.black.withOpacity(0.55)
                : Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng tiền',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatMoney(totalPrice),
                    style: TextStyle(
                      color: primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (toppingCount > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Đã chọn $toppingCount topping',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.24),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onAddToCart,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Thêm vào giỏ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
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

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _GlassCircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.40),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 23,
          ),
        ),
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ImageBadge({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.38),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: primary.withOpacity(
          AppColors.isDark(context) ? 0.18 : 0.10,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: primary,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (actionText != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              actionText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class _SelectedToppingBadge extends StatelessWidget {
  final String text;

  const _SelectedToppingBadge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: primary.withOpacity(
          AppColors.isDark(context) ? 0.18 : 0.10,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primary.withOpacity(0.20),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyReviewBox extends StatelessWidget {
  const _EmptyReviewBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.12),
            child: Icon(
              Icons.rate_review_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chưa có đánh giá cho món này',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSummaryBox extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const _RatingSummaryBox({
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StarsRow(rating: rating),
                const SizedBox(height: 5),
                Text(
                  '$reviewCount đánh giá từ khách hàng',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified_rounded,
            color: primary,
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const _ReviewCard({
    required this.review,
  });

  String formatReviewDate(String rawDate) {
    if (rawDate.isEmpty) return '';

    try {
      final date = DateTime.parse(rawDate).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return '$day/$month/$year';
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = review['customerName']?.toString() ??
        review['customer_name']?.toString() ??
        'Khách hàng';

    final avatarUrl = review['customerAvatar']?.toString() ??
        review['customer_avatar']?.toString() ??
        '';

    final rating = (review['rating'] as num?)?.toDouble() ?? 0;
    final date = formatReviewDate(review['createdAt']?.toString() ?? '');
    final content = review['content']?.toString() ?? '';

    final firstLetter = name.trim().isEmpty
        ? 'K'
        : name.trim().substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.14),
            backgroundImage: avatarUrl.trim().isNotEmpty
                ? NetworkImage(avatarUrl.trim())
                : null,
            child: avatarUrl.trim().isEmpty
                ? Text(
              firstLetter,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            )
                : null,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _StarsRow(rating: rating, size: 15),
                if (content.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      height: 1.4,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  final double rating;
  final double size;

  const _StarsRow({
    required this.rating,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final starNumber = index + 1;

        IconData icon;

        if (rating >= starNumber) {
          icon = Icons.star_rounded;
        } else if (rating >= starNumber - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }

        return Icon(
          icon,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
      ),
      child: const Center(
        child: Icon(
          Icons.fastfood_rounded,
          color: Colors.white,
          size: 72,
        ),
      ),
    );
  }
}