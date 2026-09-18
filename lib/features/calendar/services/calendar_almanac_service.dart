// 黄历 API 服务 - 对齐 Android NearbyFragment.loadCalendarInfo + WeatherHttpManager.doCalendarGet
// 天 API 黄历接口,独立 Dio 实例(不复用 DioClient 和风 key 拦截器)
// URL: https://apis.tianapi.com/lunar/index?key={token}&date={yyyy-M-d}
// 返回 ChineseCalendarBean?(code==200 时返回 result,否则 null)
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../models/chinese_calendar_bean.dart';
import '../models/xingzuo_info.dart';

class CalendarAlmanacService {
  final Dio _dio;

  /// 天 API 黄历 token - 对齐 Android CommAPI.calenderToken
  static const String _almanacToken = 'a00e87b5c90a195baef4e193388d06d0';

  /// 天 API 黄历 URL - 对齐 Android CommAPI.calenderUrl
  static const String _almanacUrl =
      'https://apis.tianapi.com/lunar/index?key=$_almanacToken';

  /// 用独立 Dio 实例(不带和风 key 拦截器) - 对齐 Android WeatherHttpManager 独立 OkHttp
  CalendarAlmanacService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              responseType: ResponseType.plain,
              headers: {
                'Connection': 'Keep-Alive',
                'Content-Type': 'application/json; charset=utf-8',
              },
            ));

  /// 查询黄历 - 对齐 Android loadCalendarInfo(date, onResult)
  /// date 格式: yyyy-MM-dd(补零,对齐天api文档示例 2019-01-13;
  /// 安卓源码拼的参数名 "&data=" 是拼写错误,天api忽略后按默认今天查询)
  /// 返回 ChineseCalendarBean?(code==200 时返回 result,否则 null;失败返回 null)
  Future<ChineseCalendarBean?> fetchAlmanac(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await _dio.get<String>(
        '$_almanacUrl&date=$dateStr',
      );
      if (response.statusCode != 200 || response.data == null) {
        return null;
      }
      // 解析 CCBean - 对齐 Android Gson().fromJson(data, CCBean::class.java)
      final decoded = jsonDecode(response.data!);
      if (decoded is! Map<String, dynamic>) return null;
      final ccBean = CCBean.fromJson(decoded);
      // 对齐 Android: fromJson.code == 200 时返回 result,否则 null
      return ccBean.code == 200 ? ccBean.result : null;
    } catch (_) {
      // 对齐 Android OnFail: 返回 null
      return null;
    }
  }

  // ===== 星座解析(本地数据) =====
  // 数据迁自安卓工程 tallynotes/src/main/assets/constellation 的 HTML 文件,
  // 已复制到本项目 assets/constellation/。页面展示格式保持 title\ngrade\ncontent。

  /// 页面星座短名 → 本地 HTML 文件名(无扩展名)。
  /// 安卓 assets 里另有 shizi.html,内容与 leo.html 同为狮子座(仅格式微差),取 leo。
  static const Map<String, String> _xingzuoFileMap = {
    '射手': 'sagittarius',
    '摩羯': 'capricornus',
    '天秤': 'libra',
    '巨蟹': 'cancer',
    '天蝎': 'scorpio',
    '狮子': 'leo',
    '处女': 'virgo',
    '双子': 'gemini',
    '金牛': 'taurus',
    '水瓶': 'aquarius',
    '双鱼': 'pisces',
    '白羊': 'aries',
  };

  /// 星座解析 - 改为读取本地 HTML(安卓 tallynotes assets/constellation),
  /// 不再请求天api xingzuo 接口。
  /// 解析规则: title 取 <title> 标签(如"白羊座分析介绍");
  /// grade 取"星座特点"字段值(如"热情活力");
  /// content 为其余字段按原顺序拼"字段：值",每字段一行。
  /// 返回 XingzuoInfo(code==200 时 result 非空;文件缺失/解析失败返回 null)
  Future<XingzuoInfo?> fetchXingzuo(String name) async {
    final file = _xingzuoFileMap[name];
    if (file == null) return null;
    try {
      final html =
          await rootBundle.loadString('assets/constellation/$file.html');
      // title: <title>白羊座分析介绍</title>(文件内含缩进空白,需 trim)
      final titleMatch =
          RegExp(r'<title>(.*?)</title>', dotAll: true).firstMatch(html);
      final title = titleMatch?.group(1)?.trim() ?? '';
      // 逐条 <p> 提取"字段：值"(span 标签剔除后按第一个全角冒号切分)
      final fields = <String, String>{};
      final ordered = <List<String>>[];
      final pMatches =
          RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true).allMatches(html);
      for (final m in pMatches) {
        final text = m.group(1)!.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        if (text.isEmpty) continue;
        final sep = text.indexOf('：');
        if (sep <= 0) continue;
        final label = text.substring(0, sep);
        final value = text.substring(sep + 1).trim();
        if (fields.containsKey(label)) continue;
        fields[label] = value;
        ordered.add([label, value]);
      }
      final grade = fields['星座特点'] ?? '';
      final contentLines = ordered
          .where((e) => e[0] != '星座特点')
          .map((e) => '${e[0]}：${e[1]}');
      return XingzuoInfo(
        code: 200,
        msg: 'local',
        result: XingzuoBean(
          title: title,
          grade: grade,
          content: contentLines.join('\n'),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
