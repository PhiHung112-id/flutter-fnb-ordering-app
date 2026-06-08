import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import 'main_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  static const Color brandPrimary = AppColors.orange;
  static const Color brandBackground = AppColors.whiteSoft;
  static const Color brandText = AppColors.black;
  static const Color brandTextSoft = Color(0xFF8D7B68);

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (fullName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mật khẩu phải có ít nhất 6 ký tự'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ref.read(loggedInProvider.notifier).register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      if (!mounted) return;

      Future.microtask(() {
        ref.read(categoriesProvider.notifier).loadCategories();
        ref.read(productsProvider.notifier).loadFromSupabase();
        ref.read(vouchersProvider.notifier).loadVouchers();
        ref.read(bannersProvider.notifier).loadBanners();

        ref.read(ordersProvider.notifier).loadOrdersFromSupabase();
        ref.read(favoritesProvider.notifier).loadFavorites();
        ref.read(savedAddressesProvider.notifier).loadAddresses();
        ref.read(paymentMethodsProvider.notifier).loadPaymentMethods();
        ref.read(customerProfileProvider.notifier).loadProfile();
      });

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainPage(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng ký thất bại: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: brandBackground,
        primaryColor: brandPrimary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandPrimary,
          brightness: Brightness.light,
          primary: brandPrimary,
          secondary: AppColors.orangeSoft,
          surface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: brandBackground,
          foregroundColor: brandText,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(
            color: brandTextSoft,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: brandTextSoft.withOpacity(0.75),
            fontWeight: FontWeight.w500,
          ),
          prefixIconColor: brandPrimary,
          suffixIconColor: brandTextSoft,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: brandPrimary.withOpacity(0.45),
              width: 1.4,
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: brandBackground,
        appBar: AppBar(
          title: Text(
            'Đăng ký tài khoản',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              SizedBox(height: 12),

              Text(
                'Tạo tài khoản Chill Bites',
                style: TextStyle(
                  color: brandText,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Tài khoản giúp bạn lưu địa chỉ, yêu thích, thanh toán và lịch sử đơn hàng.',
                style: TextStyle(
                  color: brandTextSoft,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 28),

              TextField(
                controller: fullNameController,
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  color: brandText,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Họ tên',
                  hintText: 'Nhập họ tên của bạn',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),

              SizedBox(height: 14),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  color: brandText,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  hintText: 'Nhập số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),

              SizedBox(height: 14),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  color: brandText,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Nhập email đăng ký',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              SizedBox(height: 14),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                style: TextStyle(
                  color: brandText,
                  fontWeight: FontWeight.w600,
                ),
                onSubmitted: (_) {
                  if (!isLoading) {
                    register();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  hintText: 'Tối thiểu 6 ký tự',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  'Tạo tài khoản',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}