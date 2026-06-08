import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';

class PaymentMethodPage extends ConsumerStatefulWidget {
  PaymentMethodPage({super.key});

  @override
  ConsumerState<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends ConsumerState<PaymentMethodPage> {
  final walletNameController = TextEditingController();
  final walletPhoneController = TextEditingController();

  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();

  @override
  void dispose() {
    walletNameController.dispose();
    walletPhoneController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    super.dispose();
  }

  IconData getIcon(String type) {
    switch (type) {
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'visa':
        return Icons.credit_card;
      default:
        return Icons.payments_outlined;
    }
  }

  Color getColor(BuildContext context, String type) {
    switch (type) {
      case 'wallet':
        return Colors.purple;
      case 'visa':
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  void showAddWalletDialog() {
    walletNameController.text = 'Ví MoMo';
    walletPhoneController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final primary = Theme.of(dialogContext).colorScheme.primary;

        return AlertDialog(
          backgroundColor: AppColors.card(dialogContext),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Thêm ví điện tử',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(dialogContext),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogInputField(
                controller: walletNameController,
                label: 'Tên ví',
                hint: 'Ví dụ: Ví MoMo, ZaloPay',
                icon: Icons.account_balance_wallet_outlined,
              ),
              SizedBox(height: 12),
              _DialogInputField(
                controller: walletPhoneController,
                label: 'Số điện thoại ví',
                hint: 'Ví dụ: 090xxxxxxx',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: AppColors.textSecondary(dialogContext),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(dialogContext),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.20),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  final walletName = walletNameController.text.trim();
                  final phone = walletPhoneController.text.trim();

                  if (walletName.isEmpty || phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Vui lòng nhập đầy đủ thông tin ví'),
                      ),
                    );
                    return;
                  }

                  ref
                      .read(paymentMethodsProvider.notifier)
                      .addWallet(walletName, phone);

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm ví điện tử'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Thêm',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showAddVisaDialog() {
    cardNumberController.clear();
    expiryController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final primary = Theme.of(dialogContext).colorScheme.primary;

        return AlertDialog(
          backgroundColor: AppColors.card(dialogContext),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Thêm thẻ Visa',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(dialogContext),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogInputField(
                controller: cardNumberController,
                label: 'Số thẻ',
                hint: 'Ví dụ: 4111111111111234',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              _DialogInputField(
                controller: expiryController,
                label: 'Ngày hết hạn',
                hint: 'MM/YY',
                icon: Icons.date_range_outlined,
                keyboardType: TextInputType.datetime,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: AppColors.textSecondary(dialogContext),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(dialogContext),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.20),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  final cardNumber = cardNumberController.text.trim();
                  final expiry = expiryController.text.trim();

                  if (cardNumber.length < 4 || expiry.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Vui lòng nhập thông tin thẻ hợp lệ'),
                      ),
                    );
                    return;
                  }

                  ref.read(paymentMethodsProvider.notifier).addVisa(
                    cardNumber,
                    expiry,
                  );

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm thẻ Visa'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Thêm',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final methods = ref.watch(paymentMethodsProvider);
    final selectedPayment = ref.watch(selectedPaymentProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Phương thức thanh toán',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PaymentHeader(),

          SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient(context),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.20),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: showAddWalletDialog,
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    label: Text('Thêm ví'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: showAddVisaDialog,
                  icon: Icon(Icons.credit_card),
                  label: Text('Thêm Visa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 22),

          Row(
            children: [
              Text(
                'Đã lưu',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 20,
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
                  '${methods.length} phương thức',
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          ...methods.map((method) {
            final isSelected = selectedPayment == method.id;
            final color = getColor(context, method.type);

            return _PaymentMethodCard(
              id: method.id,
              title: method.title,
              subtitle: method.subtitle,
              type: method.type,
              color: color,
              icon: getIcon(method.type),
              isSelected: isSelected,
              selectedPayment: selectedPayment,
              onSelected: () {
                ref
                    .read(selectedPaymentProvider.notifier)
                    .selectPayment(method.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã chọn ${method.title} làm mặc định',
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              onDelete: method.id == 'cash'
                  ? null
                  : () {
                ref
                    .read(paymentMethodsProvider.notifier)
                    .removeMethod(method.id);

                if (selectedPayment == method.id) {
                  ref
                      .read(selectedPaymentProvider.notifier)
                      .selectPayment('cash');
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa phương thức thanh toán'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _PaymentHeader extends StatelessWidget {
  _PaymentHeader();

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
                Icons.payment,
                color: Colors.white,
                size: 38,
              ),
            ),

            SizedBox(width: 14),

            Expanded(
              child: Text(
                'Thêm ví điện tử hoặc thẻ Visa để thanh toán nhanh hơn.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final String selectedPayment;
  final VoidCallback onSelected;
  final VoidCallback? onDelete;

  _PaymentMethodCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.selectedPayment,
    required this.onSelected,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? color : AppColors.border(context),
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? color.withOpacity(0.14)
                : AppColors.shadow(context),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Radio<String>(
            value: id,
            groupValue: selectedPayment,
            activeColor: color,
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return color;
              }

              return AppColors.textSecondary(context);
            }),
            onChanged: (value) {
              if (value == null) return;
              onSelected();
            },
          ),

          CircleAvatar(
            backgroundColor: color.withOpacity(
              AppColors.isDark(context) ? 0.20 : 0.12,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onSelected,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(height: 6),
                      Text(
                        'Đang dùng mặc định',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            )
          else
            Icon(
              Icons.lock_outline_rounded,
              color: AppColors.textSecondary(context),
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _DialogInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  _DialogInputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: AppColors.textSecondary(context),
        ),
        hintStyle: TextStyle(
          color: AppColors.textSecondary(context),
        ),
        prefixIcon: Icon(
          icon,
          color: primary,
        ),
        filled: true,
        fillColor: AppColors.background(context),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.border(context),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}