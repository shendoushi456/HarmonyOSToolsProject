// 对齐 Android ToolsWifiHomeFragment.java + activity_main_tool.xml。
// 布局: FrameLayout 固定结构 = wifi_top_bg 全屏背景 + 详情卡(叠加顶部) + 底部 homebottomyjbg 列表区(内部滚动)。
// 数据/权限/系统调用由 WifiViewModel/WifiListViewModel 提供，UI 仅消费状态。
// 排除: 优化提速(mBg→ClearSilverActivity)、流量速度 UI(安卓 visibility=gone，但 WifiState 保留计算)。
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/wifi_state.dart';
import '../viewmodels/wifi_view_model.dart';
import '../viewmodels/wifi_list_view_model.dart';
import 'widgets/wifi_connect_dialog.dart';
import 'widgets/wifi_accelerator_card.dart';
import 'widgets/wifi_list_section.dart';

class WifiPage extends ConsumerStatefulWidget {
  const WifiPage({super.key});

  @override
  ConsumerState<WifiPage> createState() => _WifiPageState();
}

class _WifiPageState extends ConsumerState<WifiPage> {
  String? _activeSsid;
  int _improvementPercent = 50;
  bool _optimized = false;
  final Random _random = Random();

  void _syncOptimizationState(String ssid) {
    if (_activeSsid == ssid) return;
    _activeSsid = ssid;
    var percent = 30 + _random.nextInt(41);
    if (percent == _improvementPercent) {
      percent = percent == 70 ? 69 : percent + 1;
    }
    _improvementPercent = percent;
    _optimized = false;
  }

  Future<void> _optimizeWifi() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WifiOptimizationProgressDialog(),
    );
    if (!mounted) return;
    setState(() => _optimized = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('优化成功')));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wifiViewModelProvider);
    final listState = ref.watch(wifiListViewModelProvider);
    final connectedToWifi = state.networkType == NetworkType.wifi;
    final ssid = state.currentSsid.isEmpty ? '已连接 Wi-Fi' : state.currentSsid;
    if (connectedToWifi && _activeSsid != ssid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !connectedToWifi) return;
        setState(() => _syncOptimizationState(ssid));
      });
    } else if (!connectedToWifi && _activeSsid != null) {
      // 断开后即使重新连回同一个 SSID，也视为新一轮连接，恢复可优化状态。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            ref.read(wifiViewModelProvider).networkType == NetworkType.wifi) {
          return;
        }
        setState(() {
          _activeSsid = null;
          _optimized = false;
        });
      });
    }
    // 对齐安卓 1 秒 Handler 更新 connectiontype: WIFI→ssid / MOBILE→运营商 / 否则"无网络"
    final connectionText = _connectionText(state);
    final isWifiEnabled =
        state.isWifiEnabled || state.networkType == NetworkType.wifi;
    // 状态栏高度(安卓 ImmersionBar fullScreen，内容需自行避让状态栏)
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // activity_main_tool.xml 顶部 ImageView wifi_top_bg(fitXY 全屏背景)
            Positioned.fill(
              child: Image.asset(AppAssets.wifiTopBg, fit: BoxFit.fill),
            ),
            // 内容层: 固定 Column(对齐 FrameLayout 内 LinearLayout)
            Column(
              children: [
                // wifi_details_btn 详情卡(paddingTop 35dp + 状态栏)
                Padding(
                  padding: EdgeInsets.only(top: topInset + 35),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    // 对齐安卓 wifi_details_btn 点击 → 权限流;
                    // 二级页 WiFiStrengthActivity 未迁移, 留 TODO。
                    onTap: () => ref
                        .read(wifiViewModelProvider.notifier)
                        .checkAndRequestPermissions(),
                    child: Column(
                      children: [
                        // top_wifi_icon 160x160dp(居中)
                        Image.asset(AppAssets.wifiTopIcon,
                            width: 160, height: 160),
                        const SizedBox(height: 10),
                        // connectiontype 18sp 黑 粗(动态 SSID/运营商/无网络)
                        Text(
                          connectionText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // "已连接" #51AB30 12sp center
                        const Text(
                          '已连接',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.wifiConnectGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                // 底部列表区: LinearLayout(homebottomyjbg 背景) + nearby_wifi_layout
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppAssets.wifiHomeBottomBg),
                        fit: BoxFit.fill,
                      ),
                    ),
                    // marginHorizontal 15dp(对齐安卓 LinearLayout marginHorizontal)
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          if (connectedToWifi)
                            WifiAcceleratorCard(
                              improvementPercent: _improvementPercent,
                              optimized: _optimized,
                              onTap: _optimizeWifi,
                            ),
                          Expanded(
                            child: WifiListSection(
                                isWifiEnabled: isWifiEnabled,
                                wifiList: listState.wifiList,
                                onItemClick: (wifi) async {
                                  // 对齐安卓列表项点击 → dialog_wifi → 系统 WiFi 设置
                                  if (await WifiConnectDialog.show(context) ==
                                      true) {
                                    try {
                                      final opened = await ref
                                          .read(wifiViewModelProvider.notifier)
                                          .openWifiSettings();
                                      if (!opened && context.mounted) {
                                        _showWifiSettingsFallback(context);
                                      }
                                    } catch (_) {
                                      if (context.mounted) {
                                        _showWifiSettingsFallback(context);
                                      }
                                    }
                                  }
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 对齐 ToolsMainActivity/ToolsWifiHomeFragment 的 connectiontype 更新逻辑
  String _connectionText(WifiState state) {
    switch (state.networkType) {
      case NetworkType.wifi:
        final ssid = state.currentSsid.replaceAll('"', '');
        // 安卓默认文案 "WI-FI 详情"(Handler 未返回 ssid 前的占位)
        return ssid.isEmpty ? 'WI-FI 详情' : ssid;
      case NetworkType.mobile:
        return state.carrierName.isEmpty ? '无网络' : state.carrierName;
      case NetworkType.none:
        return '无网络';
    }
  }

  void _showWifiSettingsFallback(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('无法自动打开 Wi-Fi 设置，请手动前往“设置 > WLAN”'),
          duration: Duration(seconds: 4),
        ),
      );
  }
}
