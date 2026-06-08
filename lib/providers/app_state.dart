import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';

import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/voucher_service.dart';
import '../services/category_service.dart';
import '../services/address_service.dart';
import '../services/favorite_service.dart';
import '../services/payment_service.dart';
import '../services/order_service.dart';
import '../services/banner_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsNotifier extends Notifier<List<Map<String, dynamic>>> {
  bool loading = false;
  bool loadedFromSupabase = false;

  @override
  List<Map<String, dynamic>> build() {
    return [];
  }

  Future<void> loadFromSupabase() async {
    if (loading || loadedFromSupabase) return;

    loading = true;

    try {
      final data = await ProductService().getProducts();

      state = data;
      loadedFromSupabase = true;
    } catch (e) {
      loadedFromSupabase = false;
      state = [];
      print('Lỗi load sản phẩm Supabase: $e');
    } finally {
      loading = false;
    }
  }

  Future<void> refreshFromSupabase() async {
    loading = true;
    loadedFromSupabase = false;

    try {
      final data = await ProductService().getProducts();

      state = data;
      loadedFromSupabase = true;
    } catch (e) {
      state = [];
      print('Lỗi refresh sản phẩm Supabase: $e');
    } finally {
      loading = false;
    }
  }
}

final productsProvider =
NotifierProvider<ProductsNotifier, List<Map<String, dynamic>>>(
  ProductsNotifier.new,
);

class CategoriesNotifier extends Notifier<List<Map<String, dynamic>>> {
  bool loading = false;
  bool loaded = false;

  @override
  List<Map<String, dynamic>> build() {
    return [];
  }

  Future<void> loadCategories() async {
    if (loading || loaded) return;

    loading = true;

    try {
      final data = await CategoryService().getCategories();

      state = data;
      loaded = true;
    } catch (e) {
      state = [];
      loaded = false;
      print('Lỗi load categories Supabase: $e');
    } finally {
      loading = false;
    }
  }

  Future<void> refreshCategories() async {
    loading = true;
    loaded = false;

    try {
      final data = await CategoryService().getCategories();

      state = data;
      loaded = true;
    } catch (e) {
      state = [];
      print('Lỗi refresh categories Supabase: $e');
    } finally {
      loading = false;
    }
  }
}

final categoriesProvider =
NotifierProvider<CategoriesNotifier, List<Map<String, dynamic>>>(
  CategoriesNotifier.new,
);

class CategoryNotifier extends Notifier<String> {
  @override
  String build() {
    return 'Tất cả';
  }

  void selectCategory(String category) {
    state = category;
  }
}

final selectedCategoryProvider =
NotifierProvider<CategoryNotifier, String>(
  CategoryNotifier.new,
);

class HomeFilterNotifier extends Notifier<String> {
  @override
  String build() {
    return 'Gợi ý';
  }

  void selectFilter(String filter) {
    state = filter;
  }
}

final homeFilterProvider =
NotifierProvider<HomeFilterNotifier, String>(
  HomeFilterNotifier.new,
);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  void addToCart(
      int productId, {
        List<String> toppings = const [],
        double toppingPrice = 0,
      }) {
    final newItem = CartItem(
      id: productId,
      qty: 1,
      toppings: toppings,
      toppingPrice: toppingPrice,
    );

    final index = state.indexWhere((item) => item.key == newItem.key);

    if (index == -1) {
      state = [...state, newItem];
    } else {
      final newCart = [...state];
      newCart[index] = newCart[index].copyWith(
        qty: newCart[index].qty + 1,
      );
      state = newCart;
    }
  }

  void removeFromCart(CartItem cartItem) {
    state = state.where((item) => item.key != cartItem.key).toList();
  }

  void increaseQty(CartItem cartItem) {
    final newCart = [...state];
    final index = newCart.indexWhere((item) => item.key == cartItem.key);

    if (index != -1) {
      newCart[index] = newCart[index].copyWith(
        qty: newCart[index].qty + 1,
      );
      state = newCart;
    }
  }

  void decreaseQty(CartItem cartItem) {
    final newCart = [...state];
    final index = newCart.indexWhere((item) => item.key == cartItem.key);

    if (index != -1) {
      if (newCart[index].qty > 1) {
        newCart[index] = newCart[index].copyWith(
          qty: newCart[index].qty - 1,
        );
      } else {
        newCart.removeAt(index);
      }

      state = newCart;
    }
  }

  void clearCart() {
    state = [];
  }
}

