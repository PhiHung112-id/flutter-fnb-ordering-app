import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../models/cart_item_model.dart';
import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../utils/format_money.dart';
import 'checkout_page.dart';
import 'location_page.dart';
import 'login_page.dart';

class CartPage extends ConsumerWidget {
  CartPage({super.key});

  Map<String, dynamic>? findProductById(
      List<Map<String, dynamic>> products,
      int productId,
      ) {
    for (final product in products) {
      if (product['id'] == productId) {
        return product;
      }
    }

    return null;
  }

  double calculateTotal(
      List<Map<String, dynamic>> products,
      List<CartItem> cartItems,
      ) {
    double total = 0;

    for (final cartItem in cartItems) {
      final product = findProductById(products, cartItem.id);

      if (product == null) continue;

      final price = (product['price'] as num?)?.toDouble() ?? 0;
      total += (price + cartItem.toppingPrice) * cartItem.qty;
    }

    return total;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final cartItems = ref.watch(cartItemsProvider);
    final deliveryLocation = ref.watch(deliveryLocationProvider);
    final total = calculateTotal(products, cartItems);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Giỏ hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: cartItems.isEmpty
          ? _EmptyCart()
          : Column(
        children: [
          _DeliveryAddressBox(
            deliveryLocation: deliveryLocation,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LocationPage(),
                ),
              );
            },
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = cartItems[index];

                final product = findProductById(
                  products,
                  cartItem.id,
                );

                if (product == null) {
                  return SizedBox.shrink();
                }

                final price =
                    (product['price'] as num?)?.toDouble() ?? 0;

                final double itemPrice = price + cartItem.toppingPrice;

                return _CartItemCard(
                  product: product,
                  cartItem: cartItem,
                  itemPrice: itemPrice,
                  onDecrease: () {
                    ref
                        .read(cartItemsProvider.notifier)
                        .decreaseQty(cartItem);
                  },
                  onIncrease: () {
                    ref
                        .read(cartItemsProvider.notifier)
                        .increaseQty(cartItem);
                  },
                );
              },
            ),
          ),

          _CartBottomBar(
            total: total,
            onCheckout: () {
              final isLoggedIn = ref.read(loggedInProvider);

              if (!isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vui lòng đăng nhập để thanh toán'),
                  ),
                );

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LoginPage(),
                  ),
                );

                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CheckoutPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DeliveryAddressBox extends StatelessWidget {
  final String deliveryLocation;
  final VoidCallback onTap;

  _DeliveryAddressBox({
    required this.deliveryLocation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final address = deliveryLocation.trim().isEmpty
        ? 'Chưa chọn địa chỉ giao hàng'
        : deliveryLocation;

    final isDark = AppColors.isDark(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.blackCard,
                AppColors.blackSoft,
                primary.withOpacity(0.16),
              ],
            )
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.card(context),
                AppColors.cardSoft(context),
                primary.withOpacity(0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: primary.withOpacity(isDark ? 0.26 : 0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(isDark ? 0.18 : 0.12),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.20),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                ),
              ),

              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giao đến',
                      style: TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primary.withOpacity(0.24),
                  ),
                ),
                child: Text(
                  'Đổi',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final CartItem cartItem;
  final double itemPrice;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  _CartItemCard({
    required this.product,
    required this.cartItem,
    required this.itemPrice,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final title = product['title']?.toString() ?? '';
    final thumbnail = product['thumbnail']?.toString() ?? '';
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 78,
              height: 78,
              child: CachedNetworkImage(
                imageUrl: thumbnail,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: AppColors.isDark(context)
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  highlightColor: AppColors.isDark(context)
                      ? Colors.grey.shade700
                      : Colors.grey.shade100,
                  child: Container(
                    color: AppColors.card(context),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient(context),
                  ),
                  child: Icon(
                    Icons.fastfood,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    height: 1.25,
                  ),
                ),

                if (cartItem.toppings.isNotEmpty) ...[
                  SizedBox(height: 6),
                  Column(
                    children: cartItem.toppings.map<Widget>((topping) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                topping,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'x1',
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

                SizedBox(height: 8),

                Text(
                  formatMoney(itemPrice),
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 46),
              _QuantityControl(
                qty: cartItem.qty,
                onDecrease: onDecrease,
                onIncrease: onIncrease,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  _QuantityControl({
    required this.qty,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardSoft(context),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: primary.withOpacity(0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove,
            onTap: onDecrease,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              qty.toString(),
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;

  _CartBottomBar({
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                ? Colors.black.withOpacity(0.50)
                : primary.withOpacity(0.10),
            blurRadius: 12,
            offset: Offset(0, -4),
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
                    'Tổng thanh toán',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    formatMoney(total),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12),

            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.22),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Thanh toán',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
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

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  _QtyButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRemove = icon == Icons.remove;
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          gradient: isRemove ? null : AppColors.primaryGradient(context),
          color: isRemove ? AppColors.card(context) : null,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: primary,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isRemove ? primary : Colors.white,
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 106,
              height: 106,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(
                      AppColors.isDark(context) ? 0.24 : 0.20,
                    ),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 58,
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Giỏ hàng đang trống',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Hãy chọn món ăn hoặc đồ uống yêu thích để bắt đầu đặt hàng.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}