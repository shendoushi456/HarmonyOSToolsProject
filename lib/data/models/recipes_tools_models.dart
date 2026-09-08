/// toolbox_c recipes_module / calculatorlibrary 数据模型迁移。
/// 对应 Android：CaiPinFenLeiBean / DiKaTuiJianBean / HeathTipBean / TiZhiBean。
/// 数据与业务规则独立于 UI，便于整体马甲包替换页面层。

/// 菜谱分类项 —— 对应 CaiPinFenLeiBean(caipinPic, caiPinName, id)。
class CaiPinFenLeiItem {
  const CaiPinFenLeiItem({
    required this.imagePath,
    required this.name,
    required this.id,
  });

  final String imagePath;
  final String name;

  /// 传给 RecipesListActivity 的 "p" 参数（原样保留安卓的取值，含历史错位）。
  final String id;
}

/// 低卡食品推荐项 —— 对应 DiKaTuiJianBean(pic, name, kaluli)。
class DiKaTuiJianItem {
  const DiKaTuiJianItem({
    required this.imagePath,
    required this.name,
    required this.kaluli,
  });

  final String imagePath;
  final String name;
  final String kaluli;
}

/// 卡路里查询 8 大分类入口 —— 对应 CalorieSearchListActivity 的 8 个
/// ImageView，点击携带 "shipu" 参数（"1"~"8"）进入 SPuActivity。
class CalorieCategoryItem {
  const CalorieCategoryItem({
    required this.imagePath,
    required this.shipuExtra,
  });

  final String imagePath;
  final String shipuExtra;
}

/// 健康小妙招项 —— 对应 HeathTipBean(name, guanzhu, corver, title, content)。
/// 安卓里是 string/drawable 资源 id，这里直接展开为字符串与图片路径。
class HeathTipItem {
  const HeathTipItem({
    required this.name,
    required this.guanzhu,
    required this.coverPath,
    required this.title,
    required this.content,
  });

  final String name;
  final String guanzhu;
  final String coverPath;
  final String title;
  final String content;
}

/// 体脂率计算结果 —— 对应 TiZhiBean(bfr, normbfr, idealweight, normweight, healthy, tip)。
class TiZhiResult {
  const TiZhiResult({
    required this.bfr,
    required this.normbfr,
    required this.idealweight,
    required this.normweight,
    required this.healthy,
    required this.tip,
  });

  factory TiZhiResult.fromJson(Map<String, dynamic> json) => TiZhiResult(
        bfr: json['bfr']?.toString() ?? '',
        normbfr: json['normbfr']?.toString() ?? '',
        idealweight: json['idealweight']?.toString() ?? '',
        normweight: json['normweight']?.toString() ?? '',
        healthy: json['healthy']?.toString() ?? '',
        tip: json['tip']?.toString() ?? '',
      );

  final String bfr;
  final String normbfr;
  final String idealweight;
  final String normweight;
  final String healthy;
  final String tip;
}
