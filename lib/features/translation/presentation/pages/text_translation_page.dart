import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/core/theme/app_colors.dart';
import 'package:harmonyos_flutter_empty/features/translation/domain/translate_data.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/providers/translation_provider.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/states/translation_ui_state.dart';

/// 最大输入字符数（保真原 `MAX_INPUT_LENGTH = 3000`）
const int _maxInputLength = 3000;

/// 文本翻译首页
///
/// 对应原 Android `TextTranslationFragment`，保真还原 Compose UI：
/// 顶部蓝色标题栏 + 翻译图标 + 输入卡片（含语言选择器/全屏按钮/翻译按钮）+ Loading 遮罩。
class TextTranslationPage extends ConsumerStatefulWidget {
  const TextTranslationPage({super.key});

  @override
  ConsumerState<TextTranslationPage> createState() =>
      _TextTranslationPageState();
}

class _TextTranslationPageState extends ConsumerState<TextTranslationPage> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 对应原 onResume → reloadLanguages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(translationNotifierProvider.notifier).reloadLanguages();
    });
  }

  void _navigateToDetail(TranslateData latest, TranslationUiState uiState) {
    context.push('/text_detail', extra: <String, dynamic>{
      'sourceText': latest.getQuery(),
      'translatedText': latest.translates().trim(),
      'sourceLanguage': uiState.fromLanguage,
      'targetLanguage': uiState.toLanguage,
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  /// 跳转语言选择页，返回后刷新语言设置（保真原 onResume → reloadLanguages）
  Future<void> _navigateToLangSwitch(int selectionType) async {
    await context.push('/lang_switch', extra: <String, dynamic>{
      'selectionType': selectionType,
    });
    if (mounted) {
      await ref.read(translationNotifierProvider.notifier).reloadLanguages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(translationNotifierProvider);

    // 监听翻译历史变化，翻译成功后跳转详情页（保真原 LaunchedEffect）
    ref.listen<TranslationUiState>(translationNotifierProvider,
        (TranslationUiState? previous, TranslationUiState next) {
      // 翻译成功跳详情页
      if (next.translateHistory.isNotEmpty &&
          !next.isLoading &&
          next.translateHistory.length >
              (previous?.translateHistory.length ?? 0)) {
        _navigateToDetail(next.translateHistory.last, next);
      }
      // 错误消息 Toast
      if (next.errorMessage != null) {
        _showToast(next.errorMessage!);
        ref.read(translationNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopSection(),
              const SizedBox(height: 20),
              Expanded(
                child: _buildInputCard(uiState),
              ),
              const SizedBox(height: 20),
            ],
          ),
          if (uiState.isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  /// 顶部区域：蓝色标题栏 + 翻译图标
  Widget _buildTopSection() {
    return Column(
      children: [
        Container(
          color: AppColors.primaryBlue,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 80,
              child: Center(
                child: const Text(
                  '文本翻译',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Image.asset(
            'assets/images/ic_trans_text_header.png',
            height: 156,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }

  /// 翻译输入卡片
  Widget _buildInputCard(TranslationUiState uiState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryBlue, width: 1),
              ),
              child: Column(
                children: [
                  // 输入框
                  Expanded(
                    child: _buildInputField(uiState),
                  ),
                  // 字数统计
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${_inputController.text.length}/$_maxInputLength',
                        style: TextStyle(
                          fontSize: 12,
                          color: _inputController.text.length >= _maxInputLength
                              ? AppColors.counterOverLimit
                              : AppColors.counterGray,
                        ),
                      ),
                    ),
                  ),
                  // 底部操作栏：语言选择器 + 全屏按钮
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLanguageSelector(uiState),
                        _buildFullScreenButton(uiState),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildTranslateButton(uiState),
        ],
      ),
    );
  }

  /// 输入框（含占位提示）
  Widget _buildInputField(TranslationUiState uiState) {
    return TextField(
      controller: _inputController,
      enabled: !uiState.isLoading,
      maxLines: null,
      expands: true,
      style: const TextStyle(
        fontSize: 18,
        color: AppColors.inputText,
      ),
      decoration: InputDecoration(
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        hintText: _inputController.text.isEmpty ? '输入需要翻译的文字' : null,
        hintStyle: const TextStyle(
          fontSize: 18,
          color: AppColors.hintText,
        ),
      ),
      onChanged: (value) {
        // 保真：限制最大输入字符数
        if (value.length <= _maxInputLength) {
          setState(() {});
        } else {
          // 超限不输入
          _inputController.text = value.substring(0, _maxInputLength);
          _inputController.selection = TextSelection.fromPosition(
            TextPosition(offset: _maxInputLength),
          );
        }
      },
    );
  }

  /// 语言选择器（源/交换/目标）
  Widget _buildLanguageSelector(TranslationUiState uiState) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.languageSelectorBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 源语言
          GestureDetector(
            onTap: () => _navigateToLangSwitch(0),
            child: Text(
              uiState.fromLanguage,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // 交换按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => _navigateToLangSwitch(0),
              child: Image.asset(
                'assets/images/ic_trans_switch.png',
                width: 10,
                height: 10,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          // 目标语言
          GestureDetector(
            onTap: () => _navigateToLangSwitch(1),
            child: Text(
              uiState.toLanguage,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 全屏按钮
  Widget _buildFullScreenButton(TranslationUiState uiState) {
    return GestureDetector(
      onTap: uiState.isLoading
          ? null
          : () {
              if (_inputController.text.trim().isNotEmpty) {
                context.push('/original', extra: <String, dynamic>{
                  'originalText': _inputController.text,
                });
              }
            },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          'assets/images/ic_trans_full_screen.png',
          width: 20,
          height: 20,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  /// 开始翻译按钮
  Widget _buildTranslateButton(TranslationUiState uiState) {
    return GestureDetector(
      onTap: uiState.isLoading
          ? null
          : () {
              final text = _inputController.text;
              if (text.trim().isNotEmpty) {
                ref
                    .read(translationNotifierProvider.notifier)
                    .translate(text);
              } else {
                _showToast('请输入要翻译的文本');
              }
            },
      child: Container(
        width: 180,
        height: 39,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            colors: uiState.isLoading
                ? [AppColors.buttonLoadingGray, AppColors.buttonLoadingGray]
                : [AppColors.buttonGradientStart, AppColors.buttonGradientEnd],
          ),
        ),
        child: Center(
          child: Text(
            uiState.isLoading ? '翻译中...' : '开始翻译',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Loading 遮罩（保真原半透明遮罩 + 进度条）
  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColors.loadingOverlay,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.loadingIndicator,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