final cartItemsProvider =
NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class FavoritesNotifier extends Notifier<List<int>> {
  bool loading = false;

  @override
  List<int> build() {
    return [];
  }

  Future<void> loadFavorites() async {
    if (loading) return;

    loading = true;

    try {
      final data = await FavoriteService().getFavorites();
      state = data;
    } catch (e) {
      state = [];
      print('Lỗi load favorites: $e');
    } finally {
      loading = false;
    }
  }

  Future<void> toggleFavorite(int productId) async {
    final isFavorite = state.contains(productId);
    final oldState = [...state];

    if (isFavorite) {
      state = state.where((id) => id != productId).toList();
    } else {
      state = [...state, productId];
    }

    try {
      await FavoriteService().toggleFavorite(
        productId: productId,
        isFavorite: isFavorite,
      );
    } catch (e) {
      state = oldState;
      print('Lỗi toggle favorite: $e');
      rethrow;
    }
  }

  void clearFavorites() {
    state = [];
  }
}

final favoritesProvider =
NotifierProvider<FavoritesNotifier, List<int>>(
  FavoritesNotifier.new,
);

class OrdersNotifier extends Notifier<List<OrderModel>> {
  bool loading = false;

  @override
  List<OrderModel> build() {
    return [];
  }

  Future<void> loadOrdersFromSupabase() async {
    if (loading) return;

    loading = true;

    try {
      final data = await OrderService().getMyOrders();

      final orders = data.map((item) {
        final orderItemsRaw = item['order_items'] as List? ?? [];

        final orderItems = orderItemsRaw.map<Map<String, dynamic>>((orderItem) {
          return {
            'productId': orderItem['product_id'],
            'title': orderItem['product_title'],
            'thumbnail': orderItem['product_thumbnail'],
            'price': (orderItem['price'] as num).toDouble(),
            'qty': (orderItem['qty'] as num).toInt(),
            'toppings': List<String>.from(orderItem['toppings'] ?? []),
          };
        }).toList();

        return OrderModel(
          id: (item['id'] as num).toInt(),
          items: orderItems,
          total: (item['total'] as num).toDouble(),
          status: item['status'].toString(),
          createdAt: DateTime.parse(item['created_at'].toString()).toLocal(),
        );
      }).toList();

      state = orders;
    } catch (e) {
      state = [];
      print('Lỗi load orders: $e');
    } finally {
      loading = false;
    }
  }

  void addOrder(OrderModel order) {
    state = [order, ...state];
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final oldState = [...state];

    state = state.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: newStatus);
      }

      return order;
    }).toList();

    try {
      await OrderService().updateOrderStatus(
        orderId: orderId,
        status: newStatus,
      );
    } catch (e) {
      state = oldState;
      print('Lỗi update order status: $e');
    }
  }

  OrderModel? getOrderById(int orderId) {
    try {
      return state.firstWhere((order) => order.id == orderId);
    } catch (_) {
      return null;
    }
  }

  void clearOrders() {
    state = [];
  }
}

final ordersProvider =
NotifierProvider<OrdersNotifier, List<OrderModel>>(
  OrdersNotifier.new,
);

class CustomerProfileNotifier extends Notifier<Map<String, dynamic>?> {
  bool loading = false;

  @override
  Map<String, dynamic>? build() {
    return null;
  }

  Future<void> loadProfile() async {
    if (loading) return;

    loading = true;

    try {
      final data = await AuthService().getProfile();
      state = data;
    } catch (e) {
      state = null;
      print('Lỗi load profile: $e');
    } finally {
      loading = false;
    }
  }

  void clearProfile() {
    state = null;
  }
}

final customerProfileProvider =
NotifierProvider<CustomerProfileNotifier, Map<String, dynamic>?>(
  CustomerProfileNotifier.new,
);

class LoginNotifier extends Notifier<bool> {
  @override
  bool build() {
    return AuthService().isLoggedIn;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await AuthService().signIn(
      email: email,
      password: password,
    );

    state = true;
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    await AuthService().signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );

    state = true;
  }

  Future<void> logout() async {
    await AuthService().signOut();

    state = false;
  }
}

final loggedInProvider =
NotifierProvider<LoginNotifier, bool>(
  LoginNotifier.new,
);

class LocationNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void updateLocation(String newLocation) {
    state = newLocation;
  }

  void clearLocation() {
    state = '';
  }
}

final deliveryLocationProvider =
NotifierProvider<LocationNotifier, String>(
  LocationNotifier.new,
);

class SavedAddressesNotifier extends Notifier<List<String>> {
  bool loading = false;

  @override
  List<String> build() {
    return [];
  }

