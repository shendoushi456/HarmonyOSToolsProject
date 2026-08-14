// 城市数据仓库 - 对齐 Android SharedPrefUtil + WeatherFragment.initWeatherData
// 管理城市列表的本地存储
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/prefs_storage.dart';
import '../models/city_bean.dart';

class CityRepository {
  /// 加载城市列表
  /// 缓存为空时写入默认北京并返回
  /// 对应 Android WeatherFragment.initWeatherData
  Future<List<CityBean>> loadCities() async {
    final jsonList = PrefsStorage.loadCityList();
    if (jsonList == null || jsonList.isEmpty) {
      final defaultCity = CityBean.defaultCity();
      await saveCities([defaultCity]);
      return [defaultCity];
    }
    return jsonList.map(CityBean.fromJson).toList();
  }

  /// 保存城市列表
  Future<void> saveCities(List<CityBean> cities) async {
    PrefsStorage.saveCityList(cities.map((e) => e.toJson()).toList());
  }

  /// 加载当前 ViewPager 位置
  int loadPosition() => PrefsStorage.loadPosition();

  /// 保存当前 ViewPager 位置
  Future<void> savePosition(int position) async {
    PrefsStorage.savePosition(position);
  }

  /// 默认城市
  CityBean defaultCity() => CityBean.defaultCity();
}

/// CityRepository Provider
final cityRepositoryProvider = Provider<CityRepository>((ref) {
  return CityRepository();
});
