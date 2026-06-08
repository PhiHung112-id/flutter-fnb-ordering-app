import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/rank_style.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  User? get currentUser => supabase.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  int calculateEarnedPoints(double total) {
    return (total / 10000).floor();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final response = await supabase.auth.signUp(
      email: email.trim(),
      password: password.trim(),
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Không tạo được tài khoản');
    }

    await supabase.from('customers').insert({
      'id': user.id,
      'full_name': fullName.trim(),
      'phone': phone.trim(),
      'avatar_url': null,
      'points': 0,
      'rank': 'Member',
      'rank_discount': 0,
      'is_admin': false,
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> sendResetPasswordEmail(String email) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      throw Exception('Vui lòng nhập email');
    }

    await supabase.auth.resetPasswordForEmail(
      cleanEmail,
      redirectTo: 'io.supabase.chillbites://reset-password',
    );
  }

  Future<void> updateNewPassword(String newPassword) async {
    final password = newPassword.trim();

    if (password.isEmpty) {
      throw Exception('Vui lòng nhập mật khẩu mới');
    }

    if (password.length < 6) {
      throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
    }

    await supabase.auth.updateUser(
      UserAttributes(
        password: password,
      ),
    );
  }

  Future<void> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final password = newPassword.trim();
    final confirm = confirmPassword.trim();

    if (password.isEmpty || confirm.isEmpty) {
      throw Exception('Vui lòng nhập đầy đủ mật khẩu');
    }

    if (password.length < 6) {
      throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
    }

    if (password != confirm) {
      throw Exception('Mật khẩu xác nhận không khớp');
    }

    await updateNewPassword(password);
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;

    if (user == null) return null;

    final data = await supabase
        .from('customers')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }

  Future<String> uploadAvatar({
    required String filePath,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập để đổi ảnh đại diện');
    }

    final extension = filePath.split('.').last;
    final fileName =
        '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

    await supabase.storage.from('avatars').upload(
      fileName,
      File(filePath),
      fileOptions: const FileOptions(
        upsert: true,
      ),
    );

    final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

    final avatarUrl = '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';

    await supabase.from('customers').update({
      'avatar_url': avatarUrl,
    }).eq('id', user.id);

    return avatarUrl;
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập để cập nhật hồ sơ');
    }

    await supabase.from('customers').update({
      'full_name': fullName.trim(),
      'phone': phone.trim(),
    }).eq('id', user.id);
  }

  Future<int> addCustomerPoints(double orderTotal) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập để cộng điểm');
    }

    final earnedPoints = calculateEarnedPoints(orderTotal);

    if (earnedPoints <= 0) {
      return 0;
    }

    final customer = await supabase
        .from('customers')
        .select('points')
        .eq('id', user.id)
        .maybeSingle();

    final currentPoints = (customer?['points'] as num?)?.toInt() ?? 0;
    final newPoints = currentPoints + earnedPoints;

    final newRank = RankHelper.getRankByPoints(newPoints);
    final newDiscount = RankHelper.getDiscountByRank(newRank);

    await supabase.from('customers').update({
      'points': newPoints,
      'rank': newRank,
      'rank_discount': newDiscount,
    }).eq('id', user.id);

    return earnedPoints;
  }

  String getCurrentEmail() {
    return currentUser?.email ?? '';
  }
}