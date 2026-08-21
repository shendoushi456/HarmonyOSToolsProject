// 黄历 API 服务 - 对齐 Android NearbyFragment.loadCalendarInfo + WeatherHttpManager.doCalendarGet
// 天 API 黄历接口,独立 Dio 实例(不复用 DioClient 和风 key 拦截器)
// URL: https://apis.tianapi.com/lunar/index?key={token}&date={yyyy-M-d}
// 返回 ChineseCalendarBean?(code==200 时返回 result,否则 null)
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/chinese_calendar_bean.dart';

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
  /// date 格式: yyyy-M-d(不补零,对齐 Android "${year}-${month}-${day}")
  /// 返回 ChineseCalendarBean?(code==200 时返回 result,否则 null;失败返回 null)
  Future<ChineseCalendarBean?> fetchAlmanac(DateTime date) async {
    try {
      // 对齐 Android date 格式: "${year}-${month}-${day}"(不补零)
      final dateStr = DateFormat('y-M-d').format(date);
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
}
