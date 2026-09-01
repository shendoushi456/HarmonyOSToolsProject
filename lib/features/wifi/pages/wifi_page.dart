// toolbox_c ToolsWifiHomeFragment/activity_main_tool.xml 的 Flutter 页面。
// 数据、权限与系统调用继续由 WifiRepository/WifiViewModel 提供；此处只负责 UI。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../models/wifi_signal_strength.dart';
import '../viewmodels/wifi_state.dart';
import '../viewmodels/wifi_view_model.dart';
import '../viewmodels/wifi_list_view_model.dart';
import 'widgets/wifi_list_section.dart';
import 'widgets/wifi_connect_dialog.dart';

class WifiPage extends ConsumerWidget {
  const WifiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wifiViewModelProvider);
    final listState = ref.watch(wifiListViewModelProvider);
    late final String title;
    switch (state.networkType) {
      case NetworkType.wifi:
        title = state.currentSsid.replaceAll('"', '').isEmpty
            ? 'CONNECT'
            : state.currentSsid.replaceAll('"', '');
        break;
      case NetworkType.mobile:
        title = state.carrierName.isEmpty ? 'MOBILE' : state.carrierName;
        break;
      case NetworkType.none:
        title = '无网络';
        break;
    }
    final signal = state.networkType == NetworkType.wifi
        ? _signalText(state.currentRssi)
        : '信号强度：无';

    return Scaffold(
      backgroundColor: AppColors.wifiHomeBg,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(AppAssets.toolboxWifiBg, fit: BoxFit.fill)),
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 25, bottom: 24),
              child: Column(
                children: [
                  const SizedBox(height: 34),
                  const Text('WIFI',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E))),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => ref
                        .read(wifiViewModelProvider.notifier)
                        .checkAndRequestPermissions(),
                    child: Column(
                      children: [
                        Image.asset(AppAssets.toolboxWifiMain,
                            width: 150, height: 150),
                        const SizedBox(height: 6),
                        Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E1E))),
                        const SizedBox(height: 6),
                        Text(signal,
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xB31E1E1E))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x66666666),
                              blurRadius: 3,
                              offset: Offset(2, 2))
                        ]),
                    child: WifiListSection(
                      isWifiEnabled: state.isWifiEnabled ||
                          state.networkType == NetworkType.wifi,
                      wifiList: listState.wifiList,
                      onItemClick: (wifi) async {
                        if (await WifiConnectDialog.show(context) == true) {
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
          ],
        ),
      ),
    );
  }

  String _signalText(int rssi) {
    final level = WifiSignalStrength.fromRssi(rssi);
    switch (level) {
      case WifiSignalStrength.disabled:
        return '信号强度：无';
      case WifiSignalStrength.low:
        return '信号强度：弱';
      case WifiSignalStrength.medium:
        return '信号强度：中';
      case WifiSignalStrength.high:
        return '信号强度：强';
      case WifiSignalStrength.excellent:
        return '信号强度：极强';
    }
  }
}
