// WiFi 工具页 - 对齐 Android ToolsWifiHomeFragment.java + activity_main_tool.xml
// 布局顺序(对齐源 XML 嵌套):
//   "WIFI" 标题 → mBg 连接卡(蓝色渐变)→ 附近 WiFi 列表 → "WiFi列表" 标题
// 注: 源布局的 wifi_details_btn 整个 CardView 在原 Java 中点击跳转 WiFiStrengthActivity(无对应 Flutter 页),
// 内层白色"优化提速"行及 mBg 跳转 ClearSilverActivity 的优化提速入口均按 MIGRATION 边界排除。
// 源 XML 中 "WiFi列表" 标题位于列表下方(L4 的同级),本迁移保持该位置。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/wifi_state.dart';
import '../viewmodels/wifi_view_model.dart';
import '../viewmodels/wifi_list_view_model.dart';
import 'widgets/wifi_connection_card.dart';
import 'widgets/wifi_list_section.dart';
import 'widgets/wifi_connect_dialog.dart';

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

    return Scaffold(
      // 对齐 activity_main_tool.xml 根 RelativeLayout android:background="#E3EEFF"
      backgroundColor: AppColors.wifiHomeBg,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 对齐 "WIFI" TextView: layout_marginTop 50dp + textSize _15sdp + textStyle bold
            // + textColor #1E1E1E + layout_gravity center
            const SizedBox(height: 50),
            const Center(
              child: Text(
                'WIFI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ),
            // 对齐源 CardView 内层 LL padding 10(标题与 mBg 卡片之间的视觉间隙)
            const SizedBox(height: 10),
            // mBg 连接卡
            WifiConnectionCard(
              // 对齐 wife_name.setText(getSSID().replace("\"", ""))
              ssid: state.currentSsid.replaceAll('"', ''),
            ),
            // 附近 WiFi 列表(对应 nearby_wifi_layout, 嵌入 MyWifiListFragment)
            Expanded(
              child: WifiListSection(
                isWifiEnabled: state.isWifiEnabled ||
                    state.networkType == NetworkType.wifi,
                wifiList: listState.wifiList,
                onItemClick: (wifi) async {
                  final confirmed = await WifiConnectDialog.show(context);
                  if (confirmed == true) {
                    try {
                      final opened = await ref
                          .read(wifiViewModelProvider.notifier)
                          .openWifiSettings();
                      if (!opened && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                '当前系统不支持直接打开 WLAN，请前往“设置 > WLAN”连接网络'),
                          ),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('无法打开系统设置，请前往“设置 > WLAN”连接网络'),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ),
            // 对齐 "WiFi列表" TextView: 位于列表下方, layout_marginTop 18dp,
            // 左相对屏幕 10dp(父 LL paddingLeft 10), textSize 22sp, textColor #000000
            // const Align(
            //   alignment: Alignment.centerLeft,
            //   child: Padding(
            //     padding: EdgeInsets.only(left: 10, top: 18, bottom: 12),
            //     child: Text(
            //       'WiFi列表',
            //       style: TextStyle(fontSize: 22, color: Colors.black),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
