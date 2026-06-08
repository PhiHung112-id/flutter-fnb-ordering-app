import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

class CartBadgeIcon extends ConsumerWidget {
  final bool active;

  CartBadgeIcon({
    super.key,
    required this.active,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsProvider);
    final count = cartItems.fold<int>(0, (sum, item) => sum + item.qty);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          active ? Icons.shopping_cart : Icons.shopping_cart_outlined,
        ),
        if (count > 0)
          Positioned(
            top: -8,
            right: -10,
            child: badges.Badge(
              badgeContent: Text(
                count.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Color(0xFFFF7A00),
                padding: EdgeInsets.all(6),
              ),
            ),
          ),
      ],
    );
  }
}