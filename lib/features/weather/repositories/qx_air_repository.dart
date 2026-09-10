// QxAir 空气质量数据仓库 - 对齐 Android QxAirRepository.kt
// 城市 → 空气质量(8s容错) + 7d预报(兜底生活指数) + 和风生活指数接口 + 本地小窍门轮询
import 'package:flutter/services.dart' show rootBundle;

import '../../../core/constants/app_assets.dart';
import '../../../core/storage/prefs_storage.dart';
import '../models/city_bean.dart';
import '../models/qx_air_ui_state.dart';
import '../models/weather_dto.dart';
import '../models/weather_city_dto.dart';
import '../repositories/city_repository.dart';
import '../repositories/weather_repository.dart';

class QxAirRepository {
  final WeatherRepository _weatherRepository;
  final CityRepository _cityRepository;

  QxAirRepository({
    WeatherRepository? weatherRepository,
    CityRepository? cityRepository,
  })  : _weatherRepository = weatherRepository ?? WeatherRepository(),
        _cityRepository = cityRepository ?? CityRepository();

  /// 加载空气质量页数据（对齐 Android QxAirRepository.loadAir）
  Future<QxAirUiState> loadAir() async {
    final city = await _selectedCity();
    final location = await _runCatching(
      () => _weatherRepository
          .resolveCity(city.cityName)
          .timeout(const Duration(seconds: 5)),
      fallback: () => _defaultLocation(city.cityName),
    );
    final air = await _runCatchingNull(() async {
      final dto = await _weatherRepository
          .loadAirNowDto(location.id)
          .timeout(const Duration(seconds: 8));
      return dto.now;
    });
    final today = await _runCatchingNull(() async {
      final dto = await _weatherRepository
          .load7d(location.id)
          .timeout(const Duration(seconds: 8));
      return dto.daily.isNotEmpty ? dto.daily.first : null;
    });
    final tip = await _loadLifeTip();

    return QxAirUiState(
      loading: false,
      aqi: air?.aqi ?? 80,
      category: air?.category ?? '良',
      pollutants: _pollutantModels(air),
      lifeIndexes: await _loadLifeIndexes(location.id, today),
      tipTitle: tip.title,
      tipBody: tip.body,
      error: air == null ? '空气质量数据暂未更新，已显示参考信息' : null,
    );
  }

  /// 当前选中城市（对齐 Android QxCityStore.selectedCity）
  Future<CityBean> _selectedCity() async {
    final cities = await _cityRepository.loadCities();
    if (cities.isEmpty) return CityBean.defaultCity();
    final index = _cityRepository.loadPosition();
    return cities[index.clamp(0, cities.length - 1)];
  }

  /// 默认位置（对齐 Android defaultLocation：城市名 + 北京城市ID）
  CityLocationDTO _defaultLocation(String cityName) {
    return CityLocationDTO(
      name: cityName.isNotEmpty ? cityName : '北京',
      id: '101010100',
      fxLink: '',
      latitude: '',
      longitude: '',
    );
  }

  /// 污染物列表（对齐 Android pollutantModels：顺序 pm2.5/so2/pm10/co/no2/o3）
  List<QxPollutantUi> _pollutantModels(AirbeanDTO? air) {
    return [
      QxPollutantUi(
        name: '细颗粒物',
        value: air?.pm2p5.isNotEmpty == true ? air!.pm2p5 : '18',
        iconPath: AppAssets.qxAirPm25,
      ),
      QxPollutantUi(
        name: '二氧化硫',
        value: air?.so2.isNotEmpty == true ? air!.so2 : '5',
        iconPath: AppAssets.qxAirSo2,
      ),
      QxPollutantUi(
        name: '粗颗粒度',
        value: air?.pm10.isNotEmpty == true ? air!.pm10 : '56',
        iconPath: AppAssets.qxAirPm10,
      ),
      QxPollutantUi(
        name: '一氧化碳',
        value: air?.co.isNotEmpty == true ? air!.co : '0.4',
        iconPath: AppAssets.qxAirCo,
      ),
      QxPollutantUi(
        name: '二氧化氮',
        value: air?.no2.isNotEmpty == true ? air!.no2 : '8',
        iconPath: AppAssets.qxAirNo2,
      ),
      QxPollutantUi(
        name: '臭氧',
        value: air?.o3.isNotEmpty == true ? air!.o3 : '82',
        iconPath: AppAssets.qxAirO3,
      ),
    ];
  }

