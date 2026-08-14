// 天气页面 - 单城市容器 - 对齐 Android WeatherChildFragment(Compose 新版)
// 单选模式:只显示当前城市,点击顶部切换栏跳转城市选择页
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../router/route_names.dart';
import '../models/city_bean.dart';
import '../repositories/city_repository.dart';
import 'weather_child_page.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  final CityRepository _cityRepository = CityRepository();
  CityBean? _city;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  /// 加载当前城市 - 单选模式只取列表第一个
  /// 对齐 Android WeatherChildFragment.onResume + getWeatherCity
  Future<void> _loadCity() async {
    final cities = await _cityRepository.loadCities();
    if (!mounted) return;
    setState(() {
      _city = cities.isNotEmpty ? cities.first : null;
      _isLoading = false;
    });
  }

  /// 点击城市切换栏 - 对齐 Android WeatherChildFragment.changeCity
  /// 单选模式跳转 CitySelectPage,返回 true 后刷新当前城市
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
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_city == null) {
      return const Scaffold(
        body: Center(child: Text('暂无城市')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: WeatherChildPage(
          city: _city!,
          // 城市变化时强制重建,触发 WeatherViewModel.loadData 重新加载
          key: ValueKey(_city!.areaCode),
          onCityClick: _onCityClick,
        ),
      ),
    );
  }
}
