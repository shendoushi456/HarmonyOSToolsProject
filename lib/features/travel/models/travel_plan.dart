// 旅行规划数据模型 - 对齐 Android ViewpointFragment.kt 末尾的 TravelPlan + TravelAction
// 纯 UI 展示页，无 ViewModel/Repository

/// 旅行行动类型枚举 - 对齐 Android TravelAction
enum TravelAction {
  /// 迪士尼度假区（跳转迪士尼攻略页）
  disney,
  /// 图片攻略（跳转 EditorPicTipsPage，需传 guideType）
  imageGuide,
  /// 乐山峨眉攻略（跳转乐山攻略页）
  leshanGuide,
}

/// 旅行规划项 - 对齐 Android TravelPlan data class
class TravelPlan {
  const TravelPlan({
    required this.title,
    required this.description,
    required this.image,
    required this.action,
    this.guideType,
  });

  /// 标题（如"上海 迪士尼度假区"）
  final String title;

  /// 描述（如"梦幻的童话世界..."）
  final String description;

  /// 图片资源路径（Flutter 端为 String，对应 AppAssets.travelXxx）
  final String image;

  /// 点击行为
  final TravelAction action;

  /// 图片攻略类型（仅 action == imageGuide 时有效）
  /// 取值：外滩/故宫博物院/环球度假区/八达岭长城/兵马俑/九寨沟/西湖
  final String? guideType;
}
