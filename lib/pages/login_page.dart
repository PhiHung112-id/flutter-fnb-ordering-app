import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import 'main_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  static const Color brandPrimary = AppColors.orange;
  static const Color brandPrimaryDark = AppColors.orangeDark;
  static const Color brandPrimaryLight = AppColors.orangeLight;
  static const Color brandPrimarySoft = AppColors.orangeSoft;
  static const Color brandBackground = AppColors.whiteSoft;
  static const Color brandText = AppColors.black;
  static const Color brandTextSoft = Color(0xFF8D7B68);
  static const Color brandBorder = Color(0xFFFFEFE1);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập email và mật khẩu'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ref.read(loggedInProvider.notifier).login(
        email: email,
        password: password,
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
        ref.read(customerProfileProvider.notifier).loadProfile();
        ref.read(paymentMethodsProvider.notifier).loadPaymentMethods();
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
          content: Text('Đăng nhập thất bại: $e'),
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
      // Theme riêng cho LoginPage để KHÔNG bị đổi theo rank theme bên ngoài.
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: brandBackground,
        primaryColor: brandPrimary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandPrimary,
          brightness: Brightness.light,
          primary: brandPrimary,
          secondary: brandPrimarySoft,
          surface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: brandBackground,
          foregroundColor: brandText,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: brandBackground,
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
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -80,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: brandPrimary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                bottom: -90,
                left: -70,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    color: brandPrimarySoft.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                top: 120,
                left: -55,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: brandPrimaryLight.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              ListView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: brandText,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  Center(
                    child: AppLogo(
                      size: 82,
                      showText: true,
                    ),
                  ),

                  SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          brandPrimarySoft,
                          brandPrimary.withOpacity(0.45),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(31),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.045),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: brandBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đăng nhập',
                            style: TextStyle(
                              color: brandText,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Đăng nhập để đặt món, lưu yêu thích và theo dõi đơn hàng của bạn.',
                            style: TextStyle(
                              color: brandTextSoft,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(height: 24),

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
                              hintText: 'Nhập email của bạn',
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
                                login();
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              hintText: 'Nhập mật khẩu',
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

                          SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Quên mật khẩu?',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 12),

                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  brandPrimaryLight,
                                  brandPrimary,
                                  brandPrimaryDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: brandPrimary.withOpacity(0.22),
                                  blurRadius: 12,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.transparent,
                                disabledForegroundColor: Colors.white70,
                                shadowColor: Colors.transparent,
                                elevation: 0,
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
                                'Đăng nhập',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản?',
                        style: TextStyle(
                          color: brandTextSoft,
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: brandPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Center(
                    child: Text(
                      'Chill Bites • Food & Drink Ordering',
                      style: TextStyle(
                        color: brandTextSoft,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}