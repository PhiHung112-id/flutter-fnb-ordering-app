import 'package:flutter/material.dart';

import '../utils/app_globals.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'splash_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> updatePassword() async {
    if (loading) return;

    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      showMessage('Vui lòng nhập đầy đủ mật khẩu');
      return;
    }

    if (password.length < 6) {
      showMessage('Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Mật khẩu xác nhận không khớp');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await AuthService().updateNewPassword(password);

      isPasswordRecoveryMode = false;

      await AuthService().signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công. Vui lòng đăng nhập lại.'),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => SplashPage(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      showMessage('Lỗi đổi mật khẩu: $e');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Đổi mật khẩu mới',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),

            Center(
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  color: primary,
                  size: 44,
                ),
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'Tạo mật khẩu mới',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Nhập mật khẩu mới cho tài khoản của bạn. Sau khi cập nhật thành công, bạn cần đăng nhập lại.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: passwordController,
              obscureText: hidePassword,
              enabled: !loading,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                hintText: 'Nhập mật khẩu mới',
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: primary,
                ),
                suffixIcon: IconButton(
                  onPressed: loading
                      ? null
                      : () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                filled: true,
                fillColor: AppColors.card(context),
                labelStyle: TextStyle(
                  color: AppColors.textSecondary(context),
                ),
                hintStyle: TextStyle(
                  color: AppColors.textSecondary(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.border(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: primary,
                    width: 1.5,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.border(context),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: confirmPasswordController,
              obscureText: hideConfirmPassword,
              enabled: !loading,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Nhập lại mật khẩu',
                hintText: 'Nhập lại mật khẩu mới',
                prefixIcon: Icon(
                  Icons.lock_reset_rounded,
                  color: primary,
                ),
                suffixIcon: IconButton(
                  onPressed: loading
                      ? null
                      : () {
                    setState(() {
                      hideConfirmPassword = !hideConfirmPassword;
                    });
                  },
                  icon: Icon(
                    hideConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                filled: true,
                fillColor: AppColors.card(context),
                labelStyle: TextStyle(
                  color: AppColors.textSecondary(context),
                ),
                hintStyle: TextStyle(
                  color: AppColors.textSecondary(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.border(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: primary,
                    width: 1.5,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.border(context),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 26),

            Container(
              decoration: BoxDecoration(
                gradient: loading ? null : AppColors.primaryGradient(context),
                color: loading ? Colors.grey : null,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  if (!loading)
                    BoxShadow(
                      color: primary.withOpacity(0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: ElevatedButton(
                onPressed: loading ? null : updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.white70,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Text(
                  'Cập nhật mật khẩu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Không tắt ứng dụng trong lúc cập nhật mật khẩu.',
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
    );
  }
}