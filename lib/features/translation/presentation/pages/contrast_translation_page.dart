import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/core/theme/app_colors.dart';

/// 对比翻译结果页（原文 + 译文）
///
/// 对应原 Android `ContrastTranslationActivity`，保真还原 Compose UI：
/// 蓝色顶栏（返回 + 标题）+ 原文卡片 + 译文卡片（背景 ic_text_bg + 全屏按钮）。
class ContrastTranslationPage extends StatelessWidget {
  const ContrastTranslationPage({
    super.key,
    required this.sourceText,
    required this.translatedText,
    this.title = '文字提取',
  });

  final String sourceText;
  final String translatedText;
  final String title;

  void _navigateToDetail(BuildContext context, String text, String label) {
    context.push('/text_detail', extra: <String, dynamic>{
      'mode': 1,
      'singleText': text,
      'title': label,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _TextCard(
                    label: '原文',
                    text: sourceText,
                    onFullScreenClick: () =>
                        _navigateToDetail(context, sourceText, '原文'),
                  ),
                  const SizedBox(height: 20),
                  _TextCard(
                    label: '译文',
                    text: translatedText,
                    onFullScreenClick: () =>
                        _navigateToDetail(context, translatedText, '译文'),
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

  /// 顶部标题栏
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Stack(
            children: [
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 文本卡片（原文/译文通用）
///
/// 保真原 `TextCard`：高 236，圆角 10，阴影，背景 ic_text_bg，
/// 标签 + 可滚动内容 + 全屏按钮。
class _TextCard extends StatelessWidget {
  const _TextCard({
    required this.label,
    required this.text,
    required this.onFullScreenClick,
  });

  final String label;
  final String text;
  final VoidCallback onFullScreenClick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 236,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // 背景图
              Positioned.fill(
                child: Image.asset(
                  'assets/images/ic_text_bg.png',
                  fit: BoxFit.fill,
                ),
              ),
              // 内容
              Column(
                children: [
                  // 标签
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, top: 12),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.langSwitchText,
                        ),
                      ),
                    ),
                  ),
                  // 内容区（可滚动）
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: SingleChildScrollView(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.langSwitchText
                                .withValues(alpha: 0.8),
                            height: 22 / 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 全屏按钮
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 16),
                      child: GestureDetector(
                        onTap: onFullScreenClick,
                        behavior: HitTestBehavior.opaque,
                        child: Image.asset(
                          'assets/images/ic_trans_full_screen.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
