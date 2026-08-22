import '../../weather/models/city_bean.dart';

/// 更多页状态。天气实体仍由 weather feature 管理，这里只保存当前城市和加载状态。
class MoreState {
  final CityBean? city;
  final bool loadingCity;
  const MoreState({required this.city, required this.loadingCity});

  const MoreState.initial()
      : city = null,
        loadingCity = true;

  MoreState copyWith({CityBean? city, bool? loadingCity}) => MoreState(
      city: city ?? this.city, loadingCity: loadingCity ?? this.loadingCity);
}
