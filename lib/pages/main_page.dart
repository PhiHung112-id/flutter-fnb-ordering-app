import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import 'account_page.dart';
import 'cart_page.dart';
import 'favorite_page.dart';
import 'home_page.dart';
import 'search_page.dart';

class MainPage extends ConsumerStatefulWidget {
  MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    HomePage(),
    SearchPage(),
    CartPage(),
    FavoritePage(),
    AccountPage(),
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(categoriesProvider.notifier).loadCategories();
      ref.read(productsProvider.notifier).loadFromSupabase();
      ref.read(vouchersProvider.notifier).loadVouchers();

      ref.read(favoritesProvider.notifier).loadFavorites();
      ref.read(savedAddressesProvider.notifier).loadAddresses();
      ref.read(paymentMethodsProvider.notifier).loadPaymentMethods();
      ref.read(customerProfileProvider.notifier).loadProfile();
      ref.read(ordersProvider.notifier).loadOrdersFromSupabase();
      ref.read(bannersProvider.notifier).loadBanners();
    });
  }

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartItemsProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    final cartCount = cartItems.fold<int>(
      0,
          (sum, item) => sum + item.qty,
    );

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
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
                  ? Colors.black.withOpacity(0.55)
                  : Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: changePage,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.card(context),
            elevation: 0,
            selectedItemColor: primaryColor,
            unselectedItemColor: AppColors.textSecondary(context),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w900,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
            ),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                activeIcon: Icon(Icons.search_rounded),
                label: 'Tìm món',
              ),
              BottomNavigationBarItem(
                icon: _CartNavIcon(
                  count: cartCount,
                  active: false,
                ),
                activeIcon: _CartNavIcon(
                  count: cartCount,
                  active: true,
                ),
                label: 'Giỏ hàng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border_rounded),
                activeIcon: Icon(Icons.favorite_rounded),
                label: 'Yêu thích',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Tài khoản',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartNavIcon extends StatelessWidget {
  final int count;
  final bool active;

  _CartNavIcon({
    required this.count,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final badgeBorderColor = AppColors.card(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          active ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined,
        ),
        if (count > 0)
          Positioned(
            top: -8,
            right: -10,
            child: Container(
              constraints: BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: active ? primaryColor : AppColors.black,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: badgeBorderColor,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.22),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}