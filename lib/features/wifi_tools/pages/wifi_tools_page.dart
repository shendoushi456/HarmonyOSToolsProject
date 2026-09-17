// 工具箱 Tab - 对齐 Android WifiToolsFragment + wifi_tools_fragment_layout.xml
// 9 入口: PDF×4(点击预留) + 特效图 + Wifi设置 + 浮窗(应用内子窗口简化版) + 自制二维码 + LED滚动
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../wifi/utils/wifi_box_support.dart';
import '../../wifi/viewmodels/wifi_view_model.dart';
import '../viewmodels/float_speed_provider.dart';

class WifiToolsPage extends ConsumerStatefulWidget {
  const WifiToolsPage({super.key});

  @override
  ConsumerState<WifiToolsPage> createState() => _WifiToolsPageState();
}

class _WifiToolsPageState extends ConsumerState<WifiToolsPage> {
  @override
  void initState() {
    super.initState();
    // 浮窗开关状态由 floatSpeedProvider 从 SP 读取(对齐 StoredPreferencesValue)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ===== 顶栏 80dp #FF373063 白字粗体"工具箱" =====
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(color: WifiBoxSupport.primary),
            child: SizedBox(
              height: 80 - MediaQuery.of(context).padding.top,
              child: const Align(
                alignment: Alignment.center,
                child: Text('工具箱',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPdfRow(),
                  // 网络测速(对齐安卓 net_speed 入口: PermissionX 全通过后进 SpeedNetActivity)
                  _toolCard(
                    icon: AppAssets.wifiToolsLowPoly, // @mipmap/cesu_icon(原测速图标)
                    label: '网络测速',
                    onTap: _onSpeedTestTap,
                  ),
                  _toolCard(
                    icon: AppAssets.wifiToolsWifiSetting,
                    label: 'Wifi设置',
                    onTap: _onWifiSettingTap,
                  ),
                  _buildFloatCard(),
                  _toolCard(
                    icon: AppAssets.wifiToolsQrCode,
                    label: '自制二维码',
                    onTap: () => context.push(RoutePaths.qrCode),
                  ),
                  _toolCard(
                    icon: AppAssets.wifiToolsLed,
                    label: 'LED滚动',
                    onTap: () => context.push(RoutePaths.led),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// PDF 四卡行(margin 15/20,等重,背景 mipmap 图,图标+12sp #FF3F3F3F 文字)
  /// 点击预留: 对齐 PdfCompress/AddPasswordToPdf/ImageToPdf/PdfToImageActivity,
  /// 本分支未接入 PDF 功能页,保留点击回调 TODO
  Widget _buildPdfRow() {
    final bgs = <String>[
      AppAssets.wifiToolsPdfBg3,
      AppAssets.wifiToolsPdfBg4,
      AppAssets.wifiToolsPdfBg1,
      AppAssets.wifiToolsPdfBg2,
    ];
    final icons = <String>[
      AppAssets.wifiToolsPdfImageToPdf,
      AppAssets.wifiToolsPdfPdfToImage,
      AppAssets.wifiToolsPdfCompress,
      AppAssets.wifiToolsPdfEncrypt,
    ];
    final labels = <String>['图片转PDF', 'PDF转图片','PDF压缩', 'PDF加密' ];
    // 跳转路由: 四卡全部复用 master_mianfeisaosaowang 迁移实现
    final routes = <String?>[
      RoutePaths.imageToPdf,
      RoutePaths.pdfToImage,
      RoutePaths.pdfCompress,
      RoutePaths.pdfEncrypt,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
      child: Row(
        children: [
          for (int i = 0; i < 4; i++) ...[
            // 卡片间 10dp 间距(对齐安卓 item 间 marginRight)
            if (i == 2) const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final route = routes[i];
                  if (route != null) {
                    context.push(route);
                  }
                },
                child: Container(
                  height: 84,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(bgs[i]), fit: BoxFit.fill),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(icons[i], width: 40, height: 40),
                      const SizedBox(height: 6),
                      Text(labels[i],
                          style: const TextStyle(
                              color: Color(0xFF3F3F3F), fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
          // PDF转图片右侧 10dp 空白(对齐安卓四卡行右缘留白)
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  /// 通用工具卡(白卡60dp 圆角10 elevation,左右20,上下20/10,图标35+黑字+右箭头)
  Widget _toolCard({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Image.asset(icon, width: 35, height: 35),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label,
                      style: const TextStyle(color: Colors.black)),
                ),
                Image.asset(AppAssets.wifiToolsArrowRight,
                    width: 20, height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Wifi设置入口: 对齐安卓 PermissionX 全部通过才跳转(拒绝静默)
  Future<void> _onWifiSettingTap() async {
    final granted = await ref
        .read(wifiViewModelProvider.notifier)
        .checkAndRequestPermissions();
    if (granted && mounted) {
      context.push(RoutePaths.wifiSettings);
    }
    // 拒绝时静默结束(对齐安卓 onExplainRequestReason 空实现)
  }

  /// 网络测速入口: 对齐安卓 PermissionX 全通过后进 SpeedNetActivity,
  /// 拒绝时 Toast「这些权限被拒绝」
  Future<void> _onSpeedTestTap() async {
    final granted = await ref
        .read(wifiViewModelProvider.notifier)
        .checkAndRequestPermissions();
    if (!mounted) return;
    if (granted) {
      context.push(RoutePaths.speedNet);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('这些权限被拒绝'), duration: Duration(seconds: 1)));
    }
  }

  /// 浮窗卡(elevation 3,15 边距,10 上边距: 图标+标题/副标题+右侧启用/禁用胶囊)
  Widget _buildFloatCard() {
    final floatShowing = ref.watch(floatSpeedProvider);
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Image.asset(AppAssets.wifiBoxFloatingWindow, width: 30, height: 30),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('浮窗',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('启用此服务以使用浮动网络速度指示器',
                    style: TextStyle(color: Color(0xFF404850), fontSize: 9)),
              ],
            ),
          ),
          // 启用/禁用胶囊(未启用 disable_circle #DF7E2C+白透字"启用";启用 green_circle #5AC158+深绿字"禁用")
          GestureDetector(
            onTap: _toggleFloatingWindow,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
              decoration: BoxDecoration(
                color: floatShowing
                    ? const Color(0xFF5AC158)
                    : const Color(0xFFDF7E2C),
                borderRadius: BorderRadius.circular(20), // 长胶囊,加长背景
              ),
              child: Text(
                floatShowing ? '禁用' : '启用',
                style: TextStyle(
                    color: floatShowing
                        ? const Color(0xFF0C6A22) // dark_green
                        : const Color(0x90FFFFFF), // disable_color
                    fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  /// 浮窗启停(对齐安卓 openFloatingWindow 直接启停 Service;
  /// 鸿蒙简化为应用内浮层,浮于所有 Tab 之上,App 退出即消失)
  Future<void> _toggleFloatingWindow() async {
    await ref.read(floatSpeedProvider.notifier).setShowing(
        !ref.read(floatSpeedProvider));
  }
}
