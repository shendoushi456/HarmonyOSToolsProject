// 黄历数据模型 - 对齐 Android ChineseCalendarBean.kt
// 天 API 黄历接口返回的数据结构,含 22 字段
import 'package:flutter/foundation.dart';

/// 天 API 黄历响应根 Bean - 对齐 Android CCBean
@immutable
class CCBean {
  final int code;
  final ChineseCalendarBean? result;

  const CCBean({required this.code, this.result});

  factory CCBean.fromJson(Map<String, dynamic> json) {
    return CCBean(
      code: json['code'] is int ? json['code'] as int : int.tryParse(json['code']?.toString() ?? '0') ?? 0,
      result: json['result'] != null
          ? ChineseCalendarBean.fromJson(json['result'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 黄历详情 - 对齐 Android ChineseCalendarBean（22 字段）
@immutable
class ChineseCalendarBean {
  /// 农历节日（如"腊八节"）
  final String lunarFestival;

  /// 公历节日
  final String festival;

  /// 宜
  final String fitness;

  /// 忌
  final String taboo;

  /// 神位
  final String shenwei;

  /// 胎神
  final String taishen;

  /// 冲煞
  final String chongsha;

  /// 岁煞
  final String suisha;

  /// 五行甲子
  final String wuxingjiazi;

  /// 五行纳音年
  final String wuxingnayear;

  /// 五行纳音月
  final String wuxingnamonth;

  /// 星宿
  final String xingsu;

  /// 彭祖
  final String pengzu;

  /// 建神
  final String jianshen;

  /// 天干地支年
  final String tiangandizhiyear;

  /// 天干地支月
  final String tiangandizhimonth;

  /// 天干地支日
  final String tiangandizhiday;

  /// 月份名
  final String lmonthname;

  /// 生肖
  final String shengxiao;

  /// 农历月份
  final String lubarmonth;

  /// 农历日
  final String lunarday;

  /// 节气
  final String jieqi;

  const ChineseCalendarBean({
    required this.lunarFestival,
    required this.festival,
    required this.fitness,
    required this.taboo,
    required this.shenwei,
    required this.taishen,
    required this.chongsha,
    required this.suisha,
    required this.wuxingjiazi,
    required this.wuxingnayear,
    required this.wuxingnamonth,
    required this.xingsu,
    required this.pengzu,
    required this.jianshen,
    required this.tiangandizhiyear,
    required this.tiangandizhimonth,
    required this.tiangandizhiday,
    required this.lmonthname,
    required this.shengxiao,
    required this.lubarmonth,
    required this.lunarday,
    required this.jieqi,
  });

  factory ChineseCalendarBean.fromJson(Map<String, dynamic> json) {
    return ChineseCalendarBean(
      lunarFestival: json['lunar_festival']?.toString() ?? '',
      festival: json['festival']?.toString() ?? '',
      fitness: json['fitness']?.toString() ?? '',
      taboo: json['taboo']?.toString() ?? '',
      shenwei: json['shenwei']?.toString() ?? '',
      taishen: json['taishen']?.toString() ?? '',
      chongsha: json['chongsha']?.toString() ?? '',
      suisha: json['suisha']?.toString() ?? '',
      wuxingjiazi: json['wuxingjiazi']?.toString() ?? '',
      wuxingnayear: json['wuxingnayear']?.toString() ?? '',
      wuxingnamonth: json['wuxingnamonth']?.toString() ?? '',
      xingsu: json['xingsu']?.toString() ?? '',
      pengzu: json['pengzu']?.toString() ?? '',
      jianshen: json['jianshen']?.toString() ?? '',
      tiangandizhiyear: json['tiangandizhiyear']?.toString() ?? '',
      tiangandizhimonth: json['tiangandizhimonth']?.toString() ?? '',
      tiangandizhiday: json['tiangandizhiday']?.toString() ?? '',
      lmonthname: json['lmonthname']?.toString() ?? '',
      shengxiao: json['shengxiao']?.toString() ?? '',
      lubarmonth: json['lubarmonth']?.toString() ?? '',
      lunarday: json['lunarday']?.toString() ?? '',
      jieqi: json['jieqi']?.toString() ?? '',
    );
  }
}
