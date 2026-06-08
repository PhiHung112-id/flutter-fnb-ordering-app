import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';

class LocationPage extends ConsumerStatefulWidget {
  LocationPage({super.key});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  final customAddressController = TextEditingController();

  @override
  void dispose() {
    customAddressController.dispose();
    super.dispose();
  }

  void selectLocation(String address) {
    ref.read(deliveryLocationProvider.notifier).updateLocation(address);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã cập nhật vị trí giao hàng'),
        duration: Duration(seconds: 1),
      ),
    );

    Navigator.pop(context);
  }

  void useCurrentLocation() {
    const currentLocation = 'Vị trí hiện tại của bạn, Bình Dương';

    ref.read(deliveryLocationProvider.notifier).updateLocation(currentLocation);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lấy vị trí hiện tại'),
        duration: Duration(seconds: 1),
      ),
    );

    Navigator.pop(context);
  }

  void showCustomAddressDialog() {
    customAddressController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final primary = Theme.of(dialogContext).colorScheme.primary;

        return AlertDialog(
          backgroundColor: AppColors.card(dialogContext),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Nhập địa chỉ mới',
            style: TextStyle(
              color: AppColors.textPrimary(dialogContext),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: customAddressController,
            maxLines: 2,
            style: TextStyle(
              color: AppColors.textPrimary(dialogContext),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Ví dụ: 123 Lê Lợi, Thuận An, Bình Dương',
              hintStyle: TextStyle(
                color: AppColors.textSecondary(dialogContext),
              ),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: primary,
              ),
              filled: true,
              fillColor: AppColors.background(dialogContext),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.border(dialogContext),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: AppColors.textSecondary(dialogContext),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient(dialogContext),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.20),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  final address = customAddressController.text.trim();

                  if (address.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Vui lòng nhập địa chỉ'),
                      ),
                    );
                    return;
                  }

                  ref.read(savedAddressesProvider.notifier).addAddress(address);
                  ref
                      .read(deliveryLocationProvider.notifier)
                      .updateLocation(address);

                  Navigator.pop(dialogContext);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm và chọn địa chỉ mới'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Lưu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocation = ref.watch(deliveryLocationProvider);
    final locations = ref.watch(savedAddressesProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Cập nhật vị trí',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LocationHeader(),

          SizedBox(height: 18),

          _LocationActionItem(
            icon: Icons.my_location,
            title: 'Dùng vị trí hiện tại',
            subtitle: 'Tự động lấy vị trí gần đúng của bạn',
            onTap: useCurrentLocation,
          ),

          SizedBox(height: 12),

          _LocationActionItem(
            icon: Icons.add_location_alt_outlined,
            title: 'Nhập địa chỉ mới',
            subtitle: 'Thêm địa chỉ giao hàng thủ công',
            onTap: showCustomAddressDialog,
          ),

          SizedBox(height: 22),

          Row(
            children: [
              Text(
                'Địa chỉ đã lưu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(
                    AppColors.isDark(context) ? 0.20 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primary.withOpacity(0.25),
                  ),
                ),
                child: Text(
                  '${locations.length} địa chỉ',
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          if (locations.isEmpty)
            _EmptyAddress()
          else
            ...locations.map((address) {
              final isSelected = selectedLocation == address;

              return _SavedAddressItem(
                address: address,
                isSelected: isSelected,
                onTap: () => selectLocation(address),
              );
            }),
        ],
      ),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  _LocationHeader();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(
              AppColors.isDark(context) ? 0.28 : 0.22,
            ),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient(context),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.22),
                ),
              ),
              child: Icon(
                Icons.location_on,
                color: Colors.white,
                size: 40,
              ),
            ),

            SizedBox(width: 14),

            Expanded(
              child: Text(
                'Chọn vị trí giao hàng để Chill Bites phục vụ bạn nhanh hơn.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _LocationActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border(context),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primary.withOpacity(
                AppColors.isDark(context) ? 0.22 : 0.13,
              ),
              child: Icon(
                icon,
                color: primary,
              ),
            ),

            SizedBox(width: 12),

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
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedAddressItem extends StatelessWidget {
  final String address;
  final bool isSelected;
  final VoidCallback onTap;

  _SavedAddressItem({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : AppColors.border(context),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primary.withOpacity(0.13)
                  : AppColors.shadow(context),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isSelected
                  ? primary
                  : primary.withOpacity(
                AppColors.isDark(context) ? 0.22 : 0.13,
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: isSelected ? Colors.white : primary,
              ),
            ),

            SizedBox(width: 12),

            Expanded(
              child: Text(
                address,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                  height: 1.35,
                ),
              ),
            ),

            if (isSelected)
              Icon(
                Icons.check_circle,
                color: primary,
              )
            else
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary(context),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAddress extends StatelessWidget {
  _EmptyAddress();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(28),
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
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.22),
                  blurRadius: 16,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Icon(
              Icons.location_off_outlined,
              color: Colors.white,
              size: 46,
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Chưa có địa chỉ đã lưu',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Bạn có thể nhập địa chỉ mới để lưu và dùng cho các lần đặt hàng sau.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}