// WiFi 列表区块 - 对齐 Android WiFiListFragment/WiFiListActivity + activity_wifi_list.xml
// 首页内嵌与全页列表共用: "可用网络"标题 + SwipeRefresh + 空态 Lottie + 列表
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../utils/wifi_box_support.dart';
import '../../viewmodels/wifi_box_list_view_model.dart';
import 'wifi_box_dialogs.dart';

/// WiFi 列表区块(对齐 activity_wifi_list.xml,标题栏 gone 仅保留"可用网络"+列表)
class WifiBoxListSection extends ConsumerWidget {
  const WifiBoxListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wifiBoxListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "可用网络"标题(对齐 #FF3F3F3F 16sp,左 20 下 10)
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 10),
          child: Text('可用网络',
              style: TextStyle(color: Color(0xFF3F3F3F), fontSize: 16)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: RefreshIndicator(
            color: const Color(0xFF0099CC),
            backgroundColor: Colors.white,
            onRefresh: () => _onRefresh(context, ref),
            child: state.entries.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.entries.length,
                    itemBuilder: (context, index) => WifiBoxScanItem(
                      entry: state.entries[index],
                      onTap: () => _onItemTap(context, state.entries[index]),
                    ),
                    separatorBuilder: (_, __) =>
                        Container(height: 1, color: const Color(0xFFE7E7E7)),
                  ),
          ),
        ),
      ],
    );
  }

  /// 下拉刷新(对齐安卓: startScan + Toast"开始扫描!",鸿蒙改为拉缓存)
  Future<void> _onRefresh(BuildContext context, WidgetRef ref) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('开始扫描!'), duration: Duration(seconds: 1)),
      );
    }
    await ref.read(wifiBoxListProvider.notifier).refreshCache();
  }

  /// 空态(对齐 animation_view: Lottie wifi_loading 120x60 + 白字"查找 WiFi...!")
  /// 注意: 安卓原版白字叠在白底上几乎不可见,属原版表现,保真还原
  Widget _buildEmpty() {
    return SizedBox(
      height: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 60,
            child: Lottie.asset('assets/lottie/wifi_loading.json',
                repeat: true, animate: true),
          ),
          const Text(
            '查找 WiFi...!',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }

  /// 列表项点击 - 按鸿蒙旧版逻辑(对齐安卓 SDK>28 分支):
  /// 弹确认框,确认后跳转系统 WiFi 设置页连接
  Future<void> _onItemTap(BuildContext context, WifiBoxEntry entry) async {
    showWifiSystemDialog(context);
  }
}

/// 列表项 - 对齐 wifi_list_item.xml + WifiListAdapter 绑定字段
class WifiBoxScanItem extends StatelessWidget {
  final WifiBoxEntry entry;
  final VoidCallback onTap;

  const WifiBoxScanItem({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // 第一行: 信号图标(26sdp 圆底 first_btn_circle) + SSID + 频率
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Color(0x80313C49),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        WifiBoxSupport.signalIcon(
                            entry.rssi, entry.capabilities),
                        fit: BoxFit.contain,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          entry.ssid,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF434343), fontSize: 12),
                        ),
                      ),
                    ),
                    Text(
                      '频率：${entry.frequency}MHz',
                      style: const TextStyle(
                          color: Color(0xFF434343), fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 第二行: MAC(左 #878787) + 网速 dBm(右 #FF373063)
                Row(
                  children: [
                    Text('MAC：${entry.bssid}',
                        style: const TextStyle(
                            color: Color(0xFF878787), fontSize: 10)),
                    const Spacer(),
                    Text('网速：${entry.rssi}dBm',
                        style: const TextStyle(
                            color: WifiBoxSupport.primary, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 10),
                // 第三行: 信号强度 + 渐变进度条(对齐 barra_gradiente #28a7fc→#3fcf8a)
                Row(
                  children: [
                    const Text('信号强度：',
                        style: TextStyle(
                            color: WifiBoxSupport.primary, fontSize: 10)),
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 10,
                        child: LinearProgressIndicator(
                          value:
                              WifiBoxSupport.progressValue(entry.rssi) / 100,
                          backgroundColor: const Color(0xFFDADADA),
                          valueColor:
                              const AlwaysStoppedAnimation(Color(0xFF3FCF8A)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 底部 1dp 分割线(对齐 #FFE7E7E7)
          Container(height: 1, color: const Color(0xFFE7E7E7)),
        ],
      ),
    );
  }
}
