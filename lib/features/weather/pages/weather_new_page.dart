// 天气页容器(新版) - 对齐 Android WeatherFragment(单城市简化模式)
// 复用现有 CityRepository 单选模式: loadCities → first → ValueKey 重建触发 loadData
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../router/route_names.dart';
import '../models/city_bean.dart';
import '../repositories/city_repository.dart';
import 'weather_compose_child_page.dart';

class WeatherNewPage extends ConsumerStatefulWidget {
  const WeatherNewPage({super.key});

  @override
  ConsumerState<WeatherNewPage> createState() => _WeatherNewPageState();
}

class _WeatherNewPageState extends ConsumerState<WeatherNewPage> {
  final CityRepository _cityRepository = CityRepository();
  CityBean? _city;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  /// 加载当前城市 - 单选模式只取列表第一个
  /// 对齐 Android WeatherFragment.initWeatherData + TravelViewModel.getWeatherCity
  Future<void> _loadCity() async {
    final cities = await _cityRepository.loadCities();
    if (!mounted) return;
    setState(() {
      _city = cities.isNotEmpty ? cities.first : null;
      _isLoading = false;
    });
  }

  /// 点击城市切换栏 - 对齐 Android WeatherChildFragment.TopAppBar.Text.clickable { changeCity }
  /// 单选模式跳转 CitySelectPage, 返回 true 后刷新当前城市
  Future<void> _onCityClick() async {
    final changed = await context.push<bool>(RoutePaths.citySelect);
    if (changed == true) {
      await _loadCity();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF010C39),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_city == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF010C39),
        body: Center(child: Text('暂无城市')),
      );
    }

    return WeatherComposeChildPage(
      city: _city!,
      // 城市变化时强制重建,触发 WeatherViewModel.loadData 重新加载
      key: ValueKey(_city!.areaCode),
      onCityClick: _onCityClick,
    );
  }
}