  Future<void> loadAddresses() async {
    if (loading) return;

    loading = true;

    try {
      final data = await AddressService().getAddresses();
      state = data;

      if (data.isNotEmpty) {
        ref.read(deliveryLocationProvider.notifier).updateLocation(data.first);
      }
    } catch (e) {
      state = [];
      print('Lỗi load addresses: $e');
    } finally {
      loading = false;
    }
  }

  Future<void> addAddress(String address) async {
    if (address.trim().isEmpty) return;

    final oldState = [...state];

    state = [...state, address];
    ref.read(deliveryLocationProvider.notifier).updateLocation(address);

    try {
      await AddressService().addAddress(address);
    } catch (e) {
      state = oldState;
      print('Lỗi thêm địa chỉ: $e');
    }
  }

  Future<void> removeAddress(String address) async {
    final oldState = [...state];

    state = state.where((item) => item != address).toList();

    try {
      await AddressService().deleteAddressByText(address);
    } catch (e) {
      state = oldState;
      print('Lỗi xoá địa chỉ: $e');
    }
  }

  void clearAddresses() {
    state = [];
  }
}

final savedAddressesProvider =
NotifierProvider<SavedAddressesNotifier, List<String>>(
  SavedAddressesNotifier.new,
);

class ReviewsNotifier extends Notifier<List<ReviewModel>> {
  @override
  List<ReviewModel> build() {
    return [];
  }

  void addReview(ReviewModel review) {
    state = [review, ...state];
  }

  void setReviews(List<ReviewModel> reviews) {
    state = reviews;
  }

  bool hasReviewed(int orderId) {
    return state.any((review) => review.orderId == orderId);
  }

  ReviewModel? getReviewByOrderId(int orderId) {
    try {
      return state.firstWhere((review) => review.orderId == orderId);
    } catch (_) {
      return null;
    }
  }

  void clearReviews() {
    state = [];
  }
}

final reviewsProvider =
NotifierProvider<ReviewsNotifier, List<ReviewModel>>(
  ReviewsNotifier.new,
);

class BannersNotifier extends Notifier<List<Map<String, dynamic>>> {
  bool loading = false;
  bool loaded = false;

  @override
  List<Map<String, dynamic>> build() {
    return [];
  }

  Future<void> loadBanners() async {
    if (loading || loaded) return;

    loading = true;

    try {
      final data = await BannerService().getBanners();

      state = data;
      loaded = true;
    } catch (e) {
      state = [];
      loaded = false;
      print('Lỗi load banners Supabase: $e');
    } finally {
      loading = false;
    }
  }

  Future<void> refreshBanners() async {
    loading = true;
    loaded = false;

    try {
      final data = await BannerService().getBanners();

      state = data;
      loaded = true;
    } catch (e) {
      state = [];
      print('Lỗi refresh banners Supabase: $e');
    } finally {
      loading = false;
    }
  }
}

final bannersProvider =
NotifierProvider<BannersNotifier, List<Map<String, dynamic>>>(
  BannersNotifier.new,
);

class SelectedVoucherNotifier extends Notifier<String> {
  @override
  String build() {
    return 'Không dùng';
  }

  void selectVoucher(String voucherCode) {
    state = voucherCode;
  }

  void clearVoucher() {
    state = 'Không dùng';
  }
}

final selectedVoucherProvider =
NotifierProvider<SelectedVoucherNotifier, String>(
  SelectedVoucherNotifier.new,
);

class VouchersNotifier extends Notifier<List<Map<String, dynamic>>> {
  bool loading = false;
  bool loaded = false;

  @override
  List<Map<String, dynamic>> build() {
    return [];
  }

  Future<void> loadVouchers() async {
    if (loading) return;

    if (loaded && state.isNotEmpty) return;

    loading = true;

    try {
      final data = await VoucherService().getVouchers();

      if (data.isNotEmpty) {
        state = data;
        loaded = true;
      } else {
        state = [];
        loaded = false;
        print('Supabase trả về 0 voucher, cho phép load lại lần sau');
      }
    } catch (e) {
      state = [];
      loaded = false;
      print('Lỗi load vouchers Supabase: $e');
    } finally {
      loading = false;
    }
  }

  Future<void> refreshVouchers() async {
    if (loading) return;

    loading = true;
    loaded = false;

    try {
      final data = await VoucherService().getVouchers();

      state = data;
      loaded = data.isNotEmpty;
    } catch (e) {
      state = [];
      loaded = false;
      print('Lỗi refresh vouchers Supabase: $e');
    } finally {
      loading = false;
    }
  }

