// 常用地址区域 - 对齐 Android bus/ui/AddressSection.kt
// 保留统一的地址选择与导航行为，布局按设计稿改为纵向三行
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../router/route_names.dart';
import '../models/address_info.dart';
import '../viewmodels/address_view_model.dart';

/// 首页常用地址区域 - 对齐 Android AddressSection
/// 保留统一的地址选择与导航行为，布局按设计稿改为纵向三行
class AddressSection extends ConsumerWidget {
  const AddressSection({
    super.key,
    required this.currentCity,
  });

  /// 当前城市（用于 BusSearch 选址页）
  final String currentCity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressViewModelProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          AddressRow(
            title: '家',
            iconPath: AppAssets.jbcxAddressHome,
            addressInfo: addressState.homeAddress,
            currentCity: currentCity,
            addressType: AddressType.home,
          ),
          Divider(color: AppColors.jbcxAddressDivider, height: 1),
          AddressRow(
            title: '公司',
            iconPath: AppAssets.jbcxAddressCompany,
            addressInfo: addressState.companyAddress,
            currentCity: currentCity,
            addressType: AddressType.company,
          ),
          Divider(color: AppColors.jbcxAddressDivider, height: 1),
          AddressRow(
            title: '学校',
            iconPath: AppAssets.jbcxAddressSchool,
            addressInfo: addressState.schoolAddress,
            currentCity: currentCity,
            addressType: AddressType.school,
          ),
        ],
      ),
    );
  }
}

/// 单个地址行 - 对齐 Android AddressRow
class AddressRow extends ConsumerWidget {
  const AddressRow({
    super.key,
    required this.title,
    required this.iconPath,
    required this.addressInfo,
    required this.currentCity,
    required this.addressType,
  });

  final String title;
  final String iconPath;
  final AddressInfo? addressInfo;
  final String currentCity;
  final AddressType addressType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAddress = addressInfo?.destinationName.isNotEmpty == true;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onRowTapped(context, ref, hasAddress),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Image.asset(iconPath, width: 50, height: 50),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.jbcxText,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hasAddress)
                    Text(
                      addressInfo?.destinationName ?? '',
                      style: const TextStyle(
                        color: AppColors.jbcxAddressSubText,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _onRowTapped(context, ref, hasAddress),
              child: Container(
                width: 98,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.jbcxAccent,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  hasAddress ? '路线导航' : '点击添加',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 行点击行为 - 对齐 Android AddressRow 的 onAddressClick / onAddClick
  Future<void> _onRowTapped(
    BuildContext context,
    WidgetRef ref,
    bool hasAddress,
  ) async {
    if (hasAddress) {
      // 已有地址，跳转路线导航 - 对齐 Android AddressSection.navigate
      // BusRouteActivity.start(context, destinationLatitude, ..., useMyLocation = true)
      GoRouter.of(context).push(
        RoutePaths.busRoute,
        extra: {
          'destination_latitude': addressInfo?.destinationLatitude ?? 0.0,
          'destination_longitude': addressInfo?.destinationLongitude ?? 0.0,
          'destination_name': addressInfo?.destinationName ?? '',
          'use_my_location': true,
          'transport_mode': -1,
        },
      );
    } else {
      // 无地址，跳转搜索选址 - 对齐 Android AddressSection.launchPicker
      final result = await GoRouter.of(context).push<Map<String, dynamic>>(
        RoutePaths.busSearch,
        extra: {
          'is_from_location': false,
          'current_city': currentCity,
          'address_type': addressType.name,
        },
      );

      // 对齐 Android AddressActivity.onActivityResult：接收选址页回传结果后保存。
      final name = result?['location_name'] as String? ?? '';
      final latitude = (result?['latitude'] as num?)?.toDouble();
      final longitude = (result?['longitude'] as num?)?.toDouble();
      if (name.trim().isEmpty || latitude == null || longitude == null) return;

      await ref.read(addressViewModelProvider.notifier).setAddress(
            addressType,
            AddressInfo(
              destinationLatitude: latitude,
              destinationLongitude: longitude,
              destinationName: name,
            ),
          );
    }
  }
}
