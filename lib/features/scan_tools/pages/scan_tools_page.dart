// CleanMainFragment 的 Flutter 迁移版：仅保留扫描工具 UI。
// 顶部节日节气/历史上的今天来自 NewLifeFragment，位于扫描工具之前。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../calendar/services/history_service.dart';
import '../../menu_home/pages/qr_scan_page.dart';
import '../../recognition/models/recognition_type.dart';
import '../../life_tools/pages/webview/web_tool_page.dart';

class ScanToolsPage extends StatelessWidget {
  const ScanToolsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF2F4F5),
        body: Stack(children: [
          Positioned.fill(
              child: Image.asset(AppAssets.wifiTopBg, fit: BoxFit.fill)),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 20, bottom: 28),
              child: Column(children: [
                const Text('工具',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E))),
                const SizedBox(height: 26),
                const _FestivalSection(),
                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text('扫描工具',
                        style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(children: [
                    _ScanCard(
                        title: '二维码扫描',
                        subtitle: '快速识别二维码内容',
                        background: AppAssets.scanItemBackground,
                        icon: AppAssets.scanItemIconQr,
                        onTap: () => QrScanPage.push(context)),
                    _ScanCard(
                        title: '文字识别',
                        subtitle: '快速识别文字内容',
                        background: AppAssets.scanItemBackground,
                        icon: AppAssets.scanItemIconText,
                        onTap: () =>
                            _openRecognition(context, RecognitionType.text)),
                    _ScanCard(
                        title: '植物识别',
                        subtitle: '对准植物直观了解',
                        background: AppAssets.scanItemBackground,
                        icon: AppAssets.scanItemIconPlant,
                        onTap: () =>
                            _openRecognition(context, RecognitionType.plant)),
                    _ScanCard(
                        title: '动物识别',
                        subtitle: '一键快速查看动物种类',
                        background: AppAssets.scanItemBackground,
                        icon: AppAssets.scanItemIconAnimal,
                        onTap: () =>
                            _openRecognition(context, RecognitionType.animal)),
                    _ScanCard(
                        title: '银行卡识别',
                        subtitle: '快速识别银行卡信息',
                        background: AppAssets.scanItemBackground,
                        icon: AppAssets.recognitionBankIcon,
                        onTap: () => _openRecognition(
                            context, RecognitionType.bankCard)),
                  ]),
                ),
              ]),
            ),
          ),
        ]),
      );

  void _openRecognition(BuildContext context, RecognitionType type) =>
      context.push(RoutePaths.recognition, extra: type);
}

class _FestivalSection extends StatelessWidget {
  const _FestivalSection();
  @override
  Widget build(BuildContext context) => Row(children: [
        const SizedBox(width: 20),
        Expanded(
            child: _FestivalCard(
                image: AppAssets.scanFestival,
                title: '节日节气',
                onTap: () => WebToolPage.push(context,
                    title: '24节气',
                    url: 'assets/game/ershisijieqi/index.html'))),
        const SizedBox(width: 15),
        Expanded(
            child: _FestivalCard(
                image: AppAssets.scanHistoryToday,
                title: '历史上的今天',
                onTap: () => _showHistory(context))),
        const SizedBox(width: 20),
      ]);

  Future<void> _showHistory(BuildContext context) async {
    final events = await HistoryService().fetchHistory(DateTime.now());
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('历史上的今天',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (events.isEmpty) const Text('暂无历史数据'),
            for (final event in events)
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${event.time}  ${event.name}'),
                  subtitle: Text(event.detail)),
          ],
        ),
      ),
    );
  }
}

class _FestivalCard extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback onTap;
  const _FestivalCard(
      {required this.image, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 160,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(image, fit: BoxFit.fill),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)))),
          ]),
        ),
      );
}

class _ScanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String background;
  final String icon;
  final VoidCallback onTap;
  const _ScanCard(
      {required this.title,
      required this.subtitle,
      required this.background,
      required this.icon,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          height: 92,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          child: Stack(children: [
            Positioned.fill(child: Image.asset(background, fit: BoxFit.fill)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Image.asset(icon, width: 50, height: 50, fit: BoxFit.contain),
                const SizedBox(width: 5),
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E))),
                      const SizedBox(height: 5),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF848484))),
                    ])),
                Image.asset(AppAssets.scanItemArrow, width: 16, height: 16),
              ]),
            ),
          ]),
        ),
      );
}
