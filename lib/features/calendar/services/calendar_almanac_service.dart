// 黄历 API 服务 - 对齐 Android NearbyFragment.loadCalendarInfo + WeatherHttpManager.doCalendarGet
// 天 API 黄历接口,独立 Dio 实例(不复用 DioClient 和风 key 拦截器)
// URL: https://apis.tianapi.com/lunar/index?key={token}&date={yyyy-M-d}
// 返回 ChineseCalendarBean?(code==200 时返回 result,否则 null)
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../core/storage/prefs_storage.dart';
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

  /// 星座解析本地缓存 key(PrefsStorage 通用 KV;撤销协议 clearAll 时一并清除)
  static const String _xingzuoCacheKey = 'xingzuo_cache_v1';

  /// 读取星座解析缓存: {星座名: {title,grade,content}}
  Map<String, dynamic> _readXingzuoCache() {
    final raw = PrefsStorage.getString(_xingzuoCacheKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  /// 星座解析成功(200)后保存到本地
  Future<void> _saveXingzuoCache(String name, XingzuoBean bean) async {
    final cache = _readXingzuoCache();
    cache[name] = {
      'title': bean.title,
      'grade': bean.grade,
      'content': bean.content,
    };
    await PrefsStorage.setString(_xingzuoCacheKey, jsonEncode(cache));
  }

  /// 星座运势 - 对齐 Android WeatherCalendarFragment.initXingZuo
  /// URL: xingzuoUrl + name，即 https://apis.tianapi.com/xingzuo/index?key={token}&me={星座名}
  /// 缓存策略(用户指定): 接口 code==200 成功时把解析保存到本地;
  /// 点击时先查本地,命中直接用本地数据不走接口,未命中才请求
  /// 返回 XingzuoInfo(code==200 时 result 非空;失败/异常返回 null)
  Future<XingzuoInfo?> fetchXingzuo(String name) async {
    // 1. 先判断本地是否有对应星座解析
    final cached = _readXingzuoCache()[name];
    if (cached is Map<String, dynamic>) {
      return XingzuoInfo(
        code: 200,
        msg: 'local cache',
        result: XingzuoBean.fromJson(cached),
      );
    }
    // 2. 本地无缓存,请求接口
    try {
      final response = await _dio.get<String>(
        'https://apis.tianapi.com/xingzuo/index',
        queryParameters: {'key': _almanacToken, 'me': name},
      );
      if (response.statusCode != 200 || response.data == null) {
        return null;
      }
      // 对齐 Android Gson().fromJson(data, XingzuoInfo::class.java)
      final decoded = jsonDecode(response.data!);
      if (decoded is! Map<String, dynamic>) return null;
      final info = XingzuoInfo.fromJson(decoded);
      // 3. 接口返回 200 成功时,把对应星座解析保存到本地
      if (info.code == 200 && info.result != null) {
        await _saveXingzuoCache(name, info.result!);
      }
      return info;
    } catch (_) {
      // 对齐 Android OnFail: 空实现
      return null;
    }
  }
}
