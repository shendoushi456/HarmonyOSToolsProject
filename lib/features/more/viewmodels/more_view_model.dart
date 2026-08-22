import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../weather/repositories/city_repository.dart';
import '../../weather/viewmodels/weather_view_model.dart';
import 'more_state.dart';

final moreViewModelProvider =
    NotifierProvider<MoreViewModel, MoreState>(MoreViewModel.new);

/// 复用城市仓储和天气 ViewModel，避免 MoreFragment 再复制一套天气请求逻辑。
class MoreViewModel extends Notifier<MoreState> {
  late final CityRepository _cityRepository;

  @override
  MoreState build() {
    _cityRepository = ref.read(cityRepositoryProvider);
    Future.microtask(load);
    return const MoreState.initial();
  }

  Future<void> load({bool refreshWeather = false}) async {
    final cities = await _cityRepository.loadCities();
    if (cities.isEmpty) {
      state = state.copyWith(loadingCity: false);
      return;
    }
    final city = cities.first;
    state = state.copyWith(city: city, loadingCity: false);
    final weather = ref.read(weatherViewModelProvider.notifier);
    if (refreshWeather) {
      await weather.refresh(city);
    } else {
      await weather.loadData(city);
    }
  }
}
