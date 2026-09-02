import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../weather/models/weather_model.dart';
import '../../weather/models/hourly_weather.dart';
import '../../weather/models/weather_warning.dart';
import '../../weather/repositories/city_repository.dart';
import '../../weather/repositories/weather_repository.dart';
import '../models/agriculture_models.dart';
import '../repositories/crop_record_repository.dart';

class AgricultureState {
  final bool loading;
  final String cityName;
  final List<DailyWeather> forecasts;
  final List<WeatherWarning> warnings;
  final List<HourlyWeather> hourlyWeather;
  final List<CropRecord> records;
  final String? errorMessage;

  const AgricultureState({
    this.loading = true,
    this.cityName = '',
    this.forecasts = const [],
    this.warnings = const [],
    this.hourlyWeather = const [],
    this.records = const [],
    this.errorMessage,
  });

  AgricultureState copyWith({
    bool? loading,
    String? cityName,
    List<DailyWeather>? forecasts,
    List<WeatherWarning>? warnings,
    List<HourlyWeather>? hourlyWeather,
    List<CropRecord>? records,
    String? errorMessage,
    bool clearError = false,
  }) =>
      AgricultureState(
        loading: loading ?? this.loading,
        cityName: cityName ?? this.cityName,
        forecasts: forecasts ?? this.forecasts,
        warnings: warnings ?? this.warnings,
        hourlyWeather: hourlyWeather ?? this.hourlyWeather,
        records: records ?? this.records,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

class AgricultureViewModel extends Notifier<AgricultureState> {
  final _weatherRepository = WeatherRepository();
  final _cityRepository = CityRepository();
  final _recordRepository = CropRecordRepository();
  int _requestVersion = 0;

  @override
  AgricultureState build() {
    Future.microtask(load);
    return const AgricultureState();
  }

  Future<void> load() async {
    final cities = await _cityRepository.loadCities();
    final city = cities.isEmpty ? _cityRepository.defaultCity() : cities.first;
    await loadForCity(city.cityName);
  }

  /// 与天气页共用同一个城市来源；切城后清空旧数据，再加载新城市农业数据。
  Future<void> loadForCity(String cityName) async {
    if (cityName.trim().isEmpty) return;
    final version = ++_requestVersion;
    state = state.copyWith(
      loading: true,
      cityName: cityName,
      forecasts: const [],
      hourlyWeather: const [],
      warnings: const [],
      records: _recordRepository.loadAll(),
      clearError: true,
    );
    AgricultureWeatherData? agricultureWeather;
    try {
      agricultureWeather =
          await _weatherRepository.loadAgricultureWeather(cityName);
    } catch (_) {
      agricultureWeather = null;
    }
    if (version != _requestVersion) return;
    state = state.copyWith(
      loading: false,
      forecasts: agricultureWeather?.dailyWeather?.daily ?? const [],
      hourlyWeather: agricultureWeather?.hourlyWeather ?? const [],
      warnings: agricultureWeather?.warnings ?? const [],
      records: _recordRepository.loadAll(),
      errorMessage:
          agricultureWeather?.dailyWeather == null ? '农业日预报加载失败，请下拉重试' : null,
      clearError: agricultureWeather?.dailyWeather != null,
    );
  }

  Future<void> saveRecord({
    CropRecord? original,
    required CropCategory category,
    required String title,
    required String content,
  }) async {
    final value = title.trim();
    if (value.isEmpty) return;
    final records = _recordRepository.loadAll().toList();
    final record = CropRecord(
      id: original?.id ??
          '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 20)}',
      categoryId: category.id,
      title: value,
      content: content.trim(),
      createdAt: original?.createdAt ?? DateTime.now(),
    );
    final index = records.indexWhere((item) => item.id == record.id);
    if (index == -1) {
      records.add(record);
    } else {
      records[index] = record;
    }
    await _recordRepository.saveAll(records);
    state = state.copyWith(records: _recordRepository.loadAll());
  }

  Future<void> deleteRecord(String id) async {
    final records =
        _recordRepository.loadAll().where((item) => item.id != id).toList();
    await _recordRepository.saveAll(records);
    state = state.copyWith(records: _recordRepository.loadAll());
  }
}

final agricultureViewModelProvider =
    NotifierProvider<AgricultureViewModel, AgricultureState>(
        AgricultureViewModel.new);
