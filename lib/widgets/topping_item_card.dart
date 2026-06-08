import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/format_money.dart';

class ToppingItemCard extends StatelessWidget {
  final Map<String, dynamic> topping;
  final bool isSelected;
  final VoidCallback onTap;

  const ToppingItemCard({
    super.key,
    required this.topping,
    required this.isSelected,
    required this.onTap,
  });

  double getPrice() {
    final value = topping['price'];

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  String getName() {
    return topping['name']?.toString() ?? 'Topping';
  }

  String getImageUrl() {
    return topping['image']?.toString() ??
        topping['image_url']?.toString() ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final name = getName();
    final price = getPrice();
    final imageUrl = getImageUrl();

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 118,
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? primary : AppColors.border(context),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ToppingImage(
                  imageUrl: imageUrl,
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(9, 7, 9, 0),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(9, 4, 9, 8),
                  child: Text(
                    '+${formatMoney(price)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              top: 7,
              right: 7,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isSelected ? primary : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? primary : AppColors.border(context),
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check_rounded : Icons.add_rounded,
                  size: 17,
                  color: isSelected ? Colors.white : primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToppingImage extends StatelessWidget {
  final String imageUrl;

  const _ToppingImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(17),
      ),
      child: SizedBox(
        height: 72,
        width: double.infinity,
        child: imageUrl.trim().isEmpty
            ? const _ToppingFallbackImage()
            : CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) {
            return const _ToppingFallbackImage();
          },
          errorWidget: (_, __, ___) {
            return const _ToppingFallbackImage();
          },
        ),
      ),
    );
  }
}

class _ToppingFallbackImage extends StatelessWidget {
  const _ToppingFallbackImage();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      color: primary.withOpacity(0.10),
      child: Icon(
        Icons.bubble_chart_rounded,
        color: primary,
        size: 30,
      ),
    );
  }
}