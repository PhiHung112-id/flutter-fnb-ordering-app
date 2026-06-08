import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/app_state.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/rank_membership_card.dart';

class ProfilePage extends ConsumerStatefulWidget {
  ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;
  bool isSaving = false;
  bool initialized = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await loadProfile();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      await ref.read(customerProfileProvider.notifier).loadProfile();

      final profile = ref.read(customerProfileProvider);
      final email = AuthService().getCurrentEmail();

      nameController.text = profile?['full_name']?.toString() ?? '';
      phoneController.text = profile?['phone']?.toString() ?? '';
      emailController.text = email;

      initialized = true;
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải hồ sơ: $e'),
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

  Future<void> changeAvatar() async {
    try {
      final picker = ImagePicker();

      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );

      if (pickedImage == null) return;

      setState(() {
        isSaving = true;
      });

      await AuthService().uploadAvatar(
        filePath: pickedImage.path,
      );

      await ref.read(customerProfileProvider.notifier).loadProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật ảnh đại diện'),
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đổi ảnh đại diện: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> saveProfile() async {
    if (isSaving) return;

    final fullName = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập họ tên'),
        ),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập số điện thoại'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await AuthService().updateProfile(
        fullName: fullName,
        phone: phone,
      );

      await ref.read(customerProfileProvider.notifier).loadProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật hồ sơ'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật hồ sơ: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  String getFirstLetter(String name) {
    final value = name.trim();

    if (value.isEmpty) return 'C';

    return value.substring(0, 1).toUpperCase();
  }

  int getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(customerProfileProvider);

    final rank = profile?['rank']?.toString() ?? 'Member';
    final points = getIntValue(profile?['points'] ?? 0);
    final avatarUrl = profile?['avatar_url']?.toString() ?? '';

    final displayName = nameController.text.trim().isEmpty
        ? 'Khách hàng'
        : nameController.text.trim();

    final email = emailController.text.trim().isEmpty
        ? 'Chưa có email'
        : emailController.text.trim();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Hồ sơ cá nhân',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadProfile,
            icon: Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: isLoading && !initialized
          ? Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      )
          : RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: AppColors.card(context),
        onRefresh: loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            RankMembershipCard(
              fullName: displayName,
              phoneOrEmail: email,
              rank: rank,
              points: points,
              avatarUrl: avatarUrl,
              firstLetter: getFirstLetter(displayName),
              compact: false,
              onAvatarTap: isSaving ? null : changeAvatar,
            ),

            SizedBox(height: 26),

            _ProfileFormCard(
              children: [
                _InputField(
                  label: 'Họ tên',
                  controller: nameController,
                  icon: Icons.person_outline,
                  enabled: !isSaving,
                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                SizedBox(height: 16),

                _InputField(
                  label: 'Email',
                  controller: emailController,
                  icon: Icons.email_outlined,
                  enabled: false,
                  helperText: 'Email đăng nhập không chỉnh tại đây',
                ),

                SizedBox(height: 16),

                _InputField(
                  label: 'Số điện thoại',
                  controller: phoneController,
                  icon: Icons.phone_outlined,
                  enabled: !isSaving,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),

            SizedBox(height: 26),

            ElevatedButton(
              onPressed: isSaving ? null : saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade600,
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: isSaving
                  ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Text(
                'Lưu thay đổi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileFormCard extends StatelessWidget {
  final List<Widget> children;

  _ProfileFormCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;
  final String? helperText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  _InputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.enabled = true,
    this.helperText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = enabled
        ? AppColors.background(context)
        : AppColors.isDark(context)
        ? AppColors.blackSoft
        : Colors.grey.shade100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: enabled
                  ? AppColors.orange
                  : AppColors.textSecondary(context),
            ),
            helperText: helperText,
            helperStyle: TextStyle(
              color: AppColors.textSecondary(context),
            ),
            filled: true,
            fillColor: fillColor,
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.border(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.border(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}