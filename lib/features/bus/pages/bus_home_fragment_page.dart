// 畅行首页 - 迁移 Android RoutenquiryFragment.kt。
// 页面仅负责组合 UI；定位、地址、VR 数据分别由既有或独立 ViewModel 提供。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../router/route_names.dart';
import '../models/address_info.dart';
import '../models/vr_scene.dart';
import '../repositories/baidu_location_repository.dart';
import '../viewmodels/address_view_model.dart';
import '../viewmodels/common_location_view_model.dart';
import '../viewmodels/vr_scene_view_model.dart';
import '../widgets/location_permission_content.dart';

/// 畅行首页 - 对齐 Android RoutenquiryFragment.ScreenContent。
class BusHomeFragmentPage extends ConsumerStatefulWidget {
  const BusHomeFragmentPage({super.key});

  @override
  ConsumerState<BusHomeFragmentPage> createState() =>
      _BusHomeFragmentPageState();
}

class _BusHomeFragmentPageState extends ConsumerState<BusHomeFragmentPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshPageState());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 对齐 Android onResume：从选址页或系统设置返回时刷新权限和地址。
    if (state == AppLifecycleState.resumed) _refreshPageState();
  }

  Future<void> _refreshPageState() async {
    await ref
        .read(commonLocationViewModelProvider.notifier)
        .checkLocationPermission();
    await ref.read(addressViewModelProvider.notifier).reload();
  }

  Future<void> _requestLocationPermission() async {
    final granted = await BaiduLocationRepository().requestLocationPermission();
    if (!mounted || !granted) return;
    await ref
        .read(commonLocationViewModelProvider.notifier)
        .checkLocationPermission();
    await ref
        .read(commonLocationViewModelProvider.notifier)
        .getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(commonLocationViewModelProvider);
    if (!locationState.hasLocationPermission) {
      return LocationPermissionContent(
        subtitle: '用于查看附近功能信息及使用\n路线规划等功能',
        onRequestPermission: _requestLocationPermission,
      );
    }

    if (!locationState.isLocating && locationState.currentCity == '定位中') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(commonLocationViewModelProvider.notifier).getCurrentLocation();
      });
    }
    return _RouteEnquiryContent(
      currentCity:
          locationState.currentCity.isEmpty ? '北京' : locationState.currentCity,
    );
  }
}

class _RouteEnquiryContent extends StatelessWidget {
  const _RouteEnquiryContent({required this.currentCity});

