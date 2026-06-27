import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../providers/app_state.dart';
import '../services/order_service.dart';
import '../services/payment_service.dart';
import '../utils/app_colors.dart';
import '../utils/format_money.dart';
import 'location_page.dart';
import 'login_page.dart';
import 'payment_method_page.dart';
import 'sepay_qr_page.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  String selectedVoucher = 'Không dùng';
  String receiveMethod = 'delivery';
  bool isPlacingOrder = false;

  final noteController = TextEditingController();
  final voucherCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(vouchersProvider.notifier).loadVouchers();
    });
  }

  @override
  void dispose() {
    noteController.dispose();
    voucherCodeController.dispose();
    super.dispose();
  }

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

  double getDoubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return 0;
  }

  bool isSePayPayment(PaymentMethod paymentMethod) {
    final type = paymentMethod.type.toLowerCase().trim();
    final title = paymentMethod.title.toLowerCase().trim();
    final subtitle = paymentMethod.subtitle.toLowerCase().trim();

    return type == 'sepay' ||
        type == 'vietqr' ||
        type.contains('sepay') ||
        type.contains('vietqr') ||
        title.contains('sepay') ||
        title.contains('vietqr') ||
        title.contains('qr') ||
        subtitle.contains('sepay') ||
        subtitle.contains('vietqr') ||
        subtitle.contains('qr');
  }

  double calculateSubtotal(
      List<Map<String, dynamic>> products,
      List<CartItem> cartItems,
      ) {
    double subtotal = 0;

    for (final cartItem in cartItems) {
      final product = findProductById(products, cartItem.id);

      if (product == null) continue;

      final price = getDoubleValue(product['price']);
      subtotal += (price + cartItem.toppingPrice) * cartItem.qty;
    }

    return subtotal;
  }

  Map<String, dynamic>? getSelectedVoucherData(
      List<Map<String, dynamic>> vouchers,
      ) {
    if (selectedVoucher == 'Không dùng') return null;

    try {
      return vouchers.firstWhere(
            (voucher) => voucher['code'] == selectedVoucher,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? findVoucherByCode(
      List<Map<String, dynamic>> vouchers,
      String inputCode,
      ) {
    final keyword = inputCode.trim().toUpperCase();

    if (keyword.isEmpty) return null;

    try {
      return vouchers.firstWhere((voucher) {
        final code = voucher['code']?.toString().trim().toUpperCase() ?? '';
        return code == keyword;
      });
    } catch (_) {
      return null;
    }
  }

  bool isVoucherEligible({
    required Map<String, dynamic> voucher,
    required double subtotal,
  }) {
    final minOrder = getDoubleValue(voucher['minOrder']);
    return subtotal >= minOrder;
  }

  double getVoucherDiscount({
    required double subtotal,
    required List<Map<String, dynamic>> vouchers,
  }) {
    final voucher = getSelectedVoucherData(vouchers);

    if (voucher == null) return 0;

    final minOrder = getDoubleValue(voucher['minOrder']);
    final discount = getDoubleValue(voucher['discount']);

    if (subtotal < minOrder) return 0;

    if (discount > subtotal) return subtotal;

    return discount;
  }

  String getVoucherTitle(List<Map<String, dynamic>> vouchers) {
    if (selectedVoucher == 'Không dùng') {
      return 'Không áp dụng voucher';
    }

    final voucher = getSelectedVoucherData(vouchers);

    if (voucher == null) {
      return 'Voucher không khả dụng';
    }

    return '${voucher['code']} - ${voucher['title']}';
  }

  String getCustomerName() {
    final profile = ref.read(customerProfileProvider);

    final fullName = profile?['full_name']?.toString().trim();

    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    return 'Khách hàng';
  }

  String getCustomerPhone() {
    final profile = ref.read(customerProfileProvider);

    final phone = profile?['phone']?.toString().trim();

    if (phone != null && phone.isNotEmpty) {
      return phone;
    }

    return 'Chưa cập nhật';
  }

  bool isSelectedVoucherValid({
    required double subtotal,
    required List<Map<String, dynamic>> vouchers,
  }) {
    if (selectedVoucher == 'Không dùng') return true;

    final voucher = getSelectedVoucherData(vouchers);

    if (voucher == null) return false;

    return isVoucherEligible(
      voucher: voucher,
      subtotal: subtotal,
    );
  }

  void applyVoucherByInput({
    required BuildContext bottomSheetContext,
    required List<Map<String, dynamic>> vouchers,
    required double subtotal,
  }) {
    final inputCode = voucherCodeController.text.trim().toUpperCase();

    if (inputCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập mã voucher'),
        ),
      );
      return;
    }

    final voucher = findVoucherByCode(vouchers, inputCode);

    if (voucher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mã voucher "$inputCode" không tồn tại hoặc đã hết hạn'),
        ),
      );
      return;
    }

    final isEligible = isVoucherEligible(
      voucher: voucher,
      subtotal: subtotal,
    );

    final minOrder = getDoubleValue(voucher['minOrder']);
    final missingAmount = minOrder - subtotal;
    final code = voucher['code']?.toString() ?? inputCode;

    if (!isEligible) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cần mua thêm ${formatMoney(missingAmount)} để dùng voucher $code',
          ),
        ),
      );
      return;
    }

    setState(() {
      selectedVoucher = code;
    });

    ref.read(selectedVoucherProvider.notifier).selectVoucher(code);

    Navigator.pop(bottomSheetContext);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã áp dụng voucher $code'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> placeOrder({
    required List<Map<String, dynamic>> products,
    required List<CartItem> cartItems,
    required List<Map<String, dynamic>> vouchers,
    required double subtotal,
    required double shippingFee,
    required double discount,
    required double total,
    required PaymentMethod selectedPaymentMethod,
  }) async {
    if (isPlacingOrder) return;

    final isLoggedIn = ref.read(loggedInProvider);

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng đăng nhập để đặt hàng'),
        ),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginPage(),
        ),
      );

      return;
    }

    final rawDeliveryLocation = ref.read(deliveryLocationProvider).trim();
    final isDelivery = receiveMethod == 'delivery';
    final deliveryLocation = isDelivery ? rawDeliveryLocation : 'Nhận tại quán';

    if (isDelivery && rawDeliveryLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn địa chỉ giao hàng'),
        ),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LocationPage(),
        ),
      );

      return;
    }

    final voucherValid = isSelectedVoucherValid(
      subtotal: subtotal,
      vouchers: vouchers,
    );

    if (!voucherValid) {
      final voucher = getSelectedVoucherData(vouchers);
      final minOrder = getDoubleValue(voucher?['minOrder']);
      final missing = minOrder - subtotal;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            missing > 0
                ? 'Đơn hàng cần thêm ${formatMoney(missing)} để dùng voucher này'
                : 'Voucher không đủ điều kiện áp dụng',
          ),
        ),
      );

      return;
    }

    final List<Map<String, dynamic>> orderItems = [];

    for (final cartItem in cartItems) {
      final product = findProductById(products, cartItem.id);

      if (product == null) continue;

      final price = getDoubleValue(product['price']);

      orderItems.add({
        'productId': product['id'],
        'title': product['title'],
        'thumbnail': product['thumbnail'],
        'price': price + cartItem.toppingPrice,
        'qty': cartItem.qty,
        'toppings': cartItem.toppings,
      });
    }

    if (orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tìm thấy sản phẩm trong giỏ hàng'),
        ),
      );

      return;
    }

    setState(() {
      isPlacingOrder = true;
    });

    try {
      final orderId = await OrderService().createOrder(
        customerName: getCustomerName(),
        phone: getCustomerPhone(),
        address: deliveryLocation,
        note: noteController.text.trim(),
        paymentMethod: selectedPaymentMethod.type,
        orderType: receiveMethod,
        subtotal: subtotal,
        shippingFee: shippingFee,
        discount: discount,
        total: total,
        items: orderItems,
      );

      final useSePay = isSePayPayment(selectedPaymentMethod);

      if (useSePay) {
        final paymentInfo = await PaymentService().getOrderPaymentInfo(orderId);

        if (!mounted) return;

        final qrUrl = paymentInfo?['payment_qr_url']?.toString() ?? '';
        final paymentCode = paymentInfo?['payment_code']?.toString() ?? '';

        if (qrUrl.isEmpty || paymentCode.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không tạo được mã QR thanh toán'),
            ),
          );
          return;
        }

        final paid = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => SePayQrPage(
              orderId: orderId,
              amount: total,
              paymentCode: paymentCode,
              qrUrl: qrUrl,
            ),
          ),
        );

        if (!mounted) return;

        if (paid == true) {
          final order = OrderModel(
            id: orderId,
            items: orderItems,
            total: total,
            status: 'Chờ xác nhận',
            createdAt: DateTime.now(),
            paymentMethod: 'SePay VietQR',
          );

          ref.read(ordersProvider.notifier).addOrder(order);
          ref.read(cartItemsProvider.notifier).clearCart();
          ref.read(selectedVoucherProvider.notifier).clearVoucher();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thanh toán thành công! Đơn hàng đã được ghi nhận.'),
            ),
          );

          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đơn hàng đã tạo nhưng chưa thanh toán. Vui lòng quét QR để hoàn tất.',
              ),
            ),
          );
        }

        return;
      }

      final order = OrderModel(
        id: orderId,
        items: orderItems,
        total: total,
        status: 'Chờ xác nhận',
        createdAt: DateTime.now(),
        paymentMethod: selectedPaymentMethod.type,
      );

      ref.read(ordersProvider.notifier).addOrder(order);
      ref.read(cartItemsProvider.notifier).clearCart();
      ref.read(selectedVoucherProvider.notifier).clearVoucher();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đặt hàng thành công! Vui lòng thanh toán khi nhận hàng.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đặt hàng: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPlacingOrder = false;
        });
      }
    }
  }

  void showVoucherBottomSheet({
    required List<Map<String, dynamic>> vouchers,
    required double subtotal,
  }) {
    voucherCodeController.clear();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card(context),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (bottomSheetContext) {
        final primary = Theme.of(bottomSheetContext).colorScheme.primary;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 12,
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 18,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border(bottomSheetContext),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Chọn voucher',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary(bottomSheetContext),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tạm tính đơn hàng: ${formatMoney(subtotal)}',
                    style: TextStyle(
                      color: AppColors.textSecondary(bottomSheetContext),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background(bottomSheetContext),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.border(bottomSheetContext),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: voucherCodeController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(
                              color: AppColors.textPrimary(bottomSheetContext),
                              fontWeight: FontWeight.w600,
                            ),
                            onSubmitted: (_) {
                              applyVoucherByInput(
                                bottomSheetContext: bottomSheetContext,
                                vouchers: vouchers,
                                subtotal: subtotal,
                              );
                            },
                            decoration: InputDecoration(
                              hintText: 'Nhập mã voucher',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary(
                                  bottomSheetContext,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.confirmation_number_outlined,
                                color: primary,
                              ),
                              filled: true,
                              fillColor: AppColors.card(bottomSheetContext),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: AppColors.border(bottomSheetContext),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: primary,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient(
                              bottomSheetContext,
                            ),
                            borderRadius: BorderRadius.circular(14),
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
                              applyVoucherByInput(
                                bottomSheetContext: bottomSheetContext,
                                vouchers: vouchers,
                                subtotal: subtotal,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              minimumSize: Size(78, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Áp dụng',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        _VoucherSelectTile(
                          title: 'Không dùng voucher',
                          subtitle: 'Thanh toán không áp dụng mã giảm giá',
                          code: 'Không dùng',
                          isSelected: selectedVoucher == 'Không dùng',
                          isEligible: true,
                          missingAmount: 0,
                          onTap: () {
                            setState(() {
                              selectedVoucher = 'Không dùng';
                            });

                            ref
                                .read(selectedVoucherProvider.notifier)
                                .clearVoucher();

                            Navigator.pop(bottomSheetContext);
                          },
                        ),
                        if (vouchers.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Hiện chưa có voucher khả dụng',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary(
                                  bottomSheetContext,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          ...vouchers.map((voucher) {
                            final code = voucher['code']?.toString() ?? '';
                            final title = voucher['title']?.toString() ?? '';
                            final description =
                                voucher['description']?.toString() ?? '';
                            final minOrder = getDoubleValue(
                              voucher['minOrder'],
                            );
                            final discount = getDoubleValue(
                              voucher['discount'],
                            );
                            final isSelected = selectedVoucher == code;

                            final isEligible = isVoucherEligible(
                              voucher: voucher,
                              subtotal: subtotal,
                            );

                            final missingAmount = minOrder - subtotal;

                            return _VoucherSelectTile(
                              title: title,
                              subtitle:
                              '$code • Giảm ${formatMoney(discount)} • Tối thiểu ${formatMoney(minOrder)}\n$description',
                              code: code,
                              isSelected: isSelected,
                              isEligible: isEligible,
                              missingAmount:
                              missingAmount > 0 ? missingAmount : 0,
                              onTap: () {
                                if (!isEligible) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Cần mua thêm ${formatMoney(missingAmount)} để dùng voucher $code',
                                      ),
                                    ),
                                  );

                                  return;
                                }

                                setState(() {
                                  selectedVoucher = code;
                                });

                                ref
                                    .read(selectedVoucherProvider.notifier)
                                    .selectVoucher(code);

                                Navigator.pop(bottomSheetContext);
                              },
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final cartItems = ref.watch(cartItemsProvider);
    final deliveryLocation = ref.watch(deliveryLocationProvider);
    final selectedVoucherFromProvider = ref.watch(selectedVoucherProvider);
    final vouchers = ref.watch(vouchersProvider);

    final paymentMethods = ref.watch(paymentMethodsProvider);
    final selectedPaymentId = ref.watch(selectedPaymentProvider);
    final primary = Theme.of(context).colorScheme.primary;

    final selectedPaymentMethod = paymentMethods.firstWhere(
          (method) => method.id == selectedPaymentId,
      orElse: () => paymentMethods.first,
    );

    final useSePay = isSePayPayment(selectedPaymentMethod);

    if (selectedVoucher != selectedVoucherFromProvider) {
      selectedVoucher = selectedVoucherFromProvider;
    }

    final subtotal = calculateSubtotal(products, cartItems);
    final shippingFee = receiveMethod == 'delivery' ? 15000.0 : 0.0;

    final voucherValid = isSelectedVoucherValid(
      subtotal: subtotal,
      vouchers: vouchers,
    );

    final profile = ref.watch(customerProfileProvider);

    final rank = profile?['rank']?.toString() ?? 'Member';

    final rankDiscountPercent =
        (profile?['rank_discount'] as num?)?.toDouble() ?? 0;

    final rankDiscount = subtotal * rankDiscountPercent / 100;

    final voucherDiscount = voucherValid
        ? getVoucherDiscount(
      subtotal: subtotal,
      vouchers: vouchers,
    )
        : 0.0;

    final discount = voucherDiscount + rankDiscount;
    final total = subtotal + shippingFee - discount;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Thanh toán',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
        child: Text(
          'Không có sản phẩm để thanh toán',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: 'Hình thức nhận món'),
          _ReceiveMethodBox(
            selectedMethod: receiveMethod,
            onChanged: (value) {
              setState(() {
                receiveMethod = value;
              });
            },
          ),
          SizedBox(height: 14),
          _SectionTitle(
            title: receiveMethod == 'delivery'
                ? 'Địa chỉ giao hàng'
                : 'Nhận tại quán',
          ),
          _AddressBox(
            address: receiveMethod == 'delivery'
                ? deliveryLocation
                : 'Khách tự đến quầy nhận món',
            onTap: receiveMethod == 'delivery'
                ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LocationPage(),
                ),
              );
            }
                : () {},
          ),
          SizedBox(height: 18),
          _SectionTitle(title: 'Món đã chọn'),
          ...cartItems.map((cartItem) {
            final product = findProductById(products, cartItem.id);

            if (product == null) {
              return SizedBox.shrink();
            }

            return _CheckoutItem(
              title: product['title']?.toString() ?? '',
              image: product['thumbnail']?.toString() ?? '',
              price:
              getDoubleValue(product['price']) + cartItem.toppingPrice,
              qty: cartItem.qty,
              toppings: cartItem.toppings,
            );
          }),
          SizedBox(height: 18),
          _SectionTitle(title: 'Voucher'),
          _VoucherBox(
            title: getVoucherTitle(vouchers),
            selectedVoucher: selectedVoucher,
            isValid: voucherValid,
            onTap: () => showVoucherBottomSheet(
              vouchers: vouchers,
              subtotal: subtotal,
            ),
          ),
          if (!voucherValid && selectedVoucher != 'Không dùng') ...[
            SizedBox(height: 8),
            Text(
              'Voucher hiện tại không đủ điều kiện áp dụng cho đơn hàng này.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
          SizedBox(height: 18),
          _SectionTitle(title: 'Phương thức thanh toán'),
          _PaymentMethodBox(
            title: selectedPaymentMethod.title,
            subtitle: selectedPaymentMethod.subtitle,
            type: selectedPaymentMethod.type,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PaymentMethodPage(),
                ),
              );
            },
          ),
          if (useSePay) ...[
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(
                  AppColors.isDark(context) ? 0.18 : 0.10,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.teal.withOpacity(0.28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    color: Colors.teal,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bạn sẽ quét mã QR và chuyển khoản trước. Đơn hàng chỉ thành công sau khi hệ thống xác nhận đã thanh toán.',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 18),
          _SectionTitle(title: 'Ghi chú đơn hàng'),
          TextField(
            controller: noteController,
            maxLines: 3,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Ví dụ: ít đá, ít đường, giao giờ nghỉ trưa...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary(context),
              ),
              filled: true,
              fillColor: AppColors.card(context),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.border(context),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          SizedBox(height: 18),
          Container(
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
            child: Column(
              children: [
                _SectionTitle(title: 'Tóm tắt thanh toán'),
                _PriceRow(
                  title: 'Tạm tính',
                  value: formatMoney(subtotal),
                ),
                _PriceRow(
                  title: 'Phí giao hàng',
                  value: formatMoney(shippingFee),
                ),
                _PriceRow(
                  title: 'Hạng thành viên',
                  value:
                  '$rank - giảm ${rankDiscountPercent.toStringAsFixed(0)}%',
                ),
                _PriceRow(
                  title: 'Voucher',
                  value: '-${formatMoney(voucherDiscount)}',
                  isDiscount: true,
                ),
                _PriceRow(
                  title: 'Ưu đãi thành viên',
                  value: '-${formatMoney(rankDiscount)}',
                  isDiscount: true,
                ),
                Divider(
                  color: AppColors.border(context),
                ),
                _PriceRow(
                  title: 'Tổng thanh toán',
                  value: formatMoney(total),
                  isTotal: true,
                ),
              ],
            ),
          ),
          SizedBox(height: 90),
        ],
      ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.all(16),
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
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              gradient:
              isPlacingOrder ? null : AppColors.primaryGradient(context),
              color: isPlacingOrder ? Colors.grey.shade600 : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isPlacingOrder)
                  BoxShadow(
                    color: primary.withOpacity(0.22),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: isPlacingOrder
                  ? null
                  : () {
                placeOrder(
                  products: products,
                  cartItems: cartItems,
                  vouchers: vouchers,
                  subtotal: subtotal,
                  shippingFee: shippingFee,
                  discount: discount,
                  total: total,
                  selectedPaymentMethod: selectedPaymentMethod,
                );
              },
              icon: isPlacingOrder
                  ? SizedBox.shrink()
                  : Icon(
                useSePay
                    ? Icons.qr_code_2_rounded
                    : Icons.check_circle_outline,
              ),
              label: isPlacingOrder
                  ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Text(
                useSePay
                    ? 'Tạo đơn và thanh toán QR'
                    : 'Xác nhận đặt hàng',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


class _ReceiveMethodBox extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onChanged;

  const _ReceiveMethodBox({
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    Widget option({
      required String value,
      required IconData icon,
      required String title,
      required String subtitle,
    }) {
      final selected = selectedMethod == value;

      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onChanged(value),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? primary.withOpacity(AppColors.isDark(context) ? 0.22 : 0.12)
                  : AppColors.card(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? primary : AppColors.border(context),
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: selected ? primary : AppColors.textSecondary(context),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        option(
          value: 'delivery',
          icon: Icons.delivery_dining_rounded,
          title: 'Giao hàng',
          subtitle: 'Giao đến địa chỉ',
        ),
        const SizedBox(width: 12),
        option(
          value: 'pickup',
          icon: Icons.storefront_rounded,
          title: 'Tự đến lấy',
          subtitle: 'Không tính phí ship',
        ),
      ],
    );
  }
}

class _AddressBox extends StatelessWidget {
  final String address;
  final VoidCallback onTap;

  _AddressBox({
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayAddress =
    address.trim().isEmpty ? 'Chưa chọn địa chỉ giao hàng' : address;
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
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
                Icons.location_on_outlined,
                color: primary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Địa chỉ giao hàng',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    displayAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      height: 1.35,
                      fontSize: 13,
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
                color: primary.withOpacity(
                  AppColors.isDark(context) ? 0.20 : 0.12,
                ),
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
    );
  }
}

class _CheckoutItem extends StatelessWidget {
  final String title;
  final String image;
  final double price;
  final int qty;
  final List<String> toppings;

  _CheckoutItem({
    required this.title,
    required this.image,
    required this.price,
    required this.qty,
    required this.toppings,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border(context),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 64,
              height: 64,
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (toppings.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Column(
                    children: toppings.map((topping) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              topping,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            'x1',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(price),
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'x$qty',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoucherBox extends StatelessWidget {
  final String title;
  final String selectedVoucher;
  final bool isValid;
  final VoidCallback onTap;

  _VoucherBox({
    required this.title,
    required this.selectedVoucher,
    required this.isValid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasVoucher = selectedVoucher != 'Không dùng';
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasVoucher
                ? isValid
                ? primary
                : Colors.red
                : AppColors.border(context),
            width: hasVoucher ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: hasVoucher && isValid
                  ? primary.withOpacity(0.12)
                  : AppColors.shadow(context),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: hasVoucher && !isValid
                  ? Colors.red.withOpacity(0.12)
                  : primary.withOpacity(
                AppColors.isDark(context) ? 0.22 : 0.13,
              ),
              child: Icon(
                hasVoucher
                    ? isValid
                    ? Icons.check_circle_outline
                    : Icons.error_outline
                    : Icons.confirmation_number_outlined,
                color: hasVoucher && !isValid ? Colors.red : primary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherSelectTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String code;
  final bool isSelected;
  final bool isEligible;
  final double missingAmount;
  final VoidCallback onTap;

  _VoucherSelectTile({
    required this.title,
    required this.subtitle,
    required this.code,
    required this.isSelected,
    required this.isEligible,
    required this.missingAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final color = isEligible ? primary : Colors.grey;

    return Opacity(
      opacity: isEligible ? 1 : 0.58,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withOpacity(
            AppColors.isDark(context) ? 0.20 : 0.12,
          )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary.withOpacity(0.25) : Colors.transparent,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? primary
                : primary.withOpacity(
              AppColors.isDark(context) ? 0.22 : 0.13,
            ),
            child: Icon(
              isSelected ? Icons.check : Icons.confirmation_number_outlined,
              color: isSelected ? Colors.white : primary,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          subtitle: Text(
            isEligible
                ? subtitle
                : '$subtitle\nCần mua thêm ${formatMoney(missingAmount)}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isEligible ? AppColors.textSecondary(context) : Colors.red,
              fontSize: 12,
            ),
          ),
          trailing: isSelected
              ? Icon(
            Icons.check_circle,
            color: primary,
          )
              : Text(
            isEligible ? code : 'Chưa đủ',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final String type;
  final VoidCallback onTap;

  _PaymentMethodBox({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.onTap,
  });

  IconData getIcon() {
    final value = type.toLowerCase().trim();

    if (value.contains('sepay') || value.contains('vietqr') || value == 'qr') {
      return Icons.qr_code_2_rounded;
    }

    switch (value) {
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'visa':
        return Icons.credit_card;
      case 'cash':
        return Icons.payments_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  Color getColor(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final value = type.toLowerCase().trim();

    if (value.contains('sepay') || value.contains('vietqr') || value == 'qr') {
      return Colors.teal;
    }

    switch (value) {
      case 'wallet':
        return Colors.purple;
      case 'visa':
        return Colors.blue;
      case 'cash':
        return Colors.green;
      default:
        return primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor(context);

    return InkWell(
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
              backgroundColor: color.withOpacity(
                AppColors.isDark(context) ? 0.22 : 0.13,
              ),
              child: Icon(
                getIcon(),
                color: color,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thanh toán bằng',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Đổi',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isTotal;
  final bool isDiscount;

  _PriceRow({
    required this.title,
    required this.value,
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = AppColors.textPrimary(context);

    if (isTotal) {
      textColor = Theme.of(context).colorScheme.primary;
    }

    if (isDiscount) {
      textColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}