  /// 生活指数：优先和风 indices 接口，失败回退本地计算（对齐 Android loadLifeIndexes）
  Future<List<QxLifeIndexUi>> _loadLifeIndexes(
      String cityId, Weather7DDTO? today) async {
    Map<String, dynamic>? payload;
    try {
      payload = await _weatherRepository
          .loadLifeIndices(cityId)
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      payload = null;
    }
    final remote = payload == null ? const <QxLifeIndexUi>[] : _parseLifeIndexes(payload);
    return remote.isNotEmpty ? remote : _fallbackLifeIndexes(today);
  }

  /// 解析和风生活指数（对齐 Android parseLifeIndexes：type 分组 + 全部非空才采用）
  List<QxLifeIndexUi> _parseLifeIndexes(Map<String, dynamic> payload) {
    if (payload['code']?.toString() != '200') return const [];
    final daily = payload['daily'];
    if (daily is! List) return const [];
    final byType = <String, Map<String, dynamic>>{};
    for (final item in daily) {
      if (item is Map<String, dynamic>) {
        byType[item['type']?.toString() ?? ''] = item;
      }
    }

    final items = [
      _lifeIndexFrom(byType['3'], '穿衣', AppAssets.qxAirDressingIcon),
      _lifeIndexFrom(byType['6'], '出行', AppAssets.qxAirTravelIcon),
      _lifeIndexFrom(byType['16'], '防晒', AppAssets.qxAirSunscreenIcon),
      _lifeIndexFrom(byType['5'], '紫外线', AppAssets.qxAirUvIcon),
      _skinProtectionIndexFrom(byType['13'], AppAssets.qxAirSkinIcon),
      _lifeIndexFrom(byType['15'], '交通', AppAssets.qxAirTrafficIcon),
    ];
    return items.every((item) => item.value.isNotEmpty) ? items : const [];
  }

  /// 单项生活指数（对齐 Android lifeIndexFrom：category → name → text）
  QxLifeIndexUi _lifeIndexFrom(
      Map<String, dynamic>? item, String title, String iconPath) {
    var value = item?['category']?.toString() ?? '';
    if (value.isEmpty) value = item?['name']?.toString() ?? '';
    if (value.isEmpty) value = item?['text']?.toString() ?? '';
    return QxLifeIndexUi(title: title, value: value, iconPath: iconPath);
  }

  /// 护肤指数特殊映射（对齐 Android skinProtectionIndexFrom）
  QxLifeIndexUi _skinProtectionIndexFrom(
      Map<String, dynamic>? item, String iconPath) {
    final value = _skinProtectionLabel(
      item?['level']?.toString(),
      item?['category']?.toString(),
    );
    return QxLifeIndexUi(title: '护肤', value: value, iconPath: iconPath);
  }

  /// 护肤标签（对齐 Android skinProtectionLabel）
  String _skinProtectionLabel(String? level, String? category) {
    final cleanCategory = category ?? '';
    if (cleanCategory.contains('防脱水') && cleanCategory.contains('防晒')) {
      return '防脱水防晒';
    }
    if (cleanCategory.contains('防脱水')) return '防脱水';
    if (cleanCategory.contains('防晒')) return '防晒';
    if (cleanCategory.contains('保湿')) return '防脱水';
    if (cleanCategory.contains('去油')) return '清爽';
    final levelValue = int.tryParse(level ?? '');
    switch (levelValue) {
      case 4:
        return '防脱水防晒';
      case 1:
      case 2:
      case 6:
      case 8:
        return '防脱水';
      case 3:
      case 7:
        return '防晒';
      case 5:
        return '清爽';
      default:
        return '';
    }
  }

