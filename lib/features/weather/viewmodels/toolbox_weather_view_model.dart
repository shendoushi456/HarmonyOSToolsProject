// Toolbox 天气页的页面状态。城市选择/持久化与展示 UI 解耦，方便替换马甲 UI。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city_bean.dart';
import '../repositories/city_repository.dart';

class ToolboxWeatherPageState {
  final CityBean? city;
  final bool isLoading;

  const ToolboxWeatherPageState({this.city, this.isLoading = true});
}

class ToolboxWeatherPageViewModel extends Notifier<ToolboxWeatherPageState> {
  final CityRepository _cityRepository = CityRepository();

  @override
  ToolboxWeatherPageState build() {
    Future.microtask(loadCity);
    return const ToolboxWeatherPageState();
  }

  Future<void> loadCity() async {
    final cities = await _cityRepository.loadCities();
    state = ToolboxWeatherPageState(
      city: cities.isEmpty ? null : cities.first,
      isLoading: false,
    );
  }
}

final toolboxWeatherPageViewModelProvider =
    NotifierProvider<ToolboxWeatherPageViewModel, ToolboxWeatherPageState>(
  ToolboxWeatherPageViewModel.new,
);
