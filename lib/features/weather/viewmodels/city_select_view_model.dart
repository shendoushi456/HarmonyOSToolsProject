// 城市选择 ViewModel - 对齐 Android AddCityActivity + SearchViewModel
// 单选模式:选择城市后替换整个列表
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city_bean.dart';
import '../models/citys.dart';
import '../repositories/city_repository.dart';
import '../services/city_search_service.dart';
import 'city_select_state.dart';

class AddCityViewModel extends Notifier<AddCityState> {
  final CityRepository _cityRepository = CityRepository();
  final CitySearchService _service = CitySearchService();

  @override
  AddCityState build() {
    // 异步加载热门城市,不阻塞 build
    Future.microtask(loadHotCities);
    return const AddCityState(isLoading: true);
  }

  /// 加载热门城市 - 对齐 SearchViewModel.getHopCity
  Future<void> loadHotCities() async {
    try {
      final cities = await _service.loadHotCities();
      state = state.copyWith(hotCities: cities, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 搜索城市 - 对齐 AddCityActivity.search(行 152-172)
  /// keyword 为空则退出搜索模式
  void search(String keyword) {
    if (keyword.isEmpty) {
      state = state.copyWith(isSearching: false, searchResults: const []);
      return;
    }
    final results = _service.search(state.hotCities, keyword);
    state = state.copyWith(isSearching: true, searchResults: results);
  }

  /// 选择城市(单选模式) - 对齐 AddCityActivity.saveAndJump 单选分支(行 91-102)
  /// 构造 CityBean 并替换整个城市列表,返回 true 表示成功
  Future<bool> selectCity(Citys city) async {
    final cityBean = CityBean(
      areaCode: city.id,
      cityName: city.district,
      isLocal: false,
    );
    await _cityRepository.replaceCity(cityBean);
    return true;
  }
}

/// 城市选择 ViewModel Provider
final addCityViewModelProvider =
    NotifierProvider<AddCityViewModel, AddCityState>(AddCityViewModel.new);
