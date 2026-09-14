import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/features/translation/domain/correction_grades.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/providers/article_correction_provider.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/states/article_correction_ui_state.dart';

/// 页面背景色（保真原 `Color(0xFFF0F2F8)`）
const Color _pageBackground = Color(0xFFF0F2F8);

/// 最大输入字符数（保真原 `maxLength = 5000`）
const int _maxLength = 5000;

/// 文档翻译展示页（Tab3 入口）
///
/// 对应原 Android `TextToolsFragment`（toolbox_c Compose 版），保真还原：
/// 拍照翻译卡片 + 文档翻译卡片 + 文章批改区域（输入框/批改按钮/等级下拉）。
///
/// 拍照翻译卡片跳转拍照翻译页（`/photo_translation_activity`），
/// 文档翻译卡片跳转文档翻译流程页（`/doc_translation_activity`，
/// 保真原 `onOpenFilePicker` 直接 `DocTranslationActivity.start`）。
class DocTranslationPage extends ConsumerStatefulWidget {
  const DocTranslationPage({super.key, this.isActive = true});

  /// 是否为当前可见 Tab。
  ///
  /// 底部导航为 IndexedStack，各 Tab 常驻；批改结果 Provider 为共享单例，
  /// 仅可见 Tab 响应结果跳转，避免与文章批改页重复 push。
  final bool isActive;

  @override
  ConsumerState<DocTranslationPage> createState() => _DocTranslationPageState();
}

class _DocTranslationPageState extends ConsumerState<DocTranslationPage> {
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

    // 监听批改结果，成功后跳转结果页并清除（保真原 LaunchedEffect，仅当前可见 Tab 响应）
    ref.listen<ArticleCorrectionUiState>(articleCorrectionNotifierProvider,
        (ArticleCorrectionUiState? previous, ArticleCorrectionUiState next) {
      if (!widget.isActive) {
        return;
      }
      final result = next.correctionResult;
      if (result != null && result != previous?.correctionResult) {
        context.push('/article_result', extra: result);
        ref.read(articleCorrectionNotifierProvider.notifier).clearResult();
      }
      // 错误消息 Toast
      if (next.errorMessage != null) {
        _showToast(next.errorMessage!);
        ref.read(articleCorrectionNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SingleChildScrollView(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 拍照翻译和文档翻译 - 横向排列
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPhotoTranslationCard(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDocTranslationCard(context),
                    ),
                  ],
                ),
              ),
              _buildArticleCorrectionContent(uiState),
            ],
          ),
        ),
      ),
    );
  }

  /// 拍照翻译卡片
  Widget _buildPhotoTranslationCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 保真：原项目点击后走相机权限流程进入拍照翻译
        context.push('/photo_translation_activity');
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A6CF7), Color(0xFF6B8AFF)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ic_trans_photo.webp',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            const Text(
              '拍照翻译',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '随时随地 畅译无阻',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 文档翻译卡片
  Widget _buildDocTranslationCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 保真：原项目文档翻译卡片点击直接打开 DocTranslationActivity
        context.push('/doc_translation_activity');
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5B8DEF), Color(0xFF7BA8F5)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ic_trans_doc.webp',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            const Text(
              '文档翻译',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '一键翻译 文字提取',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 文章批改内容
  Widget _buildArticleCorrectionContent(ArticleCorrectionUiState uiState) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 30),
            _buildContentArea(uiState),
          ],
        ),
        // 加载遮罩层
        if (uiState.isLoading) _buildLoadingOverlay(),
      ],
    );
  }

  /// 文章批改内容区
  Widget _buildContentArea(ArticleCorrectionUiState uiState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 文章批改标题
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(bottom: 16),
            child: const Text(
              '文章批改',
              style: TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 输入框容器
          Container(
            width: double.infinity,
            height: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF4F7FF)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Stack(
              children: [
                _buildInputField(),
                // 字数统计放在右下角
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Text(
                    '${_inputController.text.length}/$_maxLength',
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 27),
          // 批改按钮 + 等级下拉
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 12, right: 14, bottom: 16),
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

  /// 作文输入框
  Widget _buildInputField() {
    return TextField(
      controller: _inputController,
      maxLines: null,
      expands: true,
      style: const TextStyle(
        color: Color(0xFF666666),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        hintText: _inputController.text.isEmpty ? '请输入要批改的英语作文……' : null,
        hintStyle: const TextStyle(
          color: Color(0xFF616161),
          fontSize: 16,
        ),
      ),
      onChanged: (value) {
        // 保真：超过最大输入字符数时不接受输入
        if (value.length <= _maxLength) {
          setState(() {});
        } else {
          _inputController
            ..text = value.substring(0, _maxLength)
            ..selection = TextSelection.fromPosition(
              const TextPosition(offset: _maxLength),
            );
        }
      },
    );
  }

  /// 批改按钮
  Widget _buildCorrectButton(ArticleCorrectionUiState uiState) {
    return GestureDetector(
      onTap: () {
        if (_inputController.text.trim().isNotEmpty) {
          ref
              .read(articleCorrectionNotifierProvider.notifier)
              .correctArticle(_inputController.text);
        } else {
          _showToast('请输入要批改的作文');
        }
      },
      child: Container(
        width: 130,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          gradient: const LinearGradient(
            colors: [Color(0xFF3A6AE6), Color(0xFF3A6AE6)],
          ),
        ),
        child: const Text(
          '批改',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 等级下拉选择
  Widget _buildLevelDropdown(ArticleCorrectionUiState uiState) {
    return PopupMenuButton<String>(
      initialValue: uiState.selectedGrade,
      onSelected: (String level) {
        ref.read(articleCorrectionNotifierProvider.notifier).setGrade(level);
      },
      color: Colors.white,
      constraints: const BoxConstraints(minWidth: 130),
      itemBuilder: (BuildContext context) {
        return CorrectionGrades.grades.map((String level) {
          final isSelected = level == uiState.selectedGrade;
          return PopupMenuItem<String>(
            value: level,
            child: Text(
              level,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF4A6CF7)
                    : const Color(0xFF333333),
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        width: 130,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF5F5F5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              uiState.selectedGrade,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF666666),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 加载遮罩层
  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {},
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.3),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF15B0FC)),
                SizedBox(height: 16),
                Text(
                  '正在批改中...',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
