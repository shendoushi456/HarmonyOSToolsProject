// QxAir 空气质量页 UI 状态 - 对齐 Android QxUiModels.kt 中 QxAirUiState 部分
// 迁移自 toolbox_c toolsbox_moduel weather/air 对应数据模型

/// 污染物条目（对齐 Android PollutantUi）
class QxPollutantUi {
  final String name;
  final String value;
  final String iconPath;

  const QxPollutantUi({
    required this.name,
    required this.value,
    required this.iconPath,
  });
}

/// 生活指数条目（对齐 Android LifeIndexUi）
class QxLifeIndexUi {
  final String title;
  final String value;
  final String iconPath;

  const QxLifeIndexUi({
    required this.title,
    required this.value,
    required this.iconPath,
  });
}

/// 空气质量页整体状态（对齐 Android QxAirUiState，默认值一致）
class QxAirUiState {
  final bool loading;
  final int aqi;
  final String category;
  final List<QxPollutantUi> pollutants;
  final List<QxLifeIndexUi> lifeIndexes;
  final String tipTitle;
  final String tipBody;
  final String? error;

  const QxAirUiState({
    this.loading = true,
    this.aqi = 80,
    this.category = '良',
    this.pollutants = const [],
    this.lifeIndexes = const [],
    this.tipTitle = '生活小窍门',
    this.tipBody =
        '若有小面积皮肤损伤或烧伤、烫伤，抹上少许牙膏，可立即止血止痛，也可防止感染，疗效颇佳。',
    this.error,
  });

  /// 对齐 Android QxAirUiState.copy(loading = true)：保留已有展示字段仅切换加载态
  QxAirUiState copyWith({bool? loading}) {
    return QxAirUiState(
      loading: loading ?? this.loading,
      aqi: aqi,
      category: category,
      pollutants: pollutants,
      lifeIndexes: lifeIndexes,
      tipTitle: tipTitle,
      tipBody: tipBody,
      error: error,
    );
  }
}
