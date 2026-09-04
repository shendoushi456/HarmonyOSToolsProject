import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// 文档翻译展示页（Tab3 入口）
///
/// 对应原 Android `DocTranslationFragment`，保真还原 Compose UI：
/// 蓝色标题栏 + 翻译示例卡片（背景 ic_text_bg）+ 功能说明 + 选择文档按钮。
///
/// 点击"选择文档"跳转到 [DocTranslationActivityPage]（文档翻译核心流程）。
///
/// 保真说明：原项目 `TopGradientSection` 内容被注释（空 Box），此处保留空实现。
class DocTranslationPage extends StatelessWidget {
  const DocTranslationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEDF6FF),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FEFF), Color(0xFFF0FEFF)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 20),
                _buildExampleCards(),
                _buildFeatureDescription(),
                const SizedBox(height: 15),
                _buildSelectDocumentButton(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 顶部标题栏
  Widget _buildTopBar() {
    return Container(
      height: 50,
      color: AppColors.primaryBlue,
      child: const Center(
        child: Text(
          '文档翻译',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 翻译示例卡片列表
  Widget _buildExampleCards() {
    final examples = const [
      _TranslationExample(
        title: '汉语',
        content: '《文城》讲述了在清末民初的动荡年代，北方青年林祥福与南来女子纪小美相遇、相爱，但小美在生下一女儿后突然离开，再无音讯，林祥福背着女儿一路南下，寻找妻子小美所在的「文城」的故事。该书承续了余华民间叙事……',
      ),
      _TranslationExample(
        title: '英语',
        content: 'Wencheng tells the story of Lin Xiangfu, a young man from the north, who meets and falls in love with Ji Xiaomei, a woman from the south, during the turbulent period of the late Qing Dynasty and early Republic ……',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 370,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/ic_text_bg.png',
                fit: BoxFit.fill,
              ),
            ),
            Column(
              children: examples
                  .map((e) => _buildExampleCard(e))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 翻译示例卡片
  Widget _buildExampleCard(_TranslationExample example) {
    final isEnglish = example.title == '英语';
    return Container(
      width: double.infinity,
      height: 166,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha: 0.08),
        //     blurRadius: 4,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(
              left: 18, right: 18, top: 12, bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                example.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isEnglish
                      ? AppColors.primaryBlue
                      : AppColors.langSwitchText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                example.content,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isEnglish
                      ? AppColors.primaryBlue
                      : const Color(0xFF6A6A6A),
                  height: 20 / 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 功能说明区
  Widget _buildFeatureDescription() {
    return const Column(
      children: [
        Text(
          '100万字翻译',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          '文档大小<10MB',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF777777),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 选择文档按钮
  Widget _buildSelectDocumentButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/doc_translation_activity'),
      child: Container(
        width: 206,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: const LinearGradient(
            colors: [
              AppColors.buttonGradientStart,
              AppColors.buttonGradientEnd,
            ],
          ),
        ),
        child: const Center(
          child: Text(
            '选择文档',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// 翻译示例数据
class _TranslationExample {
  const _TranslationExample({required this.title, required this.content});

  final String title;
  final String content;
}
