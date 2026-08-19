import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/core/theme/app_colors.dart';
import 'package:harmonyos_flutter_empty/features/translation/domain/correction_grades.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/providers/article_correction_provider.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/states/article_correction_ui_state.dart';

/// 最大输入字符数（保真原 `maxLength = 5000`）
const int _maxLength = 5000;

/// 文章批改输入页（Tab4）
///
/// 对应原 Android `ArticleTranslationFragment`，保真还原 Compose UI：
/// 蓝色标题栏 + 白色卡片输入区（背景 ic_text_bg）+ 批改按钮 + 等级下拉框 + Loading 遮罩。
class ArticleTranslationPage extends ConsumerStatefulWidget {
  const ArticleTranslationPage({super.key});

  @override
  ConsumerState<ArticleTranslationPage> createState() =>
      _ArticleTranslationPageState();
}

class _ArticleTranslationPageState
    extends ConsumerState<ArticleTranslationPage> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(articleCorrectionNotifierProvider);

    // 监听批改结果跳转结果页，监听错误消息
    ref.listen<ArticleCorrectionUiState>(articleCorrectionNotifierProvider,
        (ArticleCorrectionUiState? previous, ArticleCorrectionUiState next) {
      if (next.correctionResult != null) {
        context.push('/article_result', extra: next.correctionResult);
        ref.read(articleCorrectionNotifierProvider.notifier).clearResult();
      }
      if (next.errorMessage != null) {
        _showToast(next.errorMessage!);
        ref.read(articleCorrectionNotifierProvider.notifier).clearError();
      }
    });

    return Container(
      color: const Color(0xFFEDF6FF),
      child: Stack(
        children: [
          // 顶部渐变背景
          Container(
            height: 235,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF3F6FE), Color(0xFFF3F6FE)],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _buildContentArea(uiState),
                ),
              ],
            ),
          ),
          if (uiState.isLoading) _buildLoadingOverlay(),
        ],
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
          '文章批改',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 内容区域
  Widget _buildContentArea(ArticleCorrectionUiState uiState) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        children: [
          // 白色卡片（输入区）
          _buildInputCard(),
          // 底部操作区
          Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 14, bottom: 16, top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCorrectButton(uiState),
                const SizedBox(width: 23),
                _buildLevelDropdown(uiState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 输入卡片（背景 ic_text_bg + 输入框 + 字数统计）
  Widget _buildInputCard() {
    return SizedBox(
      height: 300,
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
              // 文本输入区域
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14, top: 16),
                  child: TextField(
                    controller: _inputController,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.langSwitchText,
                    ),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: '请输入要批改的英语作文……',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: AppColors.hintText,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length <= _maxLength) {
                        setState(() {});
                      } else {
                        _inputController.text = value.substring(0, _maxLength);
                        _inputController.selection = TextSelection.fromPosition(
                          const TextPosition(offset: _maxLength),
                        );
                      }
                    },
                  ),
                ),
              ),
              // 字数统计
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_inputController.text.length}/$_maxLength',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.langSwitchText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  /// 批改按钮
  Widget _buildCorrectButton(ArticleCorrectionUiState uiState) {
    return GestureDetector(
      onTap: uiState.isLoading
          ? null
          : () {
              final text = _inputController.text;
              if (text.trim().isNotEmpty) {
                ref
                    .read(articleCorrectionNotifierProvider.notifier)
                    .correctArticle(text);
              } else {
                _showToast('请输入要批改的作文');
              }
            },
      child: Container(
        width: 108,
        height: 30,
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
            '批改',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// 等级下拉框
  Widget _buildLevelDropdown(ArticleCorrectionUiState uiState) {
    return PopupMenuButton<String>(
      initialValue: uiState.selectedGrade,
      onSelected: (level) {
        ref.read(articleCorrectionNotifierProvider.notifier).setGrade(level);
      },
      menuPadding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(maxWidth: 80),
      itemBuilder: (context) => CorrectionGrades.grades
          .map(
            (level) => PopupMenuItem<String>(
              value: level,
              height: 28,
              child: SizedBox(
                width: 80,
                child: Text(
                  level,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: level == uiState.selectedGrade
                        ? FontWeight.w500
                        : FontWeight.normal,
                    color: level == uiState.selectedGrade
                        ? AppColors.langSwitchText
                        : const Color(0xFF5A5A5A),
                  ),
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        width: 108,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              uiState.selectedGrade,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.langSwitchText,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.langSwitchText,
            ),
          ],
        ),
      ),
    );
  }

  /// Loading 遮罩
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.loadingIndicator,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '正在批改中...',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
