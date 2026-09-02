// 首页（附近） - 迁移 Android NearbyFragment.kt 的默认 MAP 模式。
// 该页默认由两行附近功能入口和占满余量的地图组成；未迁移未启用的 LIST 模式。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../router/route_names.dart';
import '../../bus/models/common_location_ui_state.dart';
import '../../bus/repositories/baidu_location_repository.dart';
import '../../bus/viewmodels/common_location_view_model.dart';
import '../../bus/widgets/location_permission_content.dart';
import '../../bus/widgets/map_compose.dart';
import '../models/nearby_function.dart';
import '../viewmodels/nearby_view_model.dart';

/// 首页（附近） - 对齐 Android NearbyFragment.ScreenContent。
class NearbyFragmentPage extends ConsumerStatefulWidget {
  const NearbyFragmentPage({super.key});

  @override
  ConsumerState<NearbyFragmentPage> createState() => _NearbyFragmentPageState();
}

class _NearbyFragmentPageState extends ConsumerState<NearbyFragmentPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPermission());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 对齐 Android NearbyFragment.onResume。
    if (state == AppLifecycleState.resumed) _checkPermission();
  }

  Future<void> _checkPermission() {
    return ref
        .read(commonLocationViewModelProvider.notifier)
        .checkLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final granted = await BaiduLocationRepository().requestLocationPermission();
    if (!mounted || !granted) return;
    await _checkPermission();
    await ref
        .read(commonLocationViewModelProvider.notifier)
        .getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(commonLocationViewModelProvider);
    if (locationState.hasLocationPermission &&
        !locationState.isLocating &&
        locationState.currentCity == '定位中') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(commonLocationViewModelProvider.notifier).getCurrentLocation();
      });
    }

    if (!locationState.hasLocationPermission) {
      return LocationPermissionContent(
        subtitle: '用于查看附近功能信息及使用\n路线规划等功能',
        onRequestPermission: _requestLocationPermission,
      );
    }
    return _NearbyMapContent(locationState: locationState);
  }
}

/// Android NearbyMapContent：上方功能区，下方无边框全屏地图。
class _NearbyMapContent extends ConsumerWidget {
  const _NearbyMapContent({required this.locationState});

  final CommonLocationUiState locationState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.nearbyGradientTop, Colors.white],
        ),
      ),
      child: Column(
        children: [
          const _NearbyTopSection(),
          Expanded(
            // Android 为无圆角、无阴影、无边框的剩余全屏 MapCompose。
            child: MapCompose(
              currentLocation: locationState.currentLocation,
              onLocationButtonClick: () {
                ref
                    .read(commonLocationViewModelProvider.notifier)
                    .getCurrentLocation();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Android NearbyTopSection：#6A85F0 至白色渐变、状态栏留白和两行入口。
class _NearbyTopSection extends ConsumerWidget {
  const _NearbyTopSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(nearbyViewModelProvider);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            const SizedBox(
              height: 47,
              child: Center(
                child: Text(
                  '附近',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            for (var index = 0; index < rows.length; index++) ...[
              _NearbyFunctionRow(functions: rows[index]),
              if (index != rows.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _NearbyFunctionRow extends StatelessWidget {
  const _NearbyFunctionRow({required this.functions});
  final List<NearbyFunction> functions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < functions.length; index++) ...[
          Expanded(child: _NearbyFunctionItem(function: functions[index])),
          if (index != functions.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

/// Android FunctionIconItemComposable + FunctionLabelRow。
class _NearbyFunctionItem extends StatelessWidget {
  const _NearbyFunctionItem({required this.function});
  final NearbyFunction function;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push(
          RoutePaths.busMapSearch,
          extra: {'search_keyword': function.name},
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              function.imageAsset,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 4),
            Text(
              function.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.nearbyFunctionText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
