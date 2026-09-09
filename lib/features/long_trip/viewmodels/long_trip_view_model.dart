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

class LongTripSaveResult {
  final bool planSaved;
  final bool duplicate;
  final String? message;
  const LongTripSaveResult(
      {required this.planSaved, this.duplicate = false, this.message});
  const LongTripSaveResult.success()
      : planSaved = true,
        duplicate = false,
        message = null;
  const LongTripSaveResult.duplicate()
      : planSaved = true,
        duplicate = true,
        message = '相同长途规划已保存，无需重复添加';
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
    final points = plans
        .expand((plan) => plan.points)
        .where((point) => point.cityName.trim().isNotEmpty)
        .fold(<String, LongTripPoint>{}, (result, point) {
      result.putIfAbsent(point.weatherKey, () => point);
      return result;
    });
    if (points.isEmpty) return;
    state = state.copyWith(weatherByCity: {
      for (final key in points.keys) key: const LongTripCityWeather()
    });
    for (final entry in points.entries) {
      _loadCityWeather(entry.key, entry.value);
    }
  }

  Future<void> _loadCityWeather(String weatherKey, LongTripPoint point) async {
    final cityName = point.cityName;
    WeatherInfo? weather;
    List<WeatherWarning> warnings = const [];
    try {
      // 日预报接口只接受 locationId。此前直接传城市名，导致入口加载时
      // 15 日预报请求失败；农业页的定位方式与此保持一致。
      final cityId = point.locationId.isNotEmpty
          ? point.locationId
          : await _weatherRepository.resolveCityId(cityName);
      try {
        weather = await _weatherRepository.loadDailyWeather(cityId);
      } catch (_) {
        weather = null;
      }
    } catch (_) {
      // 城市定位失败时，保留空态并结束加载，避免页面永久显示“获取中”。
    }
    try {
      warnings = await _weatherRepository.loadWarningsForCoordinates(
        latitude: point.latitude,
        longitude: point.longitude,
      );
      if (point.latitude.isEmpty || point.longitude.isEmpty) {
        warnings = await _weatherRepository.loadWarnings(cityName);
      }
    } catch (_) {
      warnings = const [];
    }
    final old = state.weatherByCity[weatherKey] ?? const LongTripCityWeather();
    state = state.copyWith(weatherByCity: {
      ...state.weatherByCity,
      weatherKey: LongTripCityWeather(
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

  Future<LongTripSaveResult> saveDraft() async {
    if (state.saving) {
      return const LongTripSaveResult(planSaved: false, message: '正在保存，请稍候');
    }
    final draft = state.draft;
    if (draft.start == null) {
      return const LongTripSaveResult(planSaved: false, message: '请先选择起点');
    }
    if (draft.end == null) {
      return const LongTripSaveResult(planSaved: false, message: '请先选择终点');
    }
    final points = <LongTripPoint>[
      draft.start!.copyWith(sequence: 0),
      ...draft.waypoints
          .asMap()
          .entries
          .map((entry) => entry.value.copyWith(sequence: entry.key + 1)),
      draft.end!.copyWith(sequence: draft.waypoints.length + 1),
    ];
    final plan = LongTripPlan(
      id: '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 20)}',
      start: points.first,
      waypoints: points.sublist(1, points.length - 1),
      end: points.last,
      createdAt: DateTime.now(),
    );
    final plans = _planRepository.loadAll();
    if (plans.any((item) => item.routeFingerprint == plan.routeFingerprint)) {
      return const LongTripSaveResult.duplicate();
    }
    state = state.copyWith(saving: true);
    try {
      plans.add(plan);
      final saved = await _planRepository.saveAll(plans);
      final verified =
          saved && await _planRepository.containsPersistedPlan(plan.id);
      if (!verified) {
        state = state.copyWith(saving: false);
        return const LongTripSaveResult(
            planSaved: false, message: '长途规划保存失败，请检查本地存储后重试');
      }
      state = state.copyWith(
          plans: plans, draft: const LongTripDraft(), saving: false);
      _runPostSaveTasks(plan);
      return const LongTripSaveResult.success();
    } catch (_) {
      // 任何平台通道/序列化异常都必须回到 UI 层给出失败反馈，草稿保持不变。
      state = state.copyWith(saving: false);
      return const LongTripSaveResult(
          planSaved: false, message: '长途规划保存失败，请重试');
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

  Future<void> _runPostSaveTasks(LongTripPlan plan) async {
    try {
      await _planRepository.addCommonCities(plan.points);
    } catch (_) {}
    try {
      await _enrichSavedPlan(plan);
      await reload();
    } catch (_) {}
  }

  Future<void> _enrichSavedPlan(LongTripPlan plan) async {
    final enrichedPoints = await Future.wait(plan.points
        .asMap()
        .entries
        .map((entry) => _enrichPoint(entry.value, entry.key)));
    final hasChanges = enrichedPoints
        .asMap()
        .entries
        .any((entry) => !_samePointData(entry.value, plan.points[entry.key]));
    if (!hasChanges) return;
    final latestPlans = _planRepository.loadAll();
    final index = latestPlans.indexWhere((item) => item.id == plan.id);
    if (index < 0) return;
    latestPlans[index] = LongTripPlan(
      id: plan.id,
      start: enrichedPoints.first,
      waypoints: enrichedPoints.sublist(1, enrichedPoints.length - 1),
      end: enrichedPoints.last,
      createdAt: plan.createdAt,
    );
    await _planRepository.saveAll(latestPlans);
  }

  Future<LongTripPoint> _enrichPoint(LongTripPoint point, int sequence) async {
    final original = point.copyWith(sequence: sequence);
    if (point.locationId.isNotEmpty &&
        point.latitude.isNotEmpty &&
        point.longitude.isNotEmpty) return original;
    try {
      final location = await _weatherRepository.resolveCity(point.cityName);
      return original.copyWith(
          locationId: location.id,
          latitude: location.latitude,
          longitude: location.longitude);
    } catch (_) {
      return original;
    }
  }

  bool _samePointData(LongTripPoint left, LongTripPoint right) =>
      left.cityName == right.cityName &&
      left.sourceId == right.sourceId &&
      left.locationId == right.locationId &&
      left.provinceName == right.provinceName &&
      left.adminCityName == right.adminCityName &&
      left.latitude == right.latitude &&
      left.longitude == right.longitude &&
      left.date == right.date &&
      left.sequence == right.sequence;
}

final longTripViewModelProvider =
    NotifierProvider<LongTripViewModel, LongTripState>(LongTripViewModel.new);
