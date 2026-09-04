// WiFi 工具页 - 对齐 Android ToolsWifiHomeFragment.java + activity_main_tool.xml
// 布局: Column 顶部 Stack(背景图+WIFI标题+详情卡叠加) + Expanded 列表
// 主 VM 1 秒轮询(ssid/运营商/流量); 列表 VM 订阅 onScanFinishedStream + 进入调一次缓存
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/wifi_state.dart';
import '../viewmodels/wifi_view_model.dart';
import '../viewmodels/wifi_list_view_model.dart';
import 'widgets/wifi_top_background.dart';
import 'widgets/wifi_detail_card.dart';
import 'widgets/wifi_list_section.dart';
import 'widgets/wifi_connect_dialog.dart';
import 'widgets/wifi_permission_dialog.dart';

class WifiPage extends ConsumerStatefulWidget {
  const WifiPage({super.key});

  @override
  ConsumerState<WifiPage> createState() => _WifiPageState();
}

class _WifiPageState extends ConsumerState<WifiPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wifiViewModelProvider);
    final listState = ref.watch(wifiListViewModelProvider);

    // 详情卡文案: WIFI→ssid, MOBILE→运营商, 无网络
    String connectionText;
    if (state.networkType == NetworkType.wifi) {
      connectionText = state.isSsidUnknown ? '已连接 Wi-Fi' : state.currentSsid;
      if (connectionText.isEmpty) connectionText = 'CONNECT';
    } else if (state.networkType == NetworkType.mobile) {
      connectionText =
          state.carrierName.isEmpty ? '移动网络' : state.carrierName;
    } else {
      connectionText = '无网络';
    }

    return Scaffold(
      backgroundColor: AppColors.wifiPageBg,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 顶部区域: 背景图 + WIFI 标题 + 详情卡(叠加,对齐安卓 FrameLayout)
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  // 背景图 + WIFI 标题(高度 280,覆盖状态栏区域)
                  const WifiTopBackground(height: 280),
                  // 详情卡叠加在背景图下半部分
                  Positioned(
                    top: 130,
                    left: 0,
                    right: 0,
                    child: WifiDetailCard(
                      connectionTypeText: connectionText,
                      isConnected: state.networkType != NetworkType.none,
                      netStatusText: state.networkType == NetworkType.none
                          ? '当前无网络连接'
                          : '当前网络状态良好',
                      onTap: () async {
                        // 对齐 wifi_details_btn 点击触发 checkAndRequestWifiPermissions
                        if (state.isSsidUnknown) {
                          final agreed =
                              await WifiPermissionDialog.show(context);
                          if (agreed == true) {
                            await ref
                                .read(wifiViewModelProvider.notifier)
                                .openWifiSettings();
                            ref.read(wifiViewModelProvider.notifier).refresh();
                          }
                        } else {
                          ref.read(wifiViewModelProvider.notifier).refresh();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // 列表区域(填充剩余空间)
            Expanded(
              child: WifiListSection(
                isScanning: listState.isScanning,
                isWifiEnabled: state.isWifiEnabled ||
                    state.networkType == NetworkType.wifi,
                wifiList: listState.wifiList,
                emptyText: '正在等待系统扫描附近 Wi-Fi...',
                onRefreshCache: () {
                  ref
                      .read(wifiListViewModelProvider.notifier)
                      .refreshCache();
                },
                onItemClick: (wifi) async {
                  final confirmed = await WifiConnectDialog.show(context);
                  if (confirmed == true) {
                    await ref
                        .read(wifiViewModelProvider.notifier)
                        .openWifiSettings();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
