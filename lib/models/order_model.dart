class OrderModel {
  final int id;
  final List<Map<String, dynamic>> items;
  final double total;
  final String status;
  final DateTime createdAt;

  final String address;
  final String customerName;
  final String phone;
  final String note;
  final String paymentMethod;

  final double subtotal;
  final double shippingFee;
  final double discount;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.address = '',
    this.customerName = '',
    this.phone = '',
    this.note = '',
    this.paymentMethod = 'cash',
    this.subtotal = 0,
    this.shippingFee = 0,
    this.discount = 0,
  });

  OrderModel copyWith({
    int? id,
    List<Map<String, dynamic>>? items,
    double? total,
    String? status,
    DateTime? createdAt,
    String? address,
    String? customerName,
    String? phone,
    String? note,
    String? paymentMethod,
    double? subtotal,
    double? shippingFee,
    double? discount,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      address: address ?? this.address,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      discount: discount ?? this.discount,
    );
  }

  factory OrderModel.fromSupabase(Map<String, dynamic> json) {
    final rawItems = json['order_items'];

    final List<Map<String, dynamic>> items = rawItems is List
        ? rawItems.map((item) {
      final map = Map<String, dynamic>.from(item as Map);

      return {
        'id': map['id'],
        'order_id': map['order_id'],

        'productId': _toInt(map['product_id']),
        'product_id': _toInt(map['product_id']),

        'title': map['product_title']?.toString() ?? 'Món ăn',
        'product_title': map['product_title']?.toString() ?? 'Món ăn',

        'thumbnail': map['product_thumbnail']?.toString() ?? '',
        'product_thumbnail': map['product_thumbnail']?.toString() ?? '',

        'price': _toDouble(map['price']),

        'qty': _toInt(map['qty']),
        'quantity': _toInt(map['qty']),

        'toppings': _parseToppings(map['toppings']),
      };
    }).toList()
        : <Map<String, dynamic>>[];

    return OrderModel(
      id: _toInt(json['id']),
      items: items,
      total: _toDouble(json['total']) > 0 ? _toDouble(json['total']) : _toDouble(json['total_amount']),
      status: _normalizeStatus(json['status']),
      createdAt: _toDateTime(json['created_at']).toLocal(),

      address: json['address']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      paymentMethod: _normalizePaymentMethod(json['payment_method']),

      subtotal: _toDouble(json['subtotal']),
      shippingFee: _toDouble(json['shipping_fee']),
      discount: _toDouble(json['discount']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static List<dynamic> _parseToppings(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value;
    }

    return [];
  }

  static String _normalizePaymentMethod(dynamic value) {
    final payment = value?.toString().trim() ?? '';

    if (payment.isEmpty) {
      return 'cash';
    }

    final lower = payment.toLowerCase();

    if (lower == 'cash' ||
        lower.contains('tiền mặt') ||
        lower.contains('tien mat') ||
        lower.contains('cod') ||
        lower.contains('nhận hàng') ||
        lower.contains('nhan hang')) {
      return 'cash';
    }

    if (lower == 'sepay' ||
        lower == 'sepay vietqr' ||
        lower == 'vietqr' ||
        lower.contains('sepay') ||
        lower.contains('vietqr') ||
        lower.contains('qr')) {
      return 'SePay VietQR';
    }

    return payment;
  }

  static String _normalizeStatus(dynamic value) {
    final status = value?.toString().trim() ?? '';
    final lower = status.toLowerCase();

    if (lower.isEmpty) return 'Chờ xác nhận';

    if (lower == 'waiting_payment' ||
        lower == 'pending_payment' ||
        lower == 'chờ thanh toán' ||
        lower == 'cho thanh toan') {
      return 'Chờ thanh toán';
    }

    if (lower == 'new' ||
        lower == 'pending' ||
        lower == 'processing' ||
        lower == 'chờ xác nhận' ||
        lower == 'cho xac nhan' ||
        lower == 'đang xử lý' ||
        lower == 'dang xu ly') {
      return 'Chờ xác nhận';
    }

    if (lower == 'accepted' ||
        lower == 'confirmed' ||
        lower == 'đã xác nhận' ||
        lower == 'da xac nhan') {
      return 'Đã xác nhận';
    }

    if (lower == 'chờ nhận làm' ||
        lower == 'cho nhan lam' ||
        lower == 'đã thanh toán' ||
        lower == 'da thanh toan') {
      return 'Chờ nhận làm';
    }

    if (lower == 'preparing' ||
        lower == 'đang chuẩn bị' ||
        lower == 'dang chuan bi' ||
        lower == 'đang làm' ||
        lower == 'dang lam') {
      return 'Đang chuẩn bị';
    }

    if (lower == 'ready' ||
        lower == 'done' ||
        lower == 'đã xong' ||
        lower == 'da xong') {
      return 'Hoàn thành';
    }

    if (lower == 'shipping' ||
        lower == 'delivering' ||
        lower == 'đang giao' ||
        lower == 'dang giao') {
      return 'Đang giao';
    }

    if (lower == 'completed' ||
        lower == 'hoàn thành' ||
        lower == 'hoan thanh') {
      return 'Hoàn thành';
    }

    if (lower == 'cancelled' ||
        lower == 'canceled' ||
        lower == 'refunded' ||
        lower == 'đã hủy' ||
        lower == 'da huy') {
      return 'Đã hủy';
    }

    return status;
  }
}