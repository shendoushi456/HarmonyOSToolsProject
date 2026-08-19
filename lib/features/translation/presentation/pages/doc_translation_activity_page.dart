import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/core/theme/app_colors.dart';
import 'package:harmonyos_flutter_empty/features/translation/domain/doc_page_state.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/providers/doc_translation_provider.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/states/doc_translation_ui_state.dart';

/// 文档翻译 Activity 页面
///
/// 对应原 Android `DocTranslationActivity`，保真还原 3 状态页面：
/// Upload（上传）/ Preview（预览）/ Translating（翻译中 + Loading 覆盖层）。
///
/// 文件选择使用 file_selector（ohos 适配），翻译流程由
/// [DocTranslationNotifier] 驱动：上传 → 轮询 → 下载。
class DocTranslationActivityPage extends ConsumerStatefulWidget {
  const DocTranslationActivityPage({super.key});

  @override
  ConsumerState<DocTranslationActivityPage> createState() =>
      _DocTranslationActivityPageState();
}

class _DocTranslationActivityPageState
    extends ConsumerState<DocTranslationActivityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(docTranslationNotifierProvider.notifier);
      notifier.reloadLanguages();
      notifier.checkQuota();
    });
  }

  @override
  void dispose() {
    // 保真原 onCancelTranslation：页面关闭时取消轮询
    ref.read(docTranslationNotifierProvider.notifier).cancelTranslation();
    super.dispose();
  }

  /// 打开文件选择器
  Future<void> _pickFile() async {
    final XFile? file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[
        XTypeGroup(label: '文档', extensions: ['pdf', 'doc', 'docx']),
      ],
    );
    if (file != null) {
      await ref
          .read(docTranslationNotifierProvider.notifier)
          .onFileSelected(file);
    }
  }

  void _showToast(String message, {bool long = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration:
              long ? const Duration(seconds: 4) : const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(docTranslationNotifierProvider);

    // 监听错误/成功消息
    ref.listen<DocTranslationUiState>(docTranslationNotifierProvider,
        (DocTranslationUiState? previous, DocTranslationUiState next) {
      final msg = next.errorMessage;
      if (msg != null) {
        if (msg.startsWith('SUCCESS:')) {
          _showToast(msg.substring(8), long: true);
        } else {
          _showToast(msg);
        }
        ref.read(docTranslationNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FE),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildPageContent(uiState)),
            ],
          ),
          // Loading 覆盖层
          if (uiState.pageState == DocPageState.translating)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }

  /// 顶部标题栏
  Widget _buildTopBar() {
    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Stack(
            children: [
              Positioned(
                left: 18,
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
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  '文档翻译',
                  style: TextStyle(
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

  /// 根据页面状态显示内容
  Widget _buildPageContent(DocTranslationUiState uiState) {
    switch (uiState.pageState) {
      case DocPageState.upload:
        return _UploadPage(onUploadClick: _pickFile);
      case DocPageState.preview:
      case DocPageState.translating:
        // Translating 状态显示 Preview 页面（禁用回调）+ Loading 覆盖层
        final isTranslating = uiState.pageState == DocPageState.translating;
        return _PreviewPage(
          fileName: uiState.fileName,
          canUseToday: uiState.canUseToday,
          dailyLimit: uiState.dailyLimit,
          remainingCount: uiState.remainingCount,
          onReselectClick:
              isTranslating ? () {} : () => ref.read(docTranslationNotifierProvider.notifier).onReselect(),
          onStartTranslateClick: isTranslating
              ? () {}
              : () => ref
                  .read(docTranslationNotifierProvider.notifier)
                  .startTranslation(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Loading 覆盖层
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '翻译中...',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// 上传页面
class _UploadPage extends StatelessWidget {
  const _UploadPage({required this.onUploadClick});

  final VoidCallback onUploadClick;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 27),
          Container(
            width:double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 34),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBlue, width: 1),
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/ic_trans_doc.png',
                  width: 138,
                  height: 138,
                ),
                const SizedBox(height: 38),
                const Text(
                  '支持pdf/doc/docx格式≤10MB',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6D6D6D),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _GradientButton(
            label: '上传文档',
            width: 196,
            height: 42,
            fontSize: 18,
            onTap: onUploadClick,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

/// 预览页面
class _PreviewPage extends StatelessWidget {
  const _PreviewPage({
    required this.fileName,
    required this.canUseToday,
    required this.dailyLimit,
    required this.remainingCount,
    required this.onReselectClick,
    required this.onStartTranslateClick,
  });

  final String fileName;
  final bool canUseToday;
  final int dailyLimit;
  final int remainingCount;
  final VoidCallback onReselectClick;
  final VoidCallback onStartTranslateClick;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 27),
          // 文件预览卡片
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            height: 390,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 59),
                Image.asset(
                  'assets/images/ic_trans_doc_add.png',
                  width: 226,
                  height: 226,
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF167CFC),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                // 重新上传
                GestureDetector(
                  onTap: onReselectClick,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.refresh,
                          size: 18,
                          color: AppColors.langSwitchText,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '重新上传',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.langSwitchText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 38),
          Text(
            '可免费使用$dailyLimit次/日',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.langSwitchText,
              height: 17 / 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '今日剩余$remainingCount次',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.counterGray,
              height: 17 / 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _GradientButton(
            label: '开始翻译',
            width: 196,
            height: 42,
            fontSize: 18,
            enabled: canUseToday,
            onTap: onStartTranslateClick,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

/// 渐变按钮（上传文档 / 开始翻译 通用）
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.width,
    required this.height,
    required this.fontSize,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final double width;
  final double height;
  final double fontSize;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: width,
        height: height,
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
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: enabled ? 1.0 : 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
