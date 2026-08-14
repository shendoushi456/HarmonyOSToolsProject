// 天气页面 - PageView 多城市容器 - 对齐 Android WeatherFragment
// 读取城市列表,每城市对应一个 WeatherChildPage
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/city_repository.dart';
import '../models/city_bean.dart';
import 'weather_child_page.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  final CityRepository _cityRepository = CityRepository();
  List<CityBean> _cities = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  /// 加载城市列表 - 对齐 Android WeatherFragment.initWeatherData
  Future<void> _loadCities() async {
    final cities = await _cityRepository.loadCities();
    final position = _cityRepository.loadPosition();
    if (!mounted) return;
    setState(() {
      _cities = cities;
      _currentIndex = position < cities.length ? position : 0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_cities.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('暂无城市')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // PageView 城市切换
            PageView.builder(
              itemCount: _cities.length,
              controller: PageController(initialPage: _currentIndex),
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _cityRepository.savePosition(index);
              },
              itemBuilder: (context, index) {
                return WeatherChildPage(city: _cities[index]);
              },
            ),
            // 小圆点指示器(城市数>1 时显示)
            if (_cities.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_cities.length, (i) {
                    final isActive = i == _currentIndex;
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFF159BD8)
                            : const Color(0xFFCCCCCC),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