  final String currentCity;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: _TopGradientSection(currentCity: currentCity)),
          const SliverToBoxAdapter(child: _SectionTitle(title: '常用地址')),
          SliverToBoxAdapter(
              child: _AddressCardsSection(currentCity: currentCity)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _NearbyFunctionCard(
              iconPath: AppAssets.toolboxNearbyToilet,
              title: '附近商场',
              subtitle: '实时查找周边商场便捷出行',
              onTap: () => _openNearbySearch(context, '商场'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(
            child: _NearbyFunctionCard(
              iconPath: AppAssets.toolboxNearbyMall,
              title: '附近卫生间',
              subtitle: '就近寻厕便捷无忧',
              onTap: () => _openNearbySearch(context, '卫生间'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _openNearbySearch(BuildContext context, String keyword) {
    context.push(RoutePaths.busMapSearch, extra: {'search_keyword': keyword});
  }
}

/// Android TopGradientSection：搜索、路线类型和 VR 实景。
class _TopGradientSection extends StatelessWidget {
  const _TopGradientSection({required this.currentCity});

  final String currentCity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.routeEnquiryBlue, Colors.white],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _SearchBox(currentCity: currentCity),
              const SizedBox(height: 28),
              const _RouteTypeButtons(),
              const SizedBox(height: 24),
              const Text(
                'VR实景',
                style: TextStyle(
                  color: AppColors.routeEnquiryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const _VrSceneList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.currentCity});
  final String currentCity;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => context.push(
          RoutePaths.busSearch,
          extra: {'current_city': currentCity},
        ),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '搜线路、站点、目的地',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 14),
                ),
              ),
              Container(
                width: 52,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.routeEnquirySearchButton,
                  borderRadius: BorderRadius.circular(99),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  AppAssets.toolboxRouteSearch,
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteTypeButtons extends StatelessWidget {
  const _RouteTypeButtons();

  @override
  Widget build(BuildContext context) {
    const items = [
      _RouteTypeItem('驾车路线', AppAssets.toolboxRouteCar, 1),
      _RouteTypeItem('公交路线', AppAssets.toolboxRouteBus, 0),
      _RouteTypeItem('骑行路线', AppAssets.toolboxRouteBike, 2),
      _RouteTypeItem('步行路线', AppAssets.toolboxRouteWalk, 3),
    ];
    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(child: _RouteTypeButton(item: items[index])),
          if (index != items.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _RouteTypeItem {
  const _RouteTypeItem(this.title, this.iconPath, this.mode);
  final String title;
  final String iconPath;
  final int mode;
}

class _RouteTypeButton extends StatelessWidget {
  const _RouteTypeButton({required this.item});
  final _RouteTypeItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.push(
          RoutePaths.mapRoute,
          extra: {'transport_mode': item.mode, 'skip_initial_location': true},
        ),
        child: Ink(
          height: 78,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.routeEnquiryButtonTop,
                AppColors.routeEnquiryButtonBottom,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(item.iconPath,
                  width: 48, height: 42, fit: BoxFit.contain),
              const SizedBox(height: 6),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VrSceneList extends ConsumerWidget {
  const _VrSceneList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(vrSceneViewModelProvider);
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: scenes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _VrSceneCard(scene: scenes[index], colorIndex: index % 3),
      ),
    );
  }
}

class _VrSceneCard extends StatelessWidget {
  const _VrSceneCard({required this.scene, required this.colorIndex});
  final VrScene scene;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    const barColors = [
      AppColors.routeEnquiryVrBarPink,
      AppColors.routeEnquiryVrBarTeal,
      AppColors.routeEnquiryVrBarBlue,
    ];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => context.push(
          RoutePaths.vrWebView,
          extra: {'title': scene.title, 'url': scene.url},
        ),
        child: Ink(
          width: 126,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(scene.imageAsset, fit: BoxFit.cover),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      scene.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 38,
                    color: barColors[colorIndex],
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 9, right: 6),
                    child: Text(
                      scene.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 20, top: 24, bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.routeEnquiryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _AddressCardsSection extends ConsumerWidget {
  const _AddressCardsSection({required this.currentCity});
  final String currentCity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressViewModelProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _AddressCard(
              title: '家',
              iconPath: AppAssets.toolboxAddressHome,
              address: addresses.homeAddress,
              type: AddressType.home,
              currentCity: currentCity,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: _AddressCard(
              title: '公司',
              iconPath: AppAssets.toolboxAddressCompany,
              address: addresses.companyAddress,
              type: AddressType.company,
              currentCity: currentCity,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: _AddressCard(
              title: '学校',
              iconPath: AppAssets.toolboxAddressSchool,
              address: addresses.schoolAddress,
              type: AddressType.school,
              currentCity: currentCity,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends ConsumerWidget {
  const _AddressCard({
    required this.title,
    required this.iconPath,
    required this.address,
    required this.type,
    required this.currentCity,
  });

  final String title;
  final String iconPath;
  final AddressInfo? address;
  final AddressType type;
  final String currentCity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAddress = address?.destinationName.isNotEmpty == true;
    return Padding(
      // 给扩散阴影留出绘制空间，但不改变三张卡片的列宽。
      padding: const EdgeInsets.only(top: 3, bottom: 5),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // 阴影由外层绘制，确保四条边都能清晰显示。
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 3,
              spreadRadius: 0.5,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _onTap(context, ref, hasAddress),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 8,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF3C3C3C),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Image.asset(iconPath, width: 38, height: 38),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (hasAddress)
                    Text(
                      address!.destinationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF3C3C3C),
                        fontSize: 10,
                      ),
                    )
                  else
                    Image.asset(
                      AppAssets.toolboxAddressBar,
                      height: 20,
                      fit: BoxFit.fitWidth,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    bool hasAddress,
  ) async {
    if (hasAddress) {
      context.push(RoutePaths.busRoute, extra: {
        'destination_latitude': address!.destinationLatitude,
        'destination_longitude': address!.destinationLongitude,
        'destination_name': address!.destinationName,
        'use_my_location': true,
        'transport_mode': 0,
      });
      return;
    }

    final result = await context.push<Map<String, dynamic>>(
      RoutePaths.busSearch,
      extra: {
        'is_from_location': false,
        'current_city': currentCity,
        'address_type': type.name,
      },
    );
    final name = result?['location_name'] as String? ?? '';
    final latitude = (result?['latitude'] as num?)?.toDouble();
    final longitude = (result?['longitude'] as num?)?.toDouble();
    if (name.trim().isEmpty || latitude == null || longitude == null) return;
    await ref.read(addressViewModelProvider.notifier).setAddress(
          type,
          AddressInfo(
            destinationLatitude: latitude,
            destinationLongitude: longitude,
            destinationName: name,
          ),
        );
  }
}

class _NearbyFunctionCard extends StatelessWidget {
  const _NearbyFunctionCard({
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String iconPath;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        // 预留阴影扩散区；卡片本体仍与 Android 一致为 88dp 高。
        top: 3,
        bottom: 5,
      ),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // 外层 Container 绘制四边阴影，避免 Ink 层让边缘阴影被弱化。
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 3,
              spreadRadius: 0.5,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                children: [
                  Image.asset(iconPath, width: 56, height: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.routeEnquiryTitle,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.routeEnquirySubtitle,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(AppAssets.toolboxArrow, width: 18, height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
