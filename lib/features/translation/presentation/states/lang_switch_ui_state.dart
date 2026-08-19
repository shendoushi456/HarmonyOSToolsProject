/// 语言切换 UI 状态
///
/// 对应原 Android `LangSwitchUiState`。
/// 保真字段与默认值。
class LangSwitchUiState {
  const LangSwitchUiState({
    this.fromLanguage = '自动',
    this.toLanguage = '中文',
    this.searchQuery = '',
    this.selectionType = 0,
  });

  /// 源语言（中文名）
  final String fromLanguage;

  /// 目标语言（中文名）
  final String toLanguage;

  /// 搜索关键词
  final String searchQuery;

  /// 当前选择类型：0=源语言, 1=目标语言
  final int selectionType;

  LangSwitchUiState copyWith({
    String? fromLanguage,
    String? toLanguage,
    String? searchQuery,
    int? selectionType,
  }) {
    return LangSwitchUiState(
      fromLanguage: fromLanguage ?? this.fromLanguage,
      toLanguage: toLanguage ?? this.toLanguage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectionType: selectionType ?? this.selectionType,
    );
  }
}
