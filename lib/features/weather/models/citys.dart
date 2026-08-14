// 热门城市数据模型 - 对齐 Android Citys.kt + SearchCityBean.kt
// 用于城市选择页的热门城市列表与搜索结果
import 'dart:convert';

/// 热门城市项 - 对应 Android Citys.kt
class Citys {
  /// 城市 ID(如 "1")
  final String id;

  /// 省份(如 "北京")
  final String province;

  /// 城市(如 "北京")
  final String city;

  /// 区县(如 "海淀") - 搜索匹配字段
  final String district;

  const Citys({
    required this.id,
    required this.province,
    required this.city,
    required this.district,
  });

  factory Citys.fromJson(Map<String, dynamic> json) {
    return Citys(
      id: json['id']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'province': province,
        'city': city,
        'district': district,
      };
}

/// hot_city.json 解析容器 - 对应 Android SearchCityBean.kt
/// JSON 结构: {"reason":"查询成功","result":[{...},{...}]}
class HotCityResult {
  /// 响应说明(如 "查询成功")
  final String reason;

  /// 城市列表
  final List<Citys> result;

  const HotCityResult({required this.reason, required this.result});

  /// 从 JSON 字符串解析 - 对齐 SearchViewModel.getHopCity 的 Gson 解析
  factory HotCityResult.fromJsonString(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final list = (map['result'] as List? ?? [])
          .map((e) => Citys.fromJson(e as Map<String, dynamic>))
          .toList();
      return HotCityResult(
        reason: map['reason']?.toString() ?? '',
        result: list,
      );
    } catch (_) {
      // 解析失败返回空列表,对齐 Android 容错
      return const HotCityResult(reason: '', result: []);
    }
  }
}
