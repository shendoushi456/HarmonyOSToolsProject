import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/features/translation/domain/translate_data.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/providers/translation_provider.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/states/translation_ui_state.dart';

/// 最大输入字符数（保真原 `MAX_INPUT_LENGTH = 3000`）
const int _maxInputLength = 3000;

/// 背景色（保真原 `Color(0xFFEEF1F8)`）
const Color _pageBackground = Color(0xFFEEF1F8);

/// 主题蓝（保真原 `Color(0xFF4A6CF7)`）
const Color _primaryBlue = Color(0xFF4A6CF7);

/// 语言选择卡片背景色（保真原 `Color(0xFFD4DCF8)`）
const Color _languageCardBackground = Color(0xFFD4DCF8);

/// 文本翻译首页
///
/// 对应原 Android `TextTranslationFragment`（toolbox_c Compose 版），保真还原：
/// 顶部翻译图标 + 语言选择卡片（源语言/交换/目标语言）+
/// 输入卡片（标题/虚线分隔/违规提示/输入框/字数统计）+ 翻译按钮 + Loading 遮罩。
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
    },);
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
    },);
    if (mounted) {
      await ref.read(translationNotifierProvider.notifier).reloadLanguages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(translationNotifierProvider);
    final double topGap = math.max(
      0,
      60 - MediaQuery.of(context).padding.top,
    );

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
      backgroundColor: _pageBackground,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: topGap),
                // 顶部翻译图标
                SizedBox(
                  height: 132,
                  width: double.infinity,
                  child: Center(
                    child: Image.asset(
                      'assets/images/ic_trans_text_header.webp',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 39),
                _buildLanguageCard(uiState),
                const SizedBox(height: 20),
                Expanded(child: _buildInputCard(uiState)),
                const SizedBox(height: 20),
                _buildTranslateButton(uiState),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (uiState.isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  /// 语言选择卡片：源语言按钮 + 交换图标 + 目标语言按钮
  Widget _buildLanguageCard(TranslationUiState uiState) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _languageCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 源语言按钮
          _buildLanguageButton(uiState.fromLanguage, () {
            _navigateToLangSwitch(0);
          }),
          const SizedBox(width: 16),
          // 交换图标（保真：原项目交换图标点击也是打开源语言选择）
          GestureDetector(
            onTap: () {
              _navigateToLangSwitch(0);
            },
            child: Image.asset(
              'assets/images/ic_trans_switch.webp',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          // 目标语言按钮
          _buildLanguageButton(uiState.toLanguage, () {
            _navigateToLangSwitch(1);
          }),
        ],
      ),
    );
  }

  /// 语言按钮（蓝色胶囊 + 下拉箭头）
  Widget _buildLanguageButton(String language, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: _primaryBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// 输入区域卡片
  Widget _buildInputCard(TranslationUiState uiState) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题文字
          const Center(
            child: Text(
              '输入需要翻译的文字',
              style: TextStyle(
                fontSize: 18,
                color: _primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 分隔线（虚线）
          const _DashedDivider(),
          const SizedBox(height: 12),
          // 提示文字
          const Text(
            '*请勿输入"涉政、涉恐、涉密"等违规内容',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 16),
          // 文本输入框
          Expanded(child: _buildInputField(uiState)),
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
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF999999),
                ),
              ),
            ),
          ),
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
        fontSize: 16,
        color: Color(0xFF333333),
      ),
      decoration: InputDecoration(
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        hintText: _inputController.text.isEmpty ? '在此输入要翻译的内容...' : null,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: Color(0xFFCCCCCC),
        ),
      ),
      onChanged: (value) {
        // 保真：超过最大输入字符数时不接受输入
        if (value.length <= _maxInputLength) {
          setState(() {});
        } else {
          _inputController
            ..text = value.substring(0, _maxInputLength)
            ..selection = TextSelection.fromPosition(
              const TextPosition(offset: _maxInputLength),
            );
        }
      },
    );
  }

  /// 翻译按钮
  Widget _buildTranslateButton(TranslationUiState uiState) {
    final enabled =
        !uiState.isLoading && _inputController.text.trim().isNotEmpty;
    return GestureDetector(
      onTap: enabled
          ? () {
              ref
                  .read(translationNotifierProvider.notifier)
                  .translate(_inputController.text);
            }
          : null,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: uiState.isLoading
              ? const Color(0xFFB0B8E8)
              : _primaryBlue,
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D4A6CF7),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            uiState.isLoading ? '翻译中...' : '翻译',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Loading 遮罩（保真原半透明遮罩 + 进度条，阻止点击穿透）
  Widget _buildLoadingOverlay() {
    return GestureDetector(
      onTap: () {},
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.3),
        child: const Center(
          child: CircularProgressIndicator(
            color: _primaryBlue,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}

/// 虚线分隔线（保真原 `PathEffect.dashPathEffect(intervals = [8f, 6f])`）
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const double dashWidth = 8;
    const double dashGap = 6;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(math.min(x + dashWidth, size.width), size.height / 2),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
