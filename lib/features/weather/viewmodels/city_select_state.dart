// 城市选择页状态 - 对齐 Android AddCityActivity 的 UI 状态
import 'package:flutter/foundation.dart';
import '../models/citys.dart';

@immutable
class AddCityState {
  /// 热门城市完整列表(本地 JSON)
  final List<Citys> hotCities;

  /// 搜索结果列表(按关键字过滤)
  final List<Citys> searchResults;

  /// 是否处于搜索模式(搜索框有输入)
  final bool isSearching;

  /// 是否正在加载热门城市
  final bool isLoading;

  const AddCityState({
    this.hotCities = const [],
    this.searchResults = const [],
    this.isSearching = false,
    this.isLoading = false,
  });

  AddCityState copyWith({
    List<Citys>? hotCities,
    List<Citys>? searchResults,
    bool? isSearching,
    bool? isLoading,
  }) {
    return AddCityState(
      hotCities: hotCities ?? this.hotCities,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
