import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import 'category_card.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selectedFilter = ref.watch(homeFilterProvider);

    if (categories.isEmpty) {
      return const _CategoryLoadingList();
    }

    final items = [
      {
        'id': 0,
        'name': 'Tất cả',
        'type': 'all',
        'icon': 'all',
        'image_url': '',
      },
      ...categories.map((category) {
        return {
          'id': category['id'],
          'name': category['name']?.toString() ?? '',
          'type': category['type']?.toString() ?? '',
          'icon': category['icon']?.toString() ?? '',
          'image_url': category['image_url']?.toString() ?? '',
        };
      }),
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 11),
        itemBuilder: (context, index) {
          final item = items[index];

          final name = item['name']?.toString() ?? '';
          final type = item['type']?.toString() ?? '';
          final icon = item['icon']?.toString() ?? '';
          final imageUrl = item['image_url']?.toString() ?? '';

          final filter = name == 'Tất cả' ? 'Gợi ý' : name;
          final isSelected = selectedFilter == filter;

          return CategoryCard(
            title: name,
            type: type,
            iconName: icon,
            imageUrl: imageUrl,
            isSelected: isSelected,
            onTap: () {
              ref.read(homeFilterProvider.notifier).selectFilter(filter);
            },
          );
        },
      ),
    );
  }
}

class _CategoryLoadingList extends StatelessWidget {
  const _CategoryLoadingList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 11),
        itemBuilder: (context, index) {
          return const _CategoryLoadingCard();
        },
      ),
    );
  }
}

class _CategoryLoadingCard extends StatelessWidget {
  const _CategoryLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 108,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        gradient: AppColors.isDark(context)
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blackCard,
            AppColors.blackSoft,
          ],
        )
            : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white,
            Color(0xFFFFFAF5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SkeletonBox(
            width: 48,
            height: 48,
            radius: 18,
          ),
          SizedBox(height: 7),
          _SkeletonBox(
            width: 52,
            height: 8,
            radius: 20,
          ),
          SizedBox(height: 5),
          _SkeletonBox(
            width: 34,
            height: 8,
            radius: 20,
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);

    animation = Tween<double>(
      begin: 0.35,
      end: 0.88,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  LinearGradient skeletonGradient(BuildContext context) {
    if (AppColors.isDark(context)) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.14),
        ],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFE7D1),
        Color(0xFFFFD2A1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: skeletonGradient(context),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}