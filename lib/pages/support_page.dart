import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class SupportPage extends StatelessWidget {
  SupportPage({super.key});

  static const faqs = [
    {
      'question': 'Làm sao để đặt món?',
      'answer': 'Bạn chọn món, thêm vào giỏ hàng, sau đó vào giỏ để thanh toán.',
    },
    {
      'question': 'Tôi có thể hủy đơn không?',
      'answer':
      'Bạn có thể hủy đơn khi đơn còn ở trạng thái Đang xử lý. Nếu đơn đã chuẩn bị hoặc đang giao, vui lòng liên hệ hỗ trợ.',
    },
    {
      'question': 'Voucher dùng như thế nào?',
      'answer':
      'Bạn có thể chọn voucher ở màn hình thanh toán trước khi xác nhận đơn. Voucher chỉ áp dụng khi đơn hàng đạt điều kiện tối thiểu.',
    },
    {
      'question': 'Có hỗ trợ thanh toán online không?',
      'answer':
      'App có giao diện chọn phương thức thanh toán. Phần thanh toán online thật có thể kết nối thêm ở backend.',
    },
  ];

  void showContactMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Hỗ trợ khách hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            color: primary,
            onPressed: () {
              showContactMessage(
                context,
                'Trung tâm hỗ trợ Chill Bites luôn sẵn sàng hỗ trợ bạn',
              );
            },
            icon: Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SupportHeader(),

          SizedBox(height: 18),

          _ContactItem(
            icon: Icons.phone,
            title: 'Hotline',
            value: '1900 1234',
            onTap: () {
              showContactMessage(
                context,
                'Tính năng gọi hotline sẽ kết nối sau',
              );
            },
          ),

          _ContactItem(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'support@chillbites.vn',
            onTap: () {
              showContactMessage(
                context,
                'Tính năng gửi email hỗ trợ sẽ phát triển sau',
              );
            },
          ),

          _ContactItem(
            icon: Icons.location_on_outlined,
            title: 'Địa chỉ',
            value: 'Thuận An, Bình Dương',
            onTap: () {
              showContactMessage(
                context,
                'Địa chỉ cửa hàng: Thuận An, Bình Dương',
              );
            },
          ),

          SizedBox(height: 20),

          Row(
            children: [
              Text(
                'Câu hỏi thường gặp',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(
                    AppColors.isDark(context) ? 0.20 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primary.withOpacity(0.25),
                  ),
                ),
                child: Text(
                  '${faqs.length} mục',
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          ...faqs.map((faq) {
            return _FaqItem(
              question: faq['question']!,
              answer: faq['answer']!,
            );
          }),

          SizedBox(height: 18),

          _SupportNoteCard(),

          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SupportHeader extends StatelessWidget {
  _SupportHeader();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(
              AppColors.isDark(context) ? 0.28 : 0.22,
            ),
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
                Icons.support_agent,
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
                    'Chill Bites Support',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Chúng tôi luôn sẵn sàng hỗ trợ bạn trong quá trình đặt món.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
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

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  _ContactItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(18),
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
            children: [
              CircleAvatar(
                backgroundColor: primary.withOpacity(
                  AppColors.isDark(context) ? 0.22 : 0.13,
                ),
                child: Icon(
                  icon,
                  color: primary,
                ),
              ),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(width: 8),

              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(width: 4),

              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: primary.withOpacity(0.08),
          highlightColor: primary.withOpacity(0.05),
        ),
        child: ExpansionTile(
          iconColor: primary,
          collapsedIconColor: AppColors.textSecondary(context),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          title: Text(
            question,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w900,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportNoteCard extends StatelessWidget {
  _SupportNoteCard();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(
          AppColors.isDark(context) ? 0.20 : 0.12,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: primary.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(
              AppColors.isDark(context) ? 0.10 : 0.08,
            ),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: primary,
            size: 28,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'Nếu đơn hàng gặp sự cố như thiếu món, giao trễ hoặc sai món, hãy vào chi tiết đơn hàng và chọn Hỗ trợ.',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}