  /// 本地兜底生活指数（对齐 Android fallbackLifeIndexes + ZSUtils）
  List<QxLifeIndexUi> _fallbackLifeIndexes(Weather7DDTO? today) {
    final tempMax = today?.tempMax.isNotEmpty == true ? today!.tempMax : '26';
    final tempMin = today?.tempMin.isNotEmpty == true ? today!.tempMin : '18';
    final textDay = today?.textDay.isNotEmpty == true ? today!.textDay : '晴';
    final uvIndex = today?.uvIndex.isNotEmpty == true ? today!.uvIndex : '5';
    return [
      QxLifeIndexUi(
          title: '穿衣',
          value: _zsDressing(tempMax, tempMin),
          iconPath: AppAssets.qxAirDressingIcon),
      QxLifeIndexUi(
          title: '出行',
          value: _zsTravel(tempMax, textDay),
          iconPath: AppAssets.qxAirTravelIcon),
      QxLifeIndexUi(
          title: '防晒',
          value: _zsUv(uvIndex),
          iconPath: AppAssets.qxAirSunscreenIcon),
      QxLifeIndexUi(
          title: '紫外线',
          value: _zsUvDescription(uvIndex),
          iconPath: AppAssets.qxAirUvIcon),
      QxLifeIndexUi(
          title: '护肤',
          value: _fallbackSkinProtection(tempMax, uvIndex),
          iconPath: AppAssets.qxAirSkinIcon),
      QxLifeIndexUi(
          title: '交通',
          value: _zsTraffic(textDay),
          iconPath: AppAssets.qxAirTrafficIcon),
    ];
  }

  /// 穿衣指数（对齐 ZSUtils.generateDressing：按最高温度 33/25/18/10 分档）
  String _zsDressing(String tempMax, String tempMin) {
    final maxTemp = int.tryParse(tempMax);
    if (maxTemp == null) return '';
    if (maxTemp >= 33) return '短袖';
    if (maxTemp >= 25) return 'T恤';
    if (maxTemp >= 18) return '夹克';
    if (maxTemp >= 10) return '毛衣';
    return '棉服';
  }

  /// 紫外线防护（对齐 ZSUtils.generateUv，含"注意防晒 "尾随空格保真）
  String _zsUv(String uvIndexStr) {
    final uv = int.tryParse(uvIndexStr);
    if (uv == null) return '无需防护';
    if (uv <= 2) return '无需防护';
    if (uv <= 5) return '适当防护';
    if (uv <= 7) return '注意防晒 ';
    if (uv <= 10) return '避免暴晒';
    return '务必防晒';
  }

  /// 紫外线描述（对齐 ZSUtils.generateUvDescription，含"强 "尾随空格保真）
  String _zsUvDescription(String uvIndexStr) {
    final uv = int.tryParse(uvIndexStr);
    if (uv == null) return '较弱';
    if (uv <= 2) return '最弱';
    if (uv <= 5) return '中等';
    if (uv <= 7) return '强 ';
    if (uv <= 10) return '很强';
    return '极强';
  }

  /// 出行指数（对齐 ZSUtils.generateTravel）
  String _zsTravel(String tempMax, String weatherCondition) {
    final maxTemp = int.tryParse(tempMax);
    if (weatherCondition.contains('雨') || weatherCondition.contains('雪')) {
      return '不宜出游';
    }
    if (maxTemp != null && (maxTemp > 35 || maxTemp < 0)) return '谨慎出游';
    return '适宜出游';
  }

  /// 交通指数（对齐 ZSUtils.generateTraffic）
  String _zsTraffic(String weatherCondition) {
    if (weatherCondition.contains('雨') ||
        weatherCondition.contains('雪') ||
        weatherCondition.contains('雾')) {
      return '请慢行';
    }
    return '宜出行';
  }

  /// 兜底护肤标签（对齐 Android fallbackSkinProtection）
  String _fallbackSkinProtection(String tempMax, String uvIndex) {
    final maxTemp = int.tryParse(tempMax) ?? 26;
    final uv = int.tryParse(uvIndex) ?? 5;
    if (maxTemp >= 30 && uv >= 6) return '防脱水防晒';
    if (maxTemp >= 30) return '防脱水';
    if (uv >= 3) return '防晒';
    return '防晒';
  }

  /// 本地生活小窍门（对齐 Android loadLifeTip：解析 assets/xiaoqiaomen.html 并轮询）
  Future<LifeTipResult> _loadLifeTip() async {
    try {
      final html = await rootBundle.loadString('assets/xiaoqiaomen.html');
      final tips = _parseLocalLifeTips(html);
      final result = _nextLocalLifeTip(tips);
      if (result.body.isNotEmpty) return result;
      return _defaultLifeTip();
    } catch (_) {
      return _defaultLifeTip();
    }
  }

