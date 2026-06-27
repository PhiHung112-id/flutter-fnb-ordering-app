import 'dart:async';

import 'package:flutter/material.dart';

import '../services/payment_service.dart';
import '../utils/app_colors.dart';

class SePayQrPage extends StatefulWidget {
  final int orderId;
  final double amount;
  final String paymentCode;
  final String qrUrl;

  const SePayQrPage({
    super.key,
    required this.orderId,
    required this.amount,
    required this.paymentCode,
    required this.qrUrl,
  });

  @override
  State<SePayQrPage> createState() => _SePayQrPageState();
}

class _SePayQrPageState extends State<SePayQrPage> {
  Timer? timer;
  bool isPaid = false;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => checkPaymentStatus(),
    );
  }

  Future<void> checkPaymentStatus() async {
    final status = await PaymentService().getOrderPaymentStatus(widget.orderId);

    if (status == 'paid') {
      timer?.cancel();

      if (!mounted) return;

      setState(() {
        isPaid = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanh toán thành công'),
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatMoney(double value) {
    return '${value.round()}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Thanh toán SePay'),
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.border(context),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Quét mã QR để thanh toán',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mở app ngân hàng và quét mã VietQR bên dưới.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    widget.qrUrl,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 18),
                _InfoRow(
                  title: 'Số tiền',
                  value: formatMoney(widget.amount),
                ),
                _InfoRow(
                  title: 'Nội dung CK',
                  value: widget.paymentCode,
                ),
                const SizedBox(height: 18),
                if (isPaid)
                  const Text(
                    'Đã thanh toán',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                else
                  const Text(
                    'Đang chờ xác nhận thanh toán...',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSoft(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          SelectableText(
            value,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}