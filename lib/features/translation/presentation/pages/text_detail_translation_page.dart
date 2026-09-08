import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// 详情页模式常量（保真原 `MODE_DUAL` / `MODE_SINGLE`）
const int _modeDual = 0;
const int _modeSingle = 1;

/// 翻译详情页面
///
/// 对应原 Android `TextDetailTranslationActivity`，保真还原：
/// - 双文本模式：原文区 + 译文区（含复制）+ "新建翻译"
/// - 单文本模式：背景图 + 文本 + 复制
class TextDetailTranslationPage extends StatelessWidget {
  const TextDetailTranslationPage({
    super.key,
    this.mode = _modeDual,
    this.sourceText = '',
    this.translatedText = '',
    this.sourceLanguage = '中文',
    this.targetLanguage = '英语',
    this.singleText = '',
    this.title = '原文',
  });

  /// 模式：0=双文本，1=单文本
  final int mode;

  // 双文本模式参数
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;

  // 单文本模式参数
  final String singleText;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (mode == _modeSingle) {
      return _buildSingleTextMode(context);
    }
    return _buildDualTextMode(context);
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _copyText(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showToast(context, '复制成功');
  }

  /// 双文本模式
  Widget _buildDualTextMode(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          _buildDualTopBar(context),
          Expanded(
            // 翻译结果可能很长，使用滚动容器确保原文和译文都可完整查看。
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  _buildTranslationSection(
                    text: sourceText,
                    onCopy: () => _copyText(context, sourceText),
                  ),
                  const SizedBox(height: 30),
                  _buildTranslationSection(
                    text: translatedText,
                    onCopy: () => _copyText(context, translatedText),
                  ),
                  // 新建翻译按钮
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 91),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        '新建翻译',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 双文本模式顶栏（返回按钮）
  Widget _buildDualTopBar(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => context.pop(),
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
        ),
      ),
    );
  }

  /// 翻译文本区块（原文/译文通用）
  Widget _buildTranslationSection({
    required String text,
    required VoidCallback onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.detailSectionBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.detailText,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 复制按钮
                GestureDetector(
                  onTap: onCopy,
                  child: Image.asset(
                    'assets/images/ic_trans_copy.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 单文本模式
  Widget _buildSingleTextMode(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          _buildSingleTextTopBar(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildSingleTextContent(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 单文本模式顶栏（返回 + 标题）
  Widget _buildSingleTextTopBar(BuildContext context) {
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

  /// 单文本内容（背景图 + 文本 + 复制）
  Widget _buildSingleTextContent(BuildContext context) {
    return Container(
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
            Positioned.fill(
              child: Image.asset(
                'assets/images/ic_text_bg.png',
                fit: BoxFit.fill,
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Text(
                        singleText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppColors.detailText,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _copyText(context, singleText),
                      child: Image.asset(
                        'assets/images/ic_trans_copy.png',
                        width: 22,
                        height: 22,
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
    );
  }
}
