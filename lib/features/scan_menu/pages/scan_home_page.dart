import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../life_tools/pages/checklist/checklist_page.dart';
import '../../life_tools/pages/compass/compass_page.dart';
import '../../life_tools/pages/tally/tally_page.dart';
import '../../life_tools/pages/webview/web_tool_page.dart';
import '../../menu_home/pages/qr_generate_page.dart';
import '../../menu_home/pages/qr_scan_page.dart';
import 'currency_converter_page.dart';
import 'document_camera_page.dart';
import 'document_capture_preview_page.dart';

/// 指定 MenuFragment 功能的首页，不混入原项目其余工具入口。
class ScanHomePage extends StatefulWidget {
  const ScanHomePage({super.key});

  @override
  State<ScanHomePage> createState() => _ScanHomePageState();
}

class _ScanHomePageState extends State<ScanHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(AppAssets.scanHomeBg, fit: BoxFit.cover)),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              children: [
                const Text('首页',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1E1E))),
                const SizedBox(height: 26),
                const Text('扫描工具',
                    style:
                        TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                const SizedBox(height: 13),
                _ToolGrid(items: [
                  _Tool('拍照存档', AppAssets.scanToolArchive,
                      () => _capture(context)),
                  _Tool('二维码识别', AppAssets.scanToolQrScan,
                      () => QrScanPage.push(context)),
                  _Tool('生成二维码', AppAssets.scanToolQrGenerate,
                      () => QrGeneratePage.push(context)),
                ]),
                const SizedBox(height: 28),
                const Text('常用工具',
                    style:
                        TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                const SizedBox(height: 13),
                _ToolGrid(items: [
                  _Tool('旅行清单', AppAssets.icTravel,
                      () => ChecklistPage.push(context)),
                  _Tool(
                      'JSON编辑器',
                      AppAssets.icJson,
                      () => WebToolPage.push(
                            context,
                            title: 'JSON编辑器',
                            url: 'https://ol.woobx.cn/tool/json-editor',
                          )),
                  _Tool('指南针', AppAssets.icCompass,
                      () => CompassPage.push(context)),
                  _Tool(
                      '花费记账', AppAssets.icTally, () => TallyPage.push(context)),
                ]),
                const SizedBox(height: 26),
                _CurrencyPreviewCard(
                    onTap: () => CurrencyConverterPage.push(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _capture(BuildContext context) async {
    final file = await DocumentCameraPage.capture(context);
    if (file != null && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DocumentCapturePreviewPage(file: file)),
      );
    }
  }
}

class _ToolGrid extends StatelessWidget {
  const _ToolGrid({required this.items});
  final List<_Tool> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: .91),
      itemCount: items.length,
      itemBuilder: (_, index) => _ToolCard(tool: items[index]),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});
  final _Tool tool;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tool.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
            color: const Color(0xF0FFFFFF),
            borderRadius: BorderRadius.circular(8)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(tool.asset, width: 42, height: 42),
          const SizedBox(height: 10),
          Text(tool.name,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

class _Tool {
  const _Tool(this.name, this.asset, this.onTap);
  final String name;
  final String asset;
  final VoidCallback onTap;
}

/// 对齐 MenuFragment.HuilvSelection：首页仅展示人民币与美元的换算预览。
class _CurrencyPreviewCard extends StatelessWidget {
  const _CurrencyPreviewCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            height: 168,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(children: [
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('汇率换算',
                    style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 26),
              const Row(children: [
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(right: 11),
                  child: Text('人民币（CNY）',
                      style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                )),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(left: 11),
                  child: Text('美元（USD）',
                      style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                )),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                const Expanded(
                    child: _CurrencyAmount(color: Color(0xFF51DED0))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Image.asset(AppAssets.scanExchangeArrow,
                      width: 22, height: 22),
                ),
                const Expanded(
                    child: _CurrencyAmount(color: Color(0xFFEAC27A))),
              ]),
            ]),
          ),
        ));
  }
}

class _CurrencyAmount extends StatelessWidget {
  const _CurrencyAmount({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: const Text('0',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
    );
  }
}
