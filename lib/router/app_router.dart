// 路由配置 - 集中定义所有路由
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/pages/home_shell_page.dart';
import '../features/setting/pages/about_page.dart';
import '../features/setting/pages/feedback_page.dart';
import '../features/setting/pages/policy_page.dart';
import '../features/setting/pages/setting_page.dart';
import '../features/splash/pages/splash_page.dart';
import '../features/weather/pages/city_select_page.dart';
import '../features/menu_home/pages/image_to_pdf_page.dart';
import '../features/menu_home/pages/pdf_compress_page.dart';
import '../features/menu_home/pages/pdf_encrypt_page.dart';
import '../features/menu_home/pages/pdf_to_image_page.dart';
import '../features/recognition/models/recognition_type.dart';
import '../features/recognition/pages/recognition_page.dart';
import '../features/wifi/pages/app_settings_page.dart';
import '../features/wifi/pages/speed_net_page.dart';
import '../features/wifi/pages/wifi_list_page.dart';
import '../features/wifi/pages/wifi_strength_page.dart';
import '../features/wifi_tools/pages/led_display_page.dart';
import '../features/wifi_tools/pages/led_page.dart';
import '../features/wifi_tools/pages/low_poly_page.dart';
import '../features/wifi_tools/pages/qr_code_page.dart';
import 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  routes: [
    // 启动页 - 对齐 Android SplashActivity(检查隐私协议)
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RoutePaths.weather,
      name: RouteNames.home,
      builder: (context, state) => const HomeShellPage(),
    ),
    // 城市选择页(单选模式) - 对齐 Android AddCityActivity
    GoRoute(
      path: RoutePaths.citySelect,
      name: RouteNames.citySelect,
      builder: (context, state) => const CitySelectPage(),
    ),
    // 设置页 - 对齐 Android Setting4Activity
    GoRoute(
      path: RoutePaths.setting,
      name: RouteNames.setting,
      builder: (context, state) => const SettingPage(),
    ),
    // 协议页 - 对齐 Android PolicyToolsSetActivity(extra: title+url)
    GoRoute(
      path: RoutePaths.policy,
      name: RouteNames.policy,
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return PolicyPage(
          title: extra['title'] ?? '',
          url: extra['url'] ?? '',
        );
      },
    ),
    // 关于页 - 对齐 Android AboutToolSetActivity
    GoRoute(
      path: RoutePaths.about,
      name: RouteNames.about,
      builder: (context, state) => const AboutPage(),
    ),
    // 反馈页 - 对齐 Android FeedBackSettingActivity
    GoRoute(
      path: RoutePaths.feedback,
      name: RouteNames.feedback,
      builder: (context, state) => const FeedbackPage(),
    ),
    GoRoute(
      path: RoutePaths.recognition,
      name: RouteNames.recognition,
      builder: (context, state) => RecognitionPage(
        type: state.extra as RecognitionType,
      ),
    ),
    // ====== toolbox_c 首页链路二级页 ======
    // 附近 WiFi 列表 - 对齐 Android WiFiListActivity(原首页按钮 gone,暂无 UI 入口)
    GoRoute(
      path: RoutePaths.wifiList,
      name: RouteNames.wifiList,
      builder: (context, state) => const WifiListPage(),
    ),
    // WiFi 详情 - 对齐 Android WiFiStrengthActivity(首页 Wi-Fi详情大圆卡进入)
    GoRoute(
      path: RoutePaths.wifiStrength,
      name: RouteNames.wifiStrength,
      builder: (context, state) => const WifiStrengthPage(),
    ),
    // 网速测试 - 对齐 Android SpeedNetActivity
    GoRoute(
      path: RoutePaths.speedNet,
      name: RouteNames.speedNet,
      builder: (context, state) => const SpeedNetPage(),
    ),
    // WiFi 设置 - 对齐 Android AppSettingsActivity
    GoRoute(
      path: RoutePaths.wifiSettings,
      name: RouteNames.wifiSettings,
      builder: (context, state) => const AppSettingsPage(),
    ),
    // ====== toolbox_c 工具箱链路二级页 ======
    // 特效图 - 对齐 Android PictureLowPolyActivity
    GoRoute(
      path: RoutePaths.lowPoly,
      name: RouteNames.lowPoly,
      builder: (context, state) => const LowPolyPage(),
    ),
    // 自制二维码 - 对齐 Android QRCodeActivity
    GoRoute(
      path: RoutePaths.qrCode,
      name: RouteNames.qrCode,
      builder: (context, state) => const QrCodePage(),
    ),
    // LED滚动设置 - 对齐 Android LedActivity
    GoRoute(
      path: RoutePaths.led,
      name: RouteNames.led,
      builder: (context, state) => const LedPage(),
    ),
    // LED 全屏显示 - 对齐 Android Led1/Led2Activity
    GoRoute(
      path: RoutePaths.ledDisplay,
      name: RouteNames.ledDisplay,
      builder: (context, state) {
        final q = state.queryParameters;
        Color hexToColor(String? hex, int defArgb) {
          if (hex == null || hex.isEmpty) return Color(defArgb);
          return Color(int.tryParse('FF$hex', radix: 16) ?? defArgb);
        }

        return LedDisplayPage(
          scrollMode: q['mode'] == 'scroll',
          text: q['text'] ?? '',
          bgColor: hexToColor(q['bg'], 0xFF000000),
          fgColor: hexToColor(q['fg'], 0xFFF6C766),
          fontSize: double.tryParse(q['size'] ?? '') ?? 120,
          speed: double.tryParse(q['speed'] ?? '') ?? 12,
        );
      },
    ),
    // ====== toolbox_c 工具箱 PDF 功能(复用 master_mianfeisaosaowang 迁移实现) ======
    // PDF 转图片(保存按钮写系统相册)
    GoRoute(
      path: RoutePaths.pdfToImage,
      name: RouteNames.pdfToImage,
      builder: (context, state) => const PdfToImagePage(),
    ),
    // 图片转 PDF
    GoRoute(
      path: RoutePaths.imageToPdf,
      name: RouteNames.imageToPdf,
      builder: (context, state) => const ImageToPdfPage(),
    ),
    // PDF 加密
    GoRoute(
      path: RoutePaths.pdfEncrypt,
      name: RouteNames.pdfEncrypt,
      builder: (context, state) => const PdfEncryptPage(),
    ),
    // PDF 压缩
    GoRoute(
      path: RoutePaths.pdfCompress,
      name: RouteNames.pdfCompress,
      builder: (context, state) => const PdfCompressPage(),
    ),
  ],
);