  void reset() {
    state = [];
    loaded = false;
    loading = false;
  }
}

final vouchersProvider =
NotifierProvider<VouchersNotifier, List<Map<String, dynamic>>>(
  VouchersNotifier.new,
);

class PaymentMethod {
  final String id;
  final String type;
  final String title;
  final String subtitle;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
  });
}

class PaymentMethodsNotifier extends Notifier<List<PaymentMethod>> {
  bool loading = false;

  @override
  List<PaymentMethod> build() {
    return [
      PaymentMethod(
        id: 'cash',
        type: 'cash',
        title: 'Tiền mặt',
        subtitle: 'Thanh toán khi nhận hàng',
      ),
    ];
  }

  Future<void> loadPaymentMethods() async {
    if (loading) return;

    loading = true;

    try {
      final data = await PaymentService().getPaymentMethods();

      final methods = data.map((item) {
        return PaymentMethod(
          id: item['id'].toString(),
          type: item['type'].toString(),
          title: item['title'].toString(),
          subtitle: item['subtitle']?.toString() ?? '',
        );
      }).toList();

      state = [
        PaymentMethod(
          id: 'cash',
          type: 'cash',
          title: 'Tiền mặt',
          subtitle: 'Thanh toán khi nhận hàng',
        ),
        ...methods,
      ];
    } catch (e) {
      print('Lỗi load payment methods: $e');
    } finally {
      loading = false;
    }
  }

  Future<void> addWallet(String walletName, String phone) async {
    if (walletName.trim().isEmpty) return;

    final title = walletName;
    final subtitle = phone.trim().isEmpty ? 'Chưa có số điện thoại' : phone;

    try {
      await PaymentService().addPaymentMethod(
        type: 'wallet',
        title: title,
        subtitle: subtitle,
      );

      await loadPaymentMethods();
    } catch (e) {
      print('Lỗi thêm ví điện tử: $e');
    }
  }

  Future<void> addVisa(String cardNumber, String expiry) async {
    final cleanCard = cardNumber.replaceAll(' ', '');
    final last4 = cleanCard.length >= 4
        ? cleanCard.substring(cleanCard.length - 4)
        : cleanCard;

    final title = 'Visa **** $last4';
    final subtitle =
    expiry.trim().isEmpty ? 'Chưa có hạn thẻ' : 'Hết hạn $expiry';

    try {
      await PaymentService().addPaymentMethod(
        type: 'visa',
        title: title,
        subtitle: subtitle,
      );

      await loadPaymentMethods();
    } catch (e) {
      print('Lỗi thêm thẻ Visa: $e');
    }
  }

  Future<void> removeMethod(String id) async {
    if (id == 'cash') return;

    final oldState = [...state];

    state = state.where((method) => method.id != id).toList();

    try {
      await PaymentService().deletePaymentMethod(int.parse(id));
    } catch (e) {
      state = oldState;
      print('Lỗi xoá phương thức thanh toán: $e');
    }
  }

  void clearPaymentMethods() {
    state = [
      PaymentMethod(
        id: 'cash',
        type: 'cash',
        title: 'Tiền mặt',
        subtitle: 'Thanh toán khi nhận hàng',
      ),
    ];
  }
}

final paymentMethodsProvider =
NotifierProvider<PaymentMethodsNotifier, List<PaymentMethod>>(
  PaymentMethodsNotifier.new,
);

class SelectedPaymentNotifier extends Notifier<String> {
  @override
  String build() {
    return 'cash';
  }

  void selectPayment(String paymentId) {
    state = paymentId;
  }

  void clearPayment() {
    state = 'cash';
  }
}

final selectedPaymentProvider =
NotifierProvider<SelectedPaymentNotifier, String>(
  SelectedPaymentNotifier.new,
);


class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    loadTheme();
    return ThemeMode.light;
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(themeKey);

    if (value == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }

  Future<void> setLight() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeKey, 'light');
    state = ThemeMode.light;
  }

  Future<void> setDark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeKey, 'dark');
    state = ThemeMode.dark;
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setLight();
    } else {
      await setDark();
    }
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeModeProvider =
NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class SelectedRankThemeNotifier extends Notifier<String> {
  @override
  String build() {
    return 'default';
  }

  void selectTheme(String theme) {
    state = theme;
  }

  void resetDefault() {
    state = 'default';
  }
}

final selectedRankThemeProvider =
NotifierProvider<SelectedRankThemeNotifier, String>(
  SelectedRankThemeNotifier.new,
);
