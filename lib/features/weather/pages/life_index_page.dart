// WeatherShFragment / ZyytLifeScreen 的 Flutter 迁移。
// 页面只消费天气 ViewModel，UI 与数据计算保持分层，便于替换马甲皮肤。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../models/city_bean.dart';
import '../viewmodels/weather_view_model.dart';

class LifeIndexPage extends ConsumerWidget {
  const LifeIndexPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherViewModelProvider);
    final air = state.airQuality;
    final pollution = <_Pollutant>[
      _Pollutant('细颗粒物', air?.pm2p5, AppAssets.toolboxLifePollutantPm25, '18'),
      _Pollutant('粗颗粒度', air?.pm10, AppAssets.toolboxLifePollutantPm10, '56'),
      _Pollutant('二氧化氮', air?.no2, AppAssets.toolboxLifePollutantNo2, '8'),
      _Pollutant('二氧化硫', air?.so2, AppAssets.toolboxLifePollutantSo2, '5'),
      _Pollutant('一氧化碳', air?.co, AppAssets.toolboxLifePollutantCo, '0.4'),
      _Pollutant('臭氧', air?.o3, AppAssets.toolboxLifePollutantO3, '82'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE4F6FF),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: const Color(0xFF3E9BC8),
          onRefresh: () async {
            final city = ref.read(weatherViewModelProvider).cityName;
            if (city.isNotEmpty) {
              await ref.read(weatherViewModelProvider.notifier).refresh(
                    CityBean(areaCode: '', cityName: city),
                  );
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            children: [
              const SizedBox(height: 20),
              const Center(
                  child: Text('生活指数',
                      style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 23,
                          fontWeight: FontWeight.w500))),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => context.push(RoutePaths.lifeTips),
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(14)),
                  child: Stack(fit: StackFit.expand, children: [
                    Image.asset(AppAssets.toolboxLifeBanner, fit: BoxFit.cover),
                    const Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                            padding: EdgeInsets.all(13),
                            child: Text('健康生活指南',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600)))),
                  ]),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(37, 8, 37, 0),
                child: Text('注意：健康建议并非规范建议，也不具备法律效力，在任何时候，如有身体不适者应立即就医并遵医嘱。',
                    style: TextStyle(
                        color: Color(0xFFFF8086), fontSize: 11, height: 1.45)),
              ),
              const SizedBox(height: 29),
              _PollutantCard(items: pollution),
              const Padding(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 14),
                  child: Text('生活指南',
                      style: TextStyle(
                          color: Color(0xFF484848),
                          fontSize: 18,
                          fontWeight: FontWeight.w600))),
              SizedBox(
                height: 143,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final guides = [
                      _Guide(
                          '运动指数',
                          air?.category.contains('优') == true ||
                                  air?.category.contains('良') == true
                              ? '适宜'
                              : '较不宜',
                          AppAssets.toolboxLifeSport,
                          const Color(0xFFD7F7E1),
                          const Color(0xFF3BA86B)),
                      _Guide('洗车指数', '适宜', AppAssets.toolboxLifeCar,
                          const Color(0xFFD7F7E1), const Color(0xFF3BA86B)),
                      _Guide('穿衣指数', '舒适', AppAssets.toolboxLifeClothing,
                          const Color(0xFFD9E8FF), const Color(0xFF3D83F7)),
                    ];
                    final guide = guides[i];
                    return _GuideCard(
                        title: guide.title,
                        value: guide.value,
                        icon: guide.icon,
                        background: guide.background,
                        foreground: guide.foreground);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pollutant {
  final String name;
  final String? value;
  final String icon;
  final String fallback;
  const _Pollutant(this.name, this.value, this.icon, this.fallback);
}

class _Guide {
  final String title;
  final String value;
  final String icon;
  final Color background;
  final Color foreground;
  const _Guide(
      this.title, this.value, this.icon, this.background, this.foreground);
}

class _PollutantCard extends StatelessWidget {
  final List<_Pollutant> items;
  const _PollutantCard({required this.items});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('污染物浓度',
                style: TextStyle(
                    color: Color(0xFF484848),
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 16),
                child: Text(
                    '空气质量由空气污染物确定，污染物浓度越高，对人体的危害越大。污染物包括固体颗粒、滴液和气体的混合物，它们有多种来源，例如家庭燃料燃烧、工业生产、交通废气、发电、露天焚烧、沙尘等。',
                    style: TextStyle(
                        color: Color(0xFF8D8D8D), fontSize: 11, height: 1.45))),
            Row(children: _row(items.take(3).toList())),
            const SizedBox(height: 10),
            Row(children: _row(items.skip(3).toList())),
          ]),
        ),
      );

  List<Widget> _row(List<_Pollutant> row) => List.generate(
        row.length,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == row.length - 1 ? 0 : 10),
            child: _PollutantItem(item: row[index]),
          ),
        ),
      );
}

class _PollutantItem extends StatelessWidget {
  final _Pollutant item;
  const _PollutantItem({required this.item});
  @override
  Widget build(BuildContext context) => Container(
        height: 96,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(item.icon, width: 26, height: 26),
            const SizedBox(height: 3),
            Text(item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF8D8D8D), fontSize: 11)),
            const SizedBox(height: 4),
            Text(item.value?.isNotEmpty == true ? item.value! : item.fallback,
                style: const TextStyle(color: Color(0xFF484848), fontSize: 18)),
          ],
        ),
      );
}

class _GuideCard extends StatelessWidget {
  final String title, value, icon;
  final Color background, foreground;
  const _GuideCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.background,
      required this.foreground});
  @override
  Widget build(BuildContext context) => Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
          width: 118,
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Image.asset(icon, width: 56, height: 56),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFF484848),
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 7),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(13)),
                    child: Text(value,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: foreground, fontSize: 13)))
              ]))));
}
