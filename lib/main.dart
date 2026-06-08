import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/reset_password_page.dart';
import 'pages/splash_page.dart';
import 'providers/app_state.dart';
import 'utils/app_colors.dart';
import 'utils/app_globals.dart';
import 'pages/reset_password_page.dart';

Future<void> openResetPasswordPage() async {
  isPasswordRecoveryMode = true;

  await Future.delayed(const Duration(milliseconds: 600));

  final navigator = navigatorKey.currentState;

  if (navigator == null) {
    debugPrint('Navigator chưa sẵn sàng');
    return;
  }

  navigator.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const ResetPasswordPage(),
    ),
        (route) => false,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;

    debugPrint('AUTH EVENT: $event');

    if (event == AuthChangeEvent.passwordRecovery) {
      isPasswordRecoveryMode = true;

      Future.delayed(const Duration(milliseconds: 600), () {
        final navigator = navigatorKey.currentState;

        if (navigator == null) {
          debugPrint('Navigator chưa sẵn sàng');
          return;
        }

        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const ResetPasswordPage(),
          ),
              (route) => false,
        );
      });
    }
  });

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: ChillBitesApp(),
    ),
  );
}

class ChillBitesApp extends ConsumerWidget {
  const ChillBitesApp({super.key});

  int getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  int getRequiredPoints(String theme) {
    switch (theme.toLowerCase()) {
      case 'diamond':
        return 2000;
      case 'gold':
        return 1000;
      case 'silver':
        return 500;
      default:
        return 0;
    }
  }

  String getEffectiveTheme({
    required String selectedTheme,
    required int points,
  }) {
    if (selectedTheme == 'default') {
      return 'default';
    }

    final requiredPoints = getRequiredPoints(selectedTheme);

    if (points >= requiredPoints) {
      return selectedTheme;
    }

    return 'default';
  }

  Color getPrimaryColorByTheme(String theme) {
    switch (theme.toLowerCase()) {
      case 'diamond':
        return const Color(0xFF38BDF8);
      case 'gold':
        return const Color(0xFFFFC107);
      case 'silver':
        return const Color(0xFF94A3B8);
      default:
        return AppColors.orange;
    }
  }

  Color getSecondaryColorByTheme(String theme) {
    switch (theme.toLowerCase()) {
      case 'diamond':
        return const Color(0xFFDBEAFE);
      case 'gold':
        return const Color(0xFFFFF3C4);
      case 'silver':
        return const Color(0xFFE2E8F0);
      default:
        return AppColors.orangeSoft;
    }
  }

  Color getLightBackgroundByTheme(String theme) {
    switch (theme.toLowerCase()) {
      case 'diamond':
        return const Color(0xFFF0F9FF);
      case 'gold':
        return const Color(0xFFFFFBEB);
      case 'silver':
        return const Color(0xFFF8FAFC);
      default:
        return AppColors.whiteSoft;
    }
  }

  ThemeData buildLightTheme(String theme) {
    final primary = getPrimaryColorByTheme(theme);
    final secondary = getSecondaryColorByTheme(theme);
    final background = getLightBackgroundByTheme(theme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        surface: AppColors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: AppColors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF8D7B68),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withOpacity(0.35);
          }
          return null;
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  ThemeData buildDarkTheme(String theme) {
    final primary = getPrimaryColorByTheme(theme);
    final secondary = getSecondaryColorByTheme(theme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.black,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        surface: AppColors.blackCard,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.blackCard,
        selectedItemColor: primary,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withOpacity(0.35);
          }
          return null;
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final selectedRankTheme = ref.watch(selectedRankThemeProvider);
    final profile = ref.watch(customerProfileProvider);

    final points = getIntValue(profile?['points']);

    final effectiveTheme = getEffectiveTheme(
      selectedTheme: selectedRankTheme,
      points: points,
    );

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Chill Bites',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: buildLightTheme(effectiveTheme),
      darkTheme: buildDarkTheme(effectiveTheme),
      home: SplashPage(),
    );
  }
}
