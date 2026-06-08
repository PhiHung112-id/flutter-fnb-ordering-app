import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';

class AddressPage extends ConsumerStatefulWidget {
  AddressPage({super.key});

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage> {
  final addressController = TextEditingController();

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  void showAddAddressDialog() {
    addressController.clear();

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
            'Thêm địa chỉ mới',
            style: TextStyle(
              color: AppColors.textPrimary(dialogContext),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: addressController,
            maxLines: 3,
            style: TextStyle(
              color: AppColors.textPrimary(dialogContext),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập địa chỉ giao hàng...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary(dialogContext),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 42),
                child: Icon(
                  Icons.location_on_outlined,
                  color: primary,
                ),
              ),
              filled: true,
              fillColor: AppColors.background(dialogContext),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.border(dialogContext),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
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
                  final address = addressController.text.trim();

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

  void selectAddress(String address) {
    ref.read(deliveryLocationProvider.notifier).updateLocation(address);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã cập nhật địa chỉ giao hàng'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void confirmDeleteAddress(String address) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card(dialogContext),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Xóa địa chỉ',
            style: TextStyle(
              color: AppColors.textPrimary(dialogContext),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Bạn có chắc muốn xóa địa chỉ này không?',
            style: TextStyle(
              color: AppColors.textSecondary(dialogContext),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Không',
                style: TextStyle(
                  color: AppColors.textSecondary(dialogContext),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(savedAddressesProvider.notifier).removeAddress(address);

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa địa chỉ'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(savedAddressesProvider);
    final selectedAddress = ref.watch(deliveryLocationProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Địa chỉ giao hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: showAddAddressDialog,
            icon: Icon(
              Icons.add_location_alt_outlined,
              color: primary,
              size: 18,
            ),
            label: Text(
              'Thêm',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AddressHeader(),

          SizedBox(height: 20),

          Row(
            children: [
              Text(
                'Địa chỉ đã lưu',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
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
                  '${addresses.length} địa chỉ',
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

          if (addresses.isEmpty)
            _EmptyAddress()
          else
            ...addresses.map((address) {
              final isSelected = selectedAddress == address;

              return _AddressItem(
                address: address,
                isSelected: isSelected,
                onSelect: () => selectAddress(address),
                onDelete: () => confirmDeleteAddress(address),
              );
            }),

          SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.22),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: showAddAddressDialog,
              icon: Icon(Icons.add_location_alt_outlined),
              label: Text('Thêm địa chỉ mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                elevation: 0,
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressHeader extends StatelessWidget {
  _AddressHeader();

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
                'Chọn địa chỉ giao hàng mặc định để đặt món nhanh hơn.',
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

class _AddressItem extends StatelessWidget {
  final String address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  _AddressItem({
    required this.address,
    required this.isSelected,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? primary : AppColors.border(context),
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primary.withOpacity(0.14)
                : AppColors.shadow(context),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Radio<String>(
            value: address,
            groupValue: isSelected ? address : null,
            activeColor: primary,
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return primary;
              }

              return AppColors.textSecondary(context);
            }),
            onChanged: (_) => onSelect(),
          ),

          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onSelect,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSelected ? 'Địa chỉ mặc định' : 'Địa chỉ giao hàng',
                      style: TextStyle(
                        color: isSelected
                            ? primary
                            : AppColors.textPrimary(context),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      address,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
          ),
        ],
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
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(
                    AppColors.isDark(context) ? 0.24 : 0.20,
                  ),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.location_off_outlined,
              color: Colors.white,
              size: 48,
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Chưa có địa chỉ nào',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Thêm địa chỉ giao hàng để đặt món nhanh hơn trong những lần sau.',
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