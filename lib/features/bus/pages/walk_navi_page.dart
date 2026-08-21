// 步行导航页 - 对齐 Android bus/WalkNaviActivity.kt
// 百度地图步行导航独立页面
//
// 迁移说明：
// - Android Activity（原生 View） → Flutter ConsumerStatefulWidget
// - Android WalkNavigateHelper.getInstance() → 鸿蒙端 SDK 不可用，用占位 UI + TODO 兜底
// - Android onCreate/onResume/onPause/onDestroy → WidgetsBindingObserver + initState/dispose
// - Android createMapInfoContent() → 复用 widgets/map_compose.dart 中的 MapInfoContent
// - Android FrameLayout.addView(view) → 占位 Container（SDK 不可用）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/bus_theme_colors.dart';
import '../viewmodels/map_navi_view_model.dart';
import '../widgets/map_compose.dart';

/// 步行导航页 - 对齐 Android WalkNaviActivity
/// 百度地图步行导航独立页面
class WalkNaviPage extends ConsumerStatefulWidget {
  const WalkNaviPage({super.key});

  @override
  ConsumerState<WalkNaviPage> createState() => _WalkNaviPageState();
}

class _WalkNaviPageState extends ConsumerState<WalkNaviPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 对齐 Android onCreate: mNaviHelper = WalkNavigateHelper.getInstance()
    // 对齐 Android onCreate: mNaviHelper!!.setWalkNaviDisplayOption(...)
    // 鸿蒙端 SDK 不可用，仅记录日志
    // TODO(HarmonyOS): 鸿蒙端 WalkNavigateHelper 可用后，在此初始化

    // 对齐 Android onCreate: mNaviHelper!!.onCreate(this)
    // 对齐 Android onCreate: mNaviHelper!!.startWalkNavi(this)
    // 鸿蒙端 SDK 不可用，由 ViewModel stub 处理
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 对齐 Android: mNaviHelper!!.setWalkNaviStatusListener(...)
      // 对齐 Android: mNaviHelper!!.setTTsPlayer(...)
      // 对齐 Android: mNaviHelper!!.startWalkNavi(this)
      // 对齐 Android: mNaviHelper!!.setRouteGuidanceListener(...)
      ref
          .read(mapNaviViewModelProvider.notifier)
          .startWalkNavi();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 对齐 Android: mNaviHelper!!.resume() / pause() / quit()
    switch (state) {
      case AppLifecycleState.resumed:
        // 对齐 Android onResume: mNaviHelper!!.resume()
        ref.read(mapNaviViewModelProvider.notifier).resumeNavigation();
        break;
      case AppLifecycleState.paused:
        // 对齐 Android onPause: mNaviHelper!!.pause()
        ref.read(mapNaviViewModelProvider.notifier).pauseNavigation();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    // 对齐 Android onDestroy: mNaviHelper!!.quit()
    ref.read(mapNaviViewModelProvider.notifier).exitNavigation();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 退出导航 - 对齐 Android onNaviExit / onBackPressed
  void _exitNavi() {
    // 对齐 Android: mNaviHelper!!.quit()
    ref.read(mapNaviViewModelProvider.notifier).exitNavigation();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: FrameLayout(fill) + naviView + mapInfoContent
    // 鸿蒙端 SDK 不可用，用占位 UI 替代 naviView
    return Scaffold(
      body: SafeArea(
        // 对齐 Android: 状态栏深色字体 + 全屏沉浸
        child: Stack(
          children: [
            // 顶部状态栏 - 对齐 Android WalkNaviActivity 自带的顶部导航栏（SDK 内置）
            // 鸿蒙端 SDK 不可用，需要自行添加返回按钮
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _WalkNaviTopBar(onBack: _exitNavi),
            ),
            // 占位提示 - 对齐 Android mNaviHelper!!.onCreate(this) 返回的导航视图
            // TODO(HarmonyOS): 鸿蒙端 WalkNavigateHelper 可用后，替换占位 UI 为真实导航视图
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_walk,
                      size: 80,
                      color: BusThemeColors.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '步行导航',
                      style: TextStyle(
                        color: Color(0xFF454545),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '鸿蒙端 WalkNavigateHelper SDK 不可用',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF8A8A8A),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _exitNavi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BusThemeColors.primaryColor,
                        foregroundColor: BusThemeColors.onPrimaryColor,
                      ),
                      child: const Text('退出导航'),
                    ),
                  ],
                ),
              ),
            ),
            // 审图号信息 - 对齐 Android createMapInfoContent()
            // 对齐 Android: frameLayout.addView(mapInfoContent)
            // 注意：Android 端 mapInfoContent 通过 LinearLayout 添加到 FrameLayout，
            // leftMargin = 20dp, gravity = CENTER_VERTICAL | START
            const Positioned(
              left: 20,
              top: 80,
              child: MapInfoContent(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 步行导航顶部栏 - 鸿蒙端自定义（Android 端由 SDK 提供）
class _WalkNaviTopBar extends StatelessWidget {
  const _WalkNaviTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 18),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: BusThemeColors.primaryColor,
      ),
      child: IconButton(
        onPressed: onBack,
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(),
        icon: const Icon(
          Icons.arrow_back,
          size: 18,
          color: BusThemeColors.onPrimaryColor,
        ),
      ),
    );
  }
}
