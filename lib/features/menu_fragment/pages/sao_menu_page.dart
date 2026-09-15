// 对齐 toolbox_c MenuFragment.kt (master_saols_scan 分支, sao 版首页)
// 全屏背景图 + "首页"顶栏 + 花草/果蔬/动物识别卡 + 辅助工具4项 + PDF工具4项
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../services/tool_navigation_service.dart';
import '../models/tool_definition.dart';

class SaoMenuPage extends StatelessWidget {
  const SaoMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 对齐 MenuFragment.kt:104-109 ic_sao_main_bg 全屏背景 FillBounds
          Positioned.fill(
            child: Image.asset(
              AppAssets.saoMainBg,
              fit: BoxFit.fill,
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            // 对齐 TopAppBar(): statusBarsPadding + 高50, "首页"居中 22sp SemiBold
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 50,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '首页',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const _RecognitionCard(
                    title: '花草识别',
                    image: AppAssets.saoMain11,
                    imageWidth: 68,
                    imageHeight: 54,
                    destination: ToolDestination.recognitionPlant,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _FruitRecognitionCard(
                            onTap: () => ToolNavigationService.openDestination(
                              context,
                              ToolDestination.recognitionIngredient,
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: _AnimalRecognitionCard(
                            onTap: () => ToolNavigationService.openDestination(
                              context,
                              ToolDestination.recognitionAnimal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const _AuxiliaryToolsSection(),
                  const SizedBox(height: 30),
                  const _PdfToolsSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 阴影 - 对齐 Compose shadow(elevation=1.dp, black 15%)
const List<BoxShadow> _cardShadow = [
  BoxShadow(
    color: Color(0x26000000),
    blurRadius: 3,
    offset: Offset(0, 1),
  ),
];

/// "点击识别" + 右箭头(ic_sao_main_1_4 5x8)
class _TapRecognize extends StatelessWidget {
  const _TapRecognize();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '点击识别',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF377AF2),
            height: 17 / 12,
          ),
        ),
        const SizedBox(width: 6),
        Image.asset(
          AppAssets.saoMain14,
          width: 5,
          height: 8,
          fit: BoxFit.fill,
        ),
      ],
    );
  }
}

/// 花草识别卡片 - 对齐 FlowerRecognitionCard()
class _RecognitionCard extends StatelessWidget {
  final String title;
  final String image;
  final double imageWidth;
  final double imageHeight;
  final ToolDestination destination;

  const _RecognitionCard({
    required this.title,
    required this.image,
    required this.imageWidth,
    required this.imageHeight,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            ToolNavigationService.openDestination(context, destination),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: _cardShadow,
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 左侧: 标题和图标, 固定 150dp 内两端对齐
              SizedBox(
                width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF434343),
                        height: 22 / 16,
                      ),
                    ),
                    Image.asset(
                      image,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ),
              // 中间: 点击识别(对齐 Row padding start 90, SpaceBetween 靠右)
              Padding(
                padding: const EdgeInsets.only(left: 80),
                child: const _TapRecognize(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 果蔬识别卡片 - 对齐 FruitRecognitionCard()
class _FruitRecognitionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _FruitRecognitionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _cardShadow,
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 11, 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '果蔬识别',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF434343),
                      height: 22 / 16,
                    ),
                  ),
                  SizedBox(height: 7),
                  _TapRecognize(),
                ],
              ),
            ),
            Image.asset(
              AppAssets.saoMain12,
              width: 64,
              height: 57,
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );
  }
}

/// 动物识别卡片 - 对齐 AnimalRecognitionCard()
class _AnimalRecognitionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AnimalRecognitionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _cardShadow,
        ),
        padding: const EdgeInsets.fromLTRB(8, 13, 9, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1, bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '动物识别',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF434343),
                      height: 22 / 16,
                    ),
                  ),
                  SizedBox(height: 7),
                  _TapRecognize(),
                ],
              ),
            ),
            Image.asset(
              AppAssets.saoMain13,
              width: 66,
              height: 53,
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );
  }
}

/// 辅助工具区域 - 对齐 AuxiliaryToolsSection()
class _AuxiliaryToolsSection extends StatelessWidget {
  const _AuxiliaryToolsSection();

  @override
  Widget build(BuildContext context) {
    const tools = <_AuxiliaryTool>[
      _AuxiliaryTool('文档扫描', AppAssets.saoMain21, ToolDestination.photoArchive),
      _AuxiliaryTool('文字识别', AppAssets.saoMain22, ToolDestination.recognitionText),
      _AuxiliaryTool('二维码扫描', AppAssets.saoMain23, ToolDestination.qrScan),
      _AuxiliaryTool('生成二维码', AppAssets.saoMain24, ToolDestination.qrGenerate),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _cardShadow,
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 17, 21),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '辅助工具',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF434343),
                height: 25 / 18,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final tool in tools)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ToolNavigationService.openDestination(
                      context,
                      tool.destination,
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          tool.icon,
                          width: 50,
                          height: 50,
                          fit: BoxFit.fill,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 60,
                          child: Text(
                            tool.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF434343),
                              height: 17 / 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AuxiliaryTool {
  final String name;
  final String icon;
  final ToolDestination destination;
  const _AuxiliaryTool(this.name, this.icon, this.destination);
}

/// PDF工具区域 - 对齐 PDFToolsSection() 绝对定位标签 + 4 项列表
class _PdfToolsSection extends StatelessWidget {
  const _PdfToolsSection();

  @override
  Widget build(BuildContext context) {
    const pdfTools = <_PdfTool>[
      _PdfTool('PDF转图片', '一键转换文档格式', AppAssets.saoMain31,
          ToolDestination.pdfToImage),
      _PdfTool('图片转PDF', '一键轻松转换', AppAssets.saoMain32,
          ToolDestination.imageToPdf),
      _PdfTool('加密PDF', '一键加密,操作简单', AppAssets.saoMain33,
          ToolDestination.pdfEncrypt),
      // _PdfTool('压缩PDF', '只能压缩,减小体积', AppAssets.saoMain34,
      //     ToolDestination.pdfCompress),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          // 白卡(顶部留出 4dp, 顶部内容 padding 46dp 让位于标签)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: _cardShadow,
            ),
            padding: const EdgeInsets.fromLTRB(20, 46, 20, 16),
            child: Column(
              children: [
                for (var i = 0; i < pdfTools.length; i++) ...[
                  _PdfToolItem(tool: pdfTools[i]),
                  if (i < pdfTools.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          // PDF工具标签 - 174x30 ic_sao_main_3_5 + 白字居中
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 174,
                height: 30,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        AppAssets.saoMain35,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Align(
                      child: Text(
                        'PDF工具',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 22 / 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PDF工具项 - 对齐 PDFToolItem(): 图标60 + 名称/描述 + 绿色描边"点击使用"
class _PdfToolItem extends StatelessWidget {
  final _PdfTool tool;

  const _PdfToolItem({required this.tool});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ToolNavigationService.openDestination(
        context,
        tool.destination,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                tool.icon,
                width: 60,
                height: 60,
                fit: BoxFit.fill,
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF434343),
                        height: 20 / 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tool.description,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF777777),
                        height: 14 / 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 右侧: 0xFF7DBB70 描边圆角9 "点击使用" 10sp
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFF7DBB70), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            child: const Text(
              '点击使用',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF7DBB70),
                height: 14 / 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfTool {
  final String name;
  final String description;
  final String icon;
  final ToolDestination destination;
  const _PdfTool(this.name, this.description, this.icon, this.destination);
}
