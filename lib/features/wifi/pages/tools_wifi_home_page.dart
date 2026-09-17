// 首页 Tab - 对齐 Android toolsbox_moduel/toolsbox ToolsWifiHomeFragment + activity_main_tool.xml
// 迁移自 toolbox_c(com.risi.dasutong): 紫顶栏 + Wi-Fi详情大圆卡 + 实时网速卡 + 内嵌附近WiFi列表
// 保真说明: 原布局底部三按钮(附近Wifi/网速测试/WiFi设置)与浮窗卡 visibility=gone,不渲染;
// 每秒刷新逻辑复用 WifiViewModel(对齐安卓两个 1000ms Handler)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/storage/prefs_storage.dart';
import '../../../router/route_names.dart';
import '../utils/wifi_box_support.dart';
import '../viewmodels/wifi_state.dart';
import '../viewmodels/wifi_view_model.dart';
import 'widgets/wifi_box_list_section.dart';

class ToolsWifiHomePage extends ConsumerStatefulWidget {
  const ToolsWifiHomePage({super.key});

  @override
  ConsumerState<ToolsWifiHomePage> createState() => _ToolsWifiHomePageState();
}

class _ToolsWifiHomePageState extends ConsumerState<ToolsWifiHomePage> {
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    // 对齐 onViewCreated: 仅首次弹出权限(hasRequestedPermission),已授权直接展示列表
    Future.microtask(_initPermission);
  }

  Future<void> _initPermission() async {
    final requested = PrefsStorage.getBool('hasRequestedPermission');
    if (!requested) {
      // 对齐安卓: 先记录已请求过,避免下次进入首页再次主动弹出
      await PrefsStorage.setBool('hasRequestedPermission', true);
      final granted = await ref
          .read(wifiViewModelProvider.notifier)
          .checkAndRequestPermissions();
      if (mounted) setState(() => _permissionGranted = granted);
    } else {
      // 已请求过: 权限齐备时内嵌 WiFi 列表(对齐 PermissionClass.HasPermission 分支)
      final granted = await ref
          .read(wifiViewModelProvider.notifier)
          .checkAndRequestPermissions();
      if (mounted) setState(() => _permissionGranted = granted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wifi = ref.watch(wifiViewModelProvider);

    // 对齐安卓 1 秒 Runnable: connectiontype/wifiName 文案规则
    String connectionTypeText;
    String wifiNameText;
    switch (wifi.networkType) {
      case NetworkType.wifi:
        connectionTypeText = wifi.currentSsid;
        wifiNameText = '已连接${wifi.currentSsid}';
        break;
      case NetworkType.mobile:
        connectionTypeText = wifi.carrierName;
        wifiNameText = wifi.currentSsid.isEmpty ? '已连接：' : '已连接${wifi.currentSsid}';
        break;
      case NetworkType.none:
        connectionTypeText = '无网络';
        wifiNameText = '无网络';
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== 顶部栏(80dp #FF373063, 图标+白字粗体"首页") =====
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: const BoxDecoration(color: WifiBoxSupport.primary),
              child: SizedBox(
                height: 80 - MediaQuery.of(context).padding.top,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Image.asset(AppAssets.wifiBoxTitleIc,
                          width: 30, height: 30),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '首页',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // ===== Wi-Fi 详情大圆卡(162x162 top_round_bg,整卡可点) =====
            GestureDetector(
              onTap: () => context.push(RoutePaths.wifiStrength),
              child: Container(
                width: 162,
                height: 162,
                margin: const EdgeInsets.only(top: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(AppAssets.wifiBoxTopRoundBg,
                        width: 162, height: 162, fit: BoxFit.fill),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(AppAssets.wifiBoxTopWifiIcon,
                              width: 35, height: 35),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          wifiNameText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: WifiBoxSupport.primary, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        // Wi-Fi详情胶囊按钮(圆角100 #FF373063 白字12sp)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: WifiBoxSupport.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text('Wi-Fi详情',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildSpeedCard(wifi, connectionTypeText),

            // ===== 内嵌附近 WiFi 列表(对齐 nearby_wifi_layout + WiFiListFragment) =====
            // 权限齐备才内嵌列表(对齐安卓: hasRequestedPermission && HasPermission 才 commit)
            if (_permissionGranted)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: WifiBoxListSection(),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// 连接状态/实时网速卡(对齐白色 CardView: 圆角10 elevation3 左右20 高65)
  Widget _buildSpeedCard(WifiState wifi, String connectionTypeText) {
    return Container(
      height: 65,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1))
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        children: [
          // 左列: 连接类型 + 绿色 Connected(对齐 weight 1)
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  connectionTypeText.isEmpty ? 'Connected' : connectionTypeText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 9),
                ),
                const Text(
                  'Connected',
                  style: TextStyle(
                      color: WifiBoxSupport.greenColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // 右列: 下载/上传(对齐 weight 2.5)
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: _speedColumn(
                    iconBg: const Color(0xFFFF812E),
                    iconBgEnd: const Color(0xFFFF7200),
                    icon: AppAssets.wifiBoxDownloadWhite,
                    label: '下载速度',
                    value: wifi.downloadSpeed.toStringAsFixed(2),
                    unit: ' ${wifi.downloadUnit}',
                  ),
                ),
                Expanded(
                  child: _speedColumn(
                    iconBg: const Color(0xFF32CDFF),
                    iconBgEnd: const Color(0xFF0096FF),
                    icon: AppAssets.wifiBoxUploadWhite,
                    label: '上传速度',
                    value: wifi.uploadSpeed.toStringAsFixed(2),
                    unit: ' ${wifi.uploadUnit}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 下载/上传小列(对齐 orange_circle/blue_circle 25sdp 圆底 + 白色图标)
  Widget _speedColumn({
    required Color iconBg,
    required Color iconBgEnd,
    required String icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 25,
          height: 25,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [iconBg, iconBgEnd],
            ),
          ),
          child: Image.asset(icon, fit: BoxFit.contain),
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 7,
                    fontWeight: FontWeight.bold)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
                Text(unit,
                    style: const TextStyle(color: Colors.black, fontSize: 7)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