  /// 解析小窍门 H5（对齐 Android parseLocalLifeTips）
  List<LifeTipResult> _parseLocalLifeTips(String html) {
    var pageTitle = _firstHtmlMatch(html, RegExp(r'<h1[^>]*>([\s\S]*?)</h1>'));
    if (pageTitle.startsWith('实用')) {
      pageTitle = pageTitle.substring(2);
    }
    if (pageTitle.isEmpty) pageTitle = '生活小窍门';
    final tipBlocks = RegExp(r'''<div\s+class=["']tip["'][^>]*>''')
        .allMatches(html)
        .map((match) => html.substring(match.end))
        .toList();
    return [
      for (var i = 0; i < tipBlocks.length; i++)
        _parseLocalLifeTipBlock(pageTitle, tipBlocks[i]),
    ].where((tip) => tip.body.isNotEmpty).toList();
  }

  /// 轮询下一条小窍门（对齐 Android nextLocalLifeTip：prefs 记录索引循环递增）
  LifeTipResult _nextLocalLifeTip(List<LifeTipResult> tips) {
    if (tips.isEmpty) return _defaultLifeTip();
    final savedIndex = PrefsStorage.getInt(_keyNextLifeTipIndex) ?? 0;
    final index = ((savedIndex % tips.length) + tips.length) % tips.length;
    PrefsStorage.setInt(
        _keyNextLifeTipIndex, (index + 1) % tips.length);
    return tips[index];
  }

  /// 解析单条小窍门（对齐 Android parseLocalLifeTipBlock：标题+描述+前两步）
  LifeTipResult _parseLocalLifeTipBlock(String pageTitle, String block) {
    final tipTitle = _firstHtmlMatch(
            block, RegExp(r'''<div\s+class=["']tip-header["'][^>]*>([\s\S]*?)</div>'''))
        .replaceFirst(RegExp(r'^\d+\.\s*'), '');
    final description = _firstHtmlMatch(
        block, RegExp(r'''<div\s+class=["']tip-desc["'][^>]*>([\s\S]*?)</div>'''));
    final stepsHtml = RegExp(
            r'''<ul\s+class=["']tip-steps["'][^>]*>([\s\S]*?)</ul>''')
        .firstMatch(block)
        ?.group(1) ??
        '';
    final steps = RegExp(r'<li[^>]*>([\s\S]*?)</li>')
        .allMatches(stepsHtml)
        .map((match) => _cleanHtml(match.group(1) ?? ''))
        .where((step) => step.isNotEmpty)
        .take(2)
        .join('；');
    final parts = <String>[
      if (tipTitle.isNotEmpty) '$tipTitle：',
      description,
      steps,
    ].where((part) => part.isNotEmpty).toList();
    return LifeTipResult(title: pageTitle, body: parts.join());
  }

  String _firstHtmlMatch(String html, RegExp regex) {
    return _cleanHtml(regex.firstMatch(html)?.group(1) ?? '');
  }

  /// 清洗 HTML（对齐 Android cleanHtml）
  String _cleanHtml(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// 默认小窍门（对齐 Android defaultLifeTip）
  LifeTipResult _defaultLifeTip() {
    return const LifeTipResult(
      title: '生活小窍门',
      body: '若有小面积皮肤损伤或烧伤、烫伤，抹上少许牙膏，可立即止血止痛，也可防止感染，疗效颇佳。',
    );
  }

  Future<T> _runCatching<T>(
    Future<T> Function() block, {
    required T Function() fallback,
  }) async {
    try {
      return await block();
    } catch (_) {
      return fallback();
    }
  }

  Future<T?> _runCatchingNull<T>(Future<T> Function() block) async {
    try {
      return await block();
    } catch (_) {
      return null;
    }
  }

  /// 对齐 Android LIFE_TIP_PREFS/KEY_NEXT_LIFE_TIP_INDEX 的轮询索引
  static const String _keyNextLifeTipIndex = 'qx_air_life_tip_next_index';
}

/// 小窍门结果（对齐 Android LifeTipResult）
class LifeTipResult {
  final String title;
  final String body;

  const LifeTipResult({required this.title, required this.body});
}
