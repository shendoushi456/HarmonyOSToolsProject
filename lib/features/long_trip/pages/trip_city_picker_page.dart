// 长途规划专用的城市选择页：复用天气页城市目录，但不修改首页当前城市。
import 'package:flutter/material.dart';
import '../../weather/models/citys.dart';
import '../../weather/services/city_search_service.dart';
import '../models/long_trip_models.dart';
import '../repositories/long_trip_repository.dart';

class TripCityPickerPage extends StatefulWidget {
  const TripCityPickerPage({super.key});

  @override
  State<TripCityPickerPage> createState() => _TripCityPickerPageState();
}

class _TripCityPickerPageState extends State<TripCityPickerPage> {
  final _searchController = TextEditingController();
  final _cityService = CitySearchService();
  List<Citys> _cities = const [];
  List<Citys> _results = const [];
  List<LongTripCitySelection> _commonCities = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_search);
    _commonCities = LongTripRepository().loadCommonCities();
    _loadCities();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_search)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await _cityService.loadHotCities();
      if (mounted) setState(() => _cities = cities);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectCity(Citys city) {
    Navigator.of(context).pop(LongTripCitySelection(
      sourceId: city.id,
      locationId: '',
      provinceName: city.province,
      adminCityName: city.city,
      cityName: city.district,
    ));
  }

  void _search() {
    final keyword = _searchController.text.trim();
    setState(() {
      _results =
          keyword.isEmpty ? const [] : _cityService.search(_cities, keyword);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searching = _searchController.text.trim().isNotEmpty;
    final cities = searching ? _results : _cities;
    return Scaffold(
      backgroundColor: const Color(0xFF3F5BDF),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 12, 12),
            child: Row(children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .24),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 17, right: 8),
                      child: Icon(Icons.search, color: Colors.white, size: 19),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: '搜索城市或地区',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消', style: TextStyle(color: Colors.white)),
              ),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 8, 22, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('选择沿途城市',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          if (!searching && _commonCities.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, 4),
                  child: Text('常用沿途城市',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    scrollDirection: Axis.horizontal,
                    itemCount: _commonCities.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      final city = _commonCities[index];
                      return ActionChip(
                        label: Text(city.cityName),
                        onPressed: () => Navigator.of(context).pop(city),
                      );
                    },
                  ),
                ),
              ],
            ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : cities.isEmpty
                    ? Center(
                        child: Text(searching ? '未找到该城市' : '城市列表加载失败',
                            style: const TextStyle(color: Colors.white)))
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 2.15,
                        ),
                        itemCount: cities.length,
                        itemBuilder: (_, index) {
                          final city = cities[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _selectCity(city),
                            child: Center(
                              child: Text(city.district,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14)),
                            ),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }
}
