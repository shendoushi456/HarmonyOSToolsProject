import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:harmonyos_flutter_empty/features/translation/data/doc_translation_repository.dart';
import 'package:harmonyos_flutter_empty/features/translation/domain/doc_page_state.dart';
import 'package:harmonyos_flutter_empty/features/translation/domain/doc_trans_status.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/providers/translation_provider.dart'
    show GlobalLanguageState, globalLanguageProvider;
import 'package:harmonyos_flutter_empty/features/translation/presentation/states/doc_translation_ui_state.dart';

/// 文档翻译仓库 Provider
final Provider<DocTranslationRepository> docTranslationRepositoryProvider =
    Provider<DocTranslationRepository>((Ref ref) {
  return DocTranslationRepository();
});

/// 文档翻译 Notifier
///
/// 对应原 Android `DocTranslationViewModel`，保真状态机与翻译流程：
/// Upload → Preview → Translating → (成功)Upload / (失败)Preview
///
/// 翻译流程：上传文档 → 轮询状态（2 秒/次，最多 180 次=6 分钟）→ 下载文件。
final NotifierProvider<DocTranslationNotifier, DocTranslationUiState>
    docTranslationNotifierProvider =
    NotifierProvider<DocTranslationNotifier, DocTranslationUiState>(
  DocTranslationNotifier.new,
);

class DocTranslationNotifier extends Notifier<DocTranslationUiState> {
  /// 当前选中的文件（不放入 UiState，避免平台对象污染纯数据状态）
  XFile? _selectedFile;

  /// 取消标志（控制轮询循环）
  bool _cancelled = false;

  /// 防止同一个完成状态触发并发下载。
  bool _downloadInProgress = false;

  @override
  DocTranslationUiState build() {
    ref.listen<GlobalLanguageState>(
      globalLanguageProvider,
      (previous, next) {
        state = state.copyWith(
          fromLanguage: next.fromLanguage,
          toLanguage: next.toLanguage,
        );
      },
      fireImmediately: true,
    );
    Future<void>(_checkQuota);
    return const DocTranslationUiState();
  }

  DocTranslationRepository get _repo =>
      ref.read(docTranslationRepositoryProvider);

  /// 重新读取持久化语言设置（供应用恢复时使用）。
  Future<void> reloadLanguages() async {
    await ref.read(globalLanguageProvider.notifier).reload();
  }

  /// 检查配额
  Future<void> checkQuota() async {
    await _checkQuota();
  }

  Future<void> _checkQuota() async {
    final canUse = await _repo.canUseToday();
    final limit = _repo.getDailyLimit();
    final remaining = await _repo.getRemainingCount();
    state = state.copyWith(
      canUseToday: canUse,
      dailyLimit: limit,
      remainingCount: remaining,
    );
  }

  /// 选择文件
  Future<void> onFileSelected(XFile file) async {
    try {
      final info = await _repo.getFileInfo(file);
      final error = await _repo.validateFile(file, info.fileName);
      if (error != null) {
        state = state.copyWith(errorMessage: error);
        return;
      }
      _selectedFile = file;
      state = state.copyWith(
        pageState: DocPageState.preview,
        fileName: info.fileName,
        fileSize: info.fileSize,
        fileType: info.fileType,
        errorMessage: null,
      );
    } on Exception catch (_) {
      state = state.copyWith(errorMessage: '选择文件失败');
    }
  }

  /// 重新选择文件
  void onReselect() {
    _selectedFile = null;
    state = state.copyWith(
      pageState: DocPageState.upload,
      fileName: '',
      fileSize: 0,
      fileType: '',
      flownumber: '',
      translateStatus: 0,
      errorMessage: null,
    );
  }

  /// 开始翻译
  Future<void> startTranslation() async {
    _cancelled = false;
    state = state.copyWith(
      pageState: DocPageState.translating,
      isLoading: true,
      errorMessage: null,
    );

    try {
      // 检查配额
      if (!await _repo.canUseToday()) {
        _handleError('今日免费次数已用完');
        return;
      }

      final file = _selectedFile;
      if (file == null) {
        _handleError('请先选择文件');
        return;
      }

      // 1. 上传文档
      final uploadResponse = await _repo.uploadDocument(
        file: file,
        fileName: state.fileName,
        fileType: state.fileType,
        fromLanguage: state.fromLanguage,
        toLanguage: state.toLanguage,
      );

      final flownumber = uploadResponse.flownumber;
      if (flownumber == null || flownumber.isEmpty) {
        _handleError('上传失败');
        return;
      }

      state = state.copyWith(flownumber: flownumber);

      // 2. 轮询查询状态
      await _pollTranslationStatus(flownumber, state.fileName);
    } catch (error) {
      _handleRequestError('翻译失败', error);
    }
  }

  /// 轮询翻译状态
  ///
  /// 保真原项目：2 秒间隔，最多 180 次（6 分钟）。
  Future<void> _pollTranslationStatus(
    String flownumber,
    String fileName,
  ) async {
    const pollInterval = Duration(seconds: 2);
    const maxPollCount = 180;

    for (var i = 0; i < maxPollCount; i++) {
      if (_cancelled) {
        return;
      }

      await Future<void>.delayed(pollInterval);
      if (_cancelled) {
        return;
      }

      try {
        final response = await _repo.queryStatus(flownumber);
        state = state.copyWith(translateStatus: response.status);

        if (DocTransStatus.isCompleted(response.status)) {
          await _downloadTranslatedFile(flownumber, fileName);
          return;
        }
        if (DocTransStatus.isFailed(response.status)) {
          final message = response.msg?.trim();
          _handleError(
            '翻译失败：状态码=${response.status}'
            '${message == null || message.isEmpty ? '' : '，$message'}',
          );
          return;
        }
        // 处理中，继续轮询
      } catch (error) {
        _handleRequestError('查询失败', error);
        return;
      }
    }

    // 超时
    _handleError('翻译超时');
  }

  /// 下载翻译后的文件
  Future<void> _downloadTranslatedFile(
    String flownumber,
    String fileName,
  ) async {
    if (_downloadInProgress) {
      debugPrint('DocTranslation download skipped: already in progress');
      return;
    }
    _downloadInProgress = true;
    try {
      final savedUri = await _repo.downloadAndSaveFile(flownumber, fileName);
      await _repo.recordUsage();
      await _checkQuota();

      _selectedFile = null;
      // 下载成功后展示系统下载目录中的实际保存位置。
      state = state.copyWith(
        pageState: DocPageState.upload,
        isLoading: false,
        fileName: '',
        fileSize: 0,
        fileType: '',
        flownumber: '',
        translateStatus: 0,
        errorMessage: 'SUCCESS:翻译完成，已保存到下载目录：$savedUri',
      );
    } catch (error) {
      _handleRequestError('下载失败', error);
    } finally {
      _downloadInProgress = false;
    }
  }

  /// 处理错误
  void _handleError(String message) {
    state = state.copyWith(
      pageState: DocPageState.preview,
      isLoading: false,
      errorMessage: message,
    );
  }

  /// 在界面和调试日志中保留服务端返回的错误码与消息。
  void _handleRequestError(String prefix, Object error) {
    final detail = switch (error) {
      PlatformException(:final message?) => message,
      _ => error.toString().replaceFirst('Exception: ', ''),
    };
    debugPrint('DocTranslation $prefix: $detail');
    _handleError('$prefix：$detail');
  }

  /// 清除错误消息
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 取消翻译流程
  ///
  /// 页面关闭时调用，停止轮询循环。
  void cancelTranslation() {
    _cancelled = true;
  }
}
