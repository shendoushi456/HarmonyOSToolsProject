import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../weather/models/weather_model.dart';
import '../../weather/models/weather_warning.dart';
import '../../weather/repositories/weather_repository.dart';
import '../models/long_trip_models.dart';
import '../repositories/long_trip_repository.dart';

class LongTripState {
  final List<LongTripPlan> plans;
  final LongTripDraft draft;
  final Map<String, LongTripCityWeather> weatherByCity;
  final bool saving;
  const LongTripState(
      {this.plans = const [],
      this.draft = const LongTripDraft(),
      this.weatherByCity = const {},
      this.saving = false});
  LongTripState copyWith(
          {List<LongTripPlan>? plans,
          LongTripDraft? draft,
          Map<String, LongTripCityWeather>? weatherByCity,
          bool? saving}) =>
      LongTripState(
          plans: plans ?? this.plans,
          draft: draft ?? this.draft,
          weatherByCity: weatherByCity ?? this.weatherByCity,
          saving: saving ?? this.saving);
}

class LongTripViewModel extends Notifier<LongTripState> {
  final _planRepository = LongTripRepository();
  final _weatherRepository = WeatherRepository();

  @override
  LongTripState build() {
    Future.microtask(reload);
    return const LongTripState();
  }

  Future<void> reload() async {
    final plans = _planRepository.loadAll();
    state = state.copyWith(plans: plans, weatherByCity: const {});
    final cities = plans
        .expand((plan) => plan.points)
        .map((point) => point.cityName.trim())
        .where((name) => name.isNotEmpty)
        .toSet();
    if (cities.isEmpty) return;
    state = state.copyWith(weatherByCity: {
      for (final city in cities) city: const LongTripCityWeather()
    });
    for (final city in cities) {
      _loadCityWeather(city);
    }
  }

  Future<void> _loadCityWeather(String cityName) async {
    WeatherInfo? weather;
    List<WeatherWarning> warnings = const [];
    try {
      // 日预报接口只接受 locationId。此前直接传城市名，导致入口加载时
      // 15 日预报请求失败；农业页的定位方式与此保持一致。
      final cityId = await _weatherRepository.resolveCityId(cityName);
      try {
        weather = await _weatherRepository.loadDailyWeather(cityId);
      } catch (_) {
        weather = null;
      }
    } catch (_) {
      // 城市定位失败时，保留空态并结束加载，避免页面永久显示“获取中”。
    }
    try {
      warnings = await _weatherRepository.loadWarnings(cityName);
    } catch (_) {
      warnings = const [];
    }
    final old = state.weatherByCity[cityName] ?? const LongTripCityWeather();
    state = state.copyWith(weatherByCity: {
      ...state.weatherByCity,
      cityName: LongTripCityWeather(
        loading: false,
        forecasts: weather?.daily ?? old.forecasts,
        warnings: warnings,
      ),
    });
  }

  String? addPoint(LongTripPointRole role, LongTripPoint point) {
    final today = DateTime.now();
    final day = DateTime(point.date.year, point.date.month, point.date.day);
    if (day.isBefore(DateTime(today.year, today.month, today.day)) ||
        day.isAfter(today.add(const Duration(days: 14)))) {
      return '日期需在未来15日内';
    }
    final draft = state.draft;
    if (role != LongTripPointRole.start && draft.start == null) {
      return '请先选择起点';
    }
    if (draft.start != null &&
        role != LongTripPointRole.start &&
        day.isBefore(_date(draft.start!.date))) {
      return '途径点和终点不能早于起点';
    }
    if (role == LongTripPointRole.waypoint &&
        draft.end != null &&
        day.isAfter(_date(draft.end!.date))) {
      return '途径点不能晚于终点';
    }
    if (role == LongTripPointRole.end &&
        draft.waypoints.any((item) => day.isBefore(_date(item.date)))) {
      return '终点不能早于途径点';
    }
    if (role == LongTripPointRole.start &&
        [...draft.waypoints, if (draft.end != null) draft.end!]
            .any((item) => day.isAfter(_date(item.date)))) {
      return '起点不能晚于已有途径点或终点';
    }
    switch (role) {
      case LongTripPointRole.start:
        state = state.copyWith(draft: draft.copyWith(start: point));
        break;
      case LongTripPointRole.waypoint:
        state = state.copyWith(
            draft: draft.copyWith(waypoints: [...draft.waypoints, point]));
        break;
      case LongTripPointRole.end:
        state = state.copyWith(draft: draft.copyWith(end: point));
        break;
    }
    return null;
  }

  void removePoint(LongTripPointRole role, int index) {
    final draft = state.draft;
    switch (role) {
      case LongTripPointRole.start:
        state = state.copyWith(draft: draft.copyWith(clearStart: true));
        break;
      case LongTripPointRole.waypoint:
        state = state.copyWith(
            draft: draft.copyWith(
                waypoints: [...draft.waypoints]..removeAt(index)));
        break;
      case LongTripPointRole.end:
        state = state.copyWith(draft: draft.copyWith(clearEnd: true));
        break;
    }
  }

  Future<String?> saveDraft() async {
    if (state.saving) {
      return '正在保存，请稍候';
    }
    final draft = state.draft;
    if (draft.start == null) {
      return '请先选择起点';
    }
    if (draft.end == null) {
      return '请先选择终点';
    }
    state = state.copyWith(saving: true);
    try {
      final plans = _planRepository.loadAll();
      final plan = LongTripPlan(
        id: '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 20)}',
        start: draft.start!,
        waypoints: draft.waypoints,
        end: draft.end!,
        createdAt: DateTime.now(),
      );
      plans.add(plan);
      final saved = await _planRepository.saveAll(plans);
      final verified =
          saved && await _planRepository.containsPersistedPlan(plan.id);
      if (!verified) {
        state = state.copyWith(saving: false);
        return '正在保存，请稍候';
      }
      state = state.copyWith(draft: const LongTripDraft(), saving: false);
      await reload();
      return null;
    } catch (_) {
      // 任何平台通道/序列化异常都必须回到 UI 层给出失败反馈，草稿保持不变。
      state = state.copyWith(saving: false);
      return '正在保存，请稍候';
    }
  }

  Future<void> deletePlan(String id) async {
    final plans =
        _planRepository.loadAll().where((item) => item.id != id).toList();
    await _planRepository.saveAll(plans);
    await reload();
  }

  DateTime _date(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

final longTripViewModelProvider =
    NotifierProvider<LongTripViewModel, LongTripState>(LongTripViewModel.new);
