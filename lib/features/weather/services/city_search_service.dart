// 城市搜索服务 - 对齐 Android SearchViewModel.kt + AddCityActivity.search
// 负责读取内置 hot_city.json 与本地过滤搜索
import 'package:flutter/services.dart' show rootBundle;
import '../models/citys.dart';

class CitySearchService {
  /// 加载热门城市列表 - 对齐 SearchViewModel.getHopCity + AssetsUtils.getJson
  /// 从 assets/hot_city.json 读取并解析
  Future<List<Citys>> loadHotCities() async {
    final json = await rootBundle.loadString('assets/hot_city.json');
    return HotCityResult.fromJsonString(json).result;
  }

  /// 本地过滤搜索 - 对齐 AddCityActivity.search(行 159-163)
  /// 按 district.contains(keyword) 过滤,不调网络 API
  List<Citys> search(List<Citys> source, String keyword) {
    if (keyword.isEmpty) return const [];
    return source.where((c) => c.district.contains(keyword)).toList();
  }
}
