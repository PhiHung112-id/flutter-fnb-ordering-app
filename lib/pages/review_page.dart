import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_model.dart';
import '../models/review_model.dart';
import '../providers/app_state.dart';
import '../services/review_service.dart';
import '../utils/app_colors.dart';

class ReviewPage extends ConsumerStatefulWidget {
  final OrderModel order;

  ReviewPage({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  int rating = 5;
  bool isSubmitting = false;
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  int? getFirstProductId() {
    if (widget.order.items.isEmpty) {
      return null;
    }

    final productId = widget.order.items.first['productId'];

    if (productId is int) {
      return productId;
    }

    if (productId is num) {
      return productId.toInt();
    }

    return null;
  }

  Future<void> submitReview() async {
    if (isSubmitting) return;

    final comment = commentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập nhận xét của bạn'),
        ),
      );
      return;
    }

    final productId = getFirstProductId();

    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tìm thấy sản phẩm để đánh giá'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final profile = ref.read(customerProfileProvider);

      final customerName =
      profile?['full_name']?.toString().trim().isNotEmpty == true
          ? profile!['full_name'].toString().trim()
          : 'Khách hàng';

      final customerAvatar =
      profile?['avatar_url']?.toString().trim().isNotEmpty == true
          ? profile!['avatar_url'].toString().trim()
          : '';

      final reviewService = ReviewService();

      await reviewService.addReview(
        productId: productId,
        orderId: widget.order.id,
        customerName: customerName,
        customerAvatar: customerAvatar,
        rating: rating.toDouble(),
        content: comment,
      );

      await reviewService.updateProductRating(productId);
      await ref.read(productsProvider.notifier).refreshFromSupabase();

      final review = ReviewModel(
        id: DateTime.now().millisecondsSinceEpoch,
        orderId: widget.order.id,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      ref.read(reviewsProvider.notifier).addReview(review);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cảm ơn bạn đã đánh giá!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi gửi đánh giá: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  String getRatingText() {
    switch (rating) {
      case 1:
        return 'Rất không hài lòng';
      case 2:
        return 'Chưa hài lòng';
      case 3:
        return 'Tạm ổn';
      case 4:
        return 'Hài lòng';
      default:
        return 'Rất hài lòng';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Đánh giá đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(27),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(isDark ? 0.28 : 0.22),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(context),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.22),
                      ),
                    ),
                    child: Icon(
                      Icons.rate_review,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn #${widget.order.id.toString().padLeft(6, '0')}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Chia sẻ trải nghiệm để cửa hàng phục vụ tốt hơn',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(26),
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
              children: [
                Text(
                  'Bạn hài lòng với đơn hàng này không?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  getRatingText(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    final isSelected = starValue <= rating;

                    return IconButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                        setState(() {
                          rating = starValue;
                        });
                      },
                      icon: Icon(
                        isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isSelected
                            ? Colors.amber.shade700
                            : AppColors.textSecondary(context).withOpacity(0.55),
                        size: 40,
                      ),
                    );
                  }),
                ),

                SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(isDark ? 0.20 : 0.12),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: primary.withOpacity(0.24),
                    ),
                  ),
                  child: Text(
                    '$rating/5 sao',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          Text(
            'Nhận xét của bạn',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          SizedBox(height: 10),

          TextField(
            controller: commentController,
            maxLines: 5,
            enabled: !isSubmitting,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Ví dụ: món ngon, giao nhanh, đóng gói cẩn thận...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary(context),
              ),
              filled: true,
              fillColor: AppColors.card(context),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: AppColors.border(context),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: primary,
                  width: 1.4,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: AppColors.border(context),
                ),
              ),
            ),
          ),

          SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              gradient: isSubmitting ? null : AppColors.primaryGradient(context),
              color: isSubmitting ? Colors.grey.shade500 : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isSubmitting)
                  BoxShadow(
                    color: primary.withOpacity(0.22),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isSubmitting ? null : submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.transparent,
                disabledForegroundColor: Colors.white70,
                shadowColor: Colors.transparent,
                elevation: 0,
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isSubmitting
                  ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Text(
                'Gửi đánh giá',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}