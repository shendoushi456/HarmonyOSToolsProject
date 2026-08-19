/// 翻译领域类型
///
/// 对应原 Android `DomainType` 枚举，映射到有道 API 的 `domain` 参数。
enum DomainType {
  /// 通用
  general,

  /// 医学
  medicine,

  /// 计算机
  computers,

  /// 金融
  finance,

  /// 游戏
  game,
}

/// 将 [DomainType] 映射为有道 API 的 domain 参数值
String domainTypeToString(DomainType type) {
  switch (type) {
    case DomainType.general:
      return 'general';
    case DomainType.medicine:
      return 'medicine';
    case DomainType.computers:
      return 'computers';
    case DomainType.finance:
      return 'finance';
    case DomainType.game:
      return 'game';
  }
}
