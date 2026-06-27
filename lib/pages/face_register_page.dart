import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/app_state.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class FaceRegisterPage extends ConsumerStatefulWidget {
  FaceRegisterPage({super.key});

  @override
  ConsumerState<FaceRegisterPage> createState() => _FaceRegisterPageState();
}

class _FaceRegisterPageState extends ConsumerState<FaceRegisterPage> {
  final ImagePicker picker = ImagePicker();

  bool isLoading = true;
  bool isSaving = false;
  XFile? selectedImage;
  String faceImageUrl = '';
  String registeredAt = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(loadFaceInfo);
  }

  Future<void> loadFaceInfo() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await AuthService().getFaceRegistration();

      if (!mounted) return;

      setState(() {
        faceImageUrl = data?['face_image_url']?.toString() ?? '';
        registeredAt = data?['face_registered_at']?.toString() ?? '';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        faceImageUrl = '';
        registeredAt = '';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> captureFace() async {
    if (isSaving) return;

    try {
      final image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 90,
        maxWidth: 1200,
      );

      if (image == null) return;

      setState(() {
        selectedImage = image;
      });
    } catch (e) {
      showMessage('Không mở được camera: $e');
    }
  }

  Future<void> pickFaceFromGallery() async {
    if (isSaving) return;

    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1200,
      );

      if (image == null) return;

      setState(() {
        selectedImage = image;
      });
    } catch (e) {
      showMessage('Không chọn được ảnh: $e');
    }
  }

  Future<void> saveFace() async {
    final image = selectedImage;

    if (image == null) {
      showMessage('Hãy chụp khuôn mặt trước khi lưu');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await AuthService().registerFace(
        filePath: image.path,
      );

      await ref.read(customerProfileProvider.notifier).loadProfile();
      await loadFaceInfo();

      if (!mounted) return;

      setState(() {
        selectedImage = null;
      });

      showMessage('Đã đăng ký khuôn mặt');
    } catch (e) {
      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> deleteFace() async {
    if (isSaving) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card(dialogContext),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Xóa khuôn mặt',
            style: TextStyle(
              color: AppColors.textPrimary(dialogContext),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Bạn có chắc muốn xóa dữ liệu khuôn mặt đã đăng ký không?',
            style: TextStyle(
              color: AppColors.textSecondary(dialogContext),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Không',
                style: TextStyle(
                  color: AppColors.textSecondary(dialogContext),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Xóa',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      isSaving = true;
    });

    try {
      await AuthService().deleteRegisteredFace();
      await ref.read(customerProfileProvider.notifier).loadProfile();
      await loadFaceInfo();

      if (!mounted) return;

      setState(() {
        selectedImage = null;
      });

      showMessage('Đã xóa khuôn mặt');
    } catch (e) {
      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String get dateText {
    if (registeredAt.trim().isEmpty) return '';

    final date = DateTime.tryParse(registeredAt)?.toLocal();

    if (date == null) return registeredAt;

    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(date.hour)}:${two(date.minute)} • ${two(date.day)}/${two(date.month)}/${date.year}';
  }

  Widget buildPreview(BuildContext context) {
    final selected = selectedImage;

    Widget child;

    if (selected != null) {
      child = Image.file(
        File(selected.path),
        fit: BoxFit.cover,
      );
    } else if (faceImageUrl.trim().isNotEmpty) {
      child = Image.network(
        faceImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Icon(
            Icons.face_retouching_off_outlined,
            size: 70,
            color: AppColors.textSecondary(context),
          );
        },
      );
    } else {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.face_retouching_natural_rounded,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 10),
          Text(
            'Chưa đăng ký khuôn mặt',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Chụp rõ mặt, đủ sáng, nhìn thẳng camera',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.border(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFace = faceImageUrl.trim().isNotEmpty;
    final hasSelectedImage = selectedImage != null;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Đăng ký khuôn mặt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: isSaving ? null : loadFaceInfo,
            icon: Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoCard(
            icon: hasFace
                ? Icons.verified_user_rounded
                : Icons.face_retouching_natural_rounded,
            title: hasFace
                ? 'Khuôn mặt đã được đăng ký'
                : 'Đăng ký khuôn mặt để xác thực nhanh',
            subtitle: hasFace && dateText.isNotEmpty
                ? 'Cập nhật lần cuối: $dateText'
                : 'Dữ liệu khuôn mặt được lưu với tài khoản của bạn.',
          ),

          SizedBox(height: 18),

          buildPreview(context),

          SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : captureFace,
                  icon: Icon(Icons.photo_camera_rounded),
                  label: Text(hasFace ? 'Chụp lại' : 'Chụp khuôn mặt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade600,
                    minimumSize: Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSaving ? null : pickFaceFromGallery,
                  icon: Icon(Icons.photo_library_outlined),
                  label: Text('Chọn ảnh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    minimumSize: Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              gradient: hasSelectedImage
                  ? AppColors.primaryGradient(context)
                  : null,
              color: hasSelectedImage ? null : AppColors.card(context),
              borderRadius: BorderRadius.circular(16),
              border: hasSelectedImage
                  ? null
                  : Border.all(color: AppColors.border(context)),
            ),
            child: ElevatedButton.icon(
              onPressed: isSaving || !hasSelectedImage ? null : saveFace,
              icon: isSaving
                  ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
                  : Icon(Icons.save_rounded),
              label: Text(
                isSaving ? 'Đang lưu...' : 'Lưu đăng ký khuôn mặt',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                disabledForegroundColor: AppColors.textSecondary(context),
                shadowColor: Colors.transparent,
                elevation: 0,
                minimumSize: Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          if (hasFace) ...[
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isSaving ? null : deleteFace,
              icon: Icon(Icons.delete_outline_rounded),
              label: Text('Xóa khuôn mặt đã đăng ký'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                minimumSize: Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],

          SizedBox(height: 18),

          _TipCard(),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: primary.withOpacity(
              AppColors.isDark(context) ? 0.20 : 0.12,
            ),
            child: Icon(
              icon,
              color: primary,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mẹo chụp khuôn mặt',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          _TipLine(text: 'Đưa mặt vào giữa khung hình'),
          _TipLine(text: 'Không đội nón, không đeo khẩu trang'),
          _TipLine(text: 'Chụp nơi đủ sáng để nhận diện tốt hơn'),
        ],
      ),
    );
  }
}

class _TipLine extends StatelessWidget {
  final String text;

  _TipLine({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
