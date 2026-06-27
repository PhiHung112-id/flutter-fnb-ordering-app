import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_client.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  User? get currentUser => supabase.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

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

    await ApiClient.post(
      '/api/customers/upsert',
      body: {
        'id': user.id,
        'email': email.trim(),
        'fullName': fullName.trim(),
        'phone': phone.trim(),
      },
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = currentUser;
    if (user != null) {
      await ApiClient.post(
        '/api/customers/upsert',
        body: {
          'id': user.id,
          'email': user.email ?? email.trim(),
          'fullName': user.userMetadata?['full_name']?.toString() ?? '',
          'phone': user.phone ?? '',
        },
      );
    }
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

    if (user == null) {
      return null;
    }

    final profile = await ApiClient.getMap('/api/customers/${user.id}/profile');

    if (profile == null) return null;

    profile['email'] = profile['email']?.toString().trim().isNotEmpty == true
        ? profile['email']
        : user.email ?? '';

    return profile;
  }

  int getIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
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

    await ApiClient.patch(
      '/api/customers/${user.id}/profile',
      body: {
        'avatarUrl': avatarUrl,
      },
    );

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

    await ApiClient.patch(
      '/api/customers/${user.id}/profile',
      body: {
        'fullName': fullName.trim(),
        'phone': phone.trim(),
      },
    );
  }

  Future<Map<String, dynamic>?> getFaceRegistration() async {
    final user = currentUser;

    if (user == null) {
      return null;
    }

    return ApiClient.getMap('/api/customers/${user.id}/face');
  }

  Future<String> registerFace({
    required String filePath,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập để đăng ký khuôn mặt');
    }

    final extension = filePath.split('.').last.toLowerCase();
    final safeExtension = extension.isEmpty ? 'jpg' : extension;
    final fileName =
        '${user.id}/face_${DateTime.now().millisecondsSinceEpoch}.$safeExtension';

    await supabase.storage.from('avatars').upload(
      fileName,
      File(filePath),
      fileOptions: const FileOptions(
        upsert: true,
      ),
    );

    final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
    final faceUrl = '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';

    await ApiClient.post(
      '/api/customers/${user.id}/face',
      body: {
        'faceImageUrl': faceUrl,
        'captureType': 'front',
        'method': 'camera',
      },
    );

    return faceUrl;
  }

  Future<void> deleteRegisteredFace() async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập để xóa khuôn mặt');
    }

    await ApiClient.delete('/api/customers/${user.id}/face');
  }

  String getCurrentEmail() {
    return currentUser?.email ?? '';
  }
}
