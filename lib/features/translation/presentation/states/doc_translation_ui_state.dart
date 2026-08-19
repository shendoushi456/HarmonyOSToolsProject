import 'package:harmonyos_flutter_empty/features/translation/domain/doc_page_state.dart';

/// 文档翻译 UI 状态
///
/// 对应原 Android `DocTranslationUiState`，保真字段与默认值。
class DocTranslationUiState {
  const DocTranslationUiState({
    this.pageState = DocPageState.upload,
    this.fromLanguage = '中文',
    this.toLanguage = '英文',
    this.fileName = '',
    this.fileSize = 0,
    this.fileType = '',
    this.flownumber = '',
    this.translateStatus = 0,
    this.isLoading = false,
    this.errorMessage,
    this.canUseToday = true,
    this.dailyLimit = 1,
    this.remainingCount = 1,
  });

  /// 页面状态
  final DocPageState pageState;

  /// 源语言（中文名）
  final String fromLanguage;

  /// 目标语言（中文名）
  final String toLanguage;

  /// 文件名
  final String fileName;

  /// 文件大小（字节）
  final int fileSize;

  /// 文件类型（pdf/doc/docx）
  final String fileType;

  /// 翻译流程号
  final String flownumber;

  /// 翻译状态码
  final int translateStatus;

  /// 是否加载中
  final bool isLoading;

  /// 错误消息（"SUCCESS:" 前缀表示成功提示，保真原项目约定）
  final String? errorMessage;

  /// 今日是否可用
  final bool canUseToday;

  /// 每日限制次数
  final int dailyLimit;

  /// 今日剩余次数
  final int remainingCount;

  DocTranslationUiState copyWith({
    DocPageState? pageState,
    String? fromLanguage,
    String? toLanguage,
    String? fileName,
    int? fileSize,
    String? fileType,
    String? flownumber,
    int? translateStatus,
    bool? isLoading,
    String? errorMessage,
    bool? canUseToday,
    int? dailyLimit,
    int? remainingCount,
  }) {
    return DocTranslationUiState(
      pageState: pageState ?? this.pageState,
      fromLanguage: fromLanguage ?? this.fromLanguage,
      toLanguage: toLanguage ?? this.toLanguage,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      flownumber: flownumber ?? this.flownumber,
      translateStatus: translateStatus ?? this.translateStatus,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      canUseToday: canUseToday ?? this.canUseToday,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      remainingCount: remainingCount ?? this.remainingCount,
    );
  }
}
