import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/weather_icon_util.dart';
import '../../../router/route_names.dart';
import '../../image_process/models/image_process_type.dart';
import '../../image_process/pages/image_process_page.dart';
import '../../life_tools/pages/checklist/checklist_page.dart';
import '../../life_tools/pages/compass/compass_page.dart';
import '../../life_tools/pages/tally/tally_page.dart';
import '../../portable_tools/pages/magnifier_camera_page.dart';
import '../../portable_tools/pages/watermark_image_page.dart';
import '../../scan_menu/pages/currency_converter_page.dart';
import '../../weather/models/city_bean.dart';
import '../../weather/repositories/city_repository.dart';
import '../../weather/viewmodels/weather_view_model.dart';

class ScanToolsPage extends ConsumerStatefulWidget {
  const ScanToolsPage({super.key});
  @override
  ConsumerState<ScanToolsPage> createState() => _ScanToolsPageState();
}

class _ScanToolsPageState extends ConsumerState<ScanToolsPage> {
  final _cityRepository = CityRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSavedCity());
  }

  Future<void> _loadSavedCity() async {
    final cities = await _cityRepository.loadCities();
    if (!mounted) return;
    await ref
        .read(weatherViewModelProvider.notifier)
        .loadData(cities.isEmpty ? CityBean.defaultCity() : cities.first);
  }

  Future<void> _changeCity() async {
    final changed = await context.push<bool>(RoutePaths.citySelect);
    if (changed != true || !mounted) return;
    await _loadSavedCity();
  }

  @override
  Widget build(BuildContext context) {
    final w = ref.watch(weatherViewModelProvider), t = w.today;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          Positioned.fill(
              child:
                  Image.asset(AppAssets.toolboxYzsmHomeBg, fit: BoxFit.fill)),
          SafeArea(
              bottom: false,
              child: Column(children: [
                _StatusBar(
                    city: w.cityName.isEmpty ? '北京市' : w.cityName,
                    temperature:
                        '${t?.tempMin ?? '18'}°-${t?.tempMax ?? '26'}°',
                    weatherIcon: WeatherIconUtil.toolboxDayIcon(
                        t?.iconDay ?? '', t?.textDay ?? '晴'),
                    onCity: _changeCity,
                    onWeather: () => context.push(RoutePaths.weather)),
                Expanded(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 45),
                        child: Column(children: [
                          _Banner(
                              title: '图像动漫化',
                              subtitle: '拥有专属动漫形象',
                              image: AppAssets.toolboxYzsmCartoon,
                              color: const Color(0xFFFFE4E9),
                              onTap: () => _openImage(
                                  context, ImageProcessType.selfieAnime)),
                          _Banner(
                              title: '图像风格转换',
                              subtitle: '一键切换图片风格',
                              image: AppAssets.toolboxYzsmStyle,
                              color: const Color(0xFFE7FFCD),
                              onTap: () => _openImage(
                                  context, ImageProcessType.styleTransfer)),
                          _GridRow(children: [
                            _Utility(
                                title: '指南针',
                                subtitle: '精准辨向出行无忧',
                                icon: AppAssets.toolboxYzsmCompass,
                                top: const Color(0xFFE6FDFD),
                                accent: const Color(0xFF19D2D2),
                                onTap: () => CompassPage.push(context)),
                            _Utility(
                                title: '汇率换算',
                                subtitle: '实时汇率一键换算',
                                icon: AppAssets.toolboxYzsmExchange,
                                top: const Color(0xFFFFF3E9),
                                accent: const Color(0xFFE09E66),
                                onTap: () =>
                                    CurrencyConverterPage.push(context))
                          ]),
                          _GridRow(children: [
                            _Utility(
                                title: '花费记账',
                                subtitle: '日常开销一键记账',
                                icon: AppAssets.toolboxYzsmExpense,
                                top: const Color(0xFFFFE9E9),
                                accent: const Color(0xFFF28888),
                                onTap: () => TallyPage.push(context)),
                            _Utility(
                                title: '旅行清单',
                                subtitle: '出行清单一键备齐',
                                icon: AppAssets.toolboxYzsmTravel,
                                top: const Color(0xFFE3EEFF),
                                accent: const Color(0xFF6193E3),
                                onTap: () => ChecklistPage.push(context))
                          ]),
                          _GridRow(children: [
                            _Utility(
                                title: '放大镜',
                                subtitle: '清晰放大查看细节',
                                icon: AppAssets.toolboxYzsmMagnifier,
                                top: const Color(0xFFF3F0FF),
                                accent: const Color(0xFF8B80F7),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const MagnifierCameraPage()))),
                            _Utility(
                                title: '添加水印',
                                subtitle: '一键添加水印安全无忧',
                                icon: AppAssets.toolboxYzsmWatermark,
                                top: const Color(0xFFE7FFF0),
                                accent: const Color(0xFF4DD98C),
                                onTap: () => WatermarkImagePage.push(context))
                          ]),
                        ])))
              ]))
        ]));
  }

  void _openImage(BuildContext c, ImageProcessType type) => Navigator.push(
      c, MaterialPageRoute(builder: (_) => ImageProcessPage(type: type)));
}

class _StatusBar extends StatelessWidget {
  final String city, temperature, weatherIcon;
  final VoidCallback onCity, onWeather;
  const _StatusBar(
      {required this.city,
      required this.temperature,
      required this.weatherIcon,
      required this.onCity,
      required this.onWeather});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(children: [
          Expanded(
              child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onCity,
                  child: Row(children: [
                    Image.asset(AppAssets.toolboxYzsmLocation,
                        width: 18, height: 18),
                    const SizedBox(width: 4),
                    Flexible(
                        child: Text(city,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14)))
                  ]))),
          const Expanded(
              child: Center(
                  child: Text('常用工具',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w500)))),
          Expanded(
              child: GestureDetector(
                  onTap: onWeather,
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(temperature, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Image.asset(weatherIcon, width: 20, height: 20)
                  ]))),
        ]),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String title, subtitle, image;
  final Color color;
  final VoidCallback onTap;
  const _Banner(
      {required this.title,
      required this.subtitle,
      required this.image,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
              width: 335,
              height: 84,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                SizedBox(
                    width: 84,
                    height: 52,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: Image.asset(image, fit: BoxFit.contain))),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3C3C3C))),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF9F9F9F)))
                    ])),
                Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Image.asset(AppAssets.toolboxYzsmArrow,
                        width: 20, height: 20))
              ]))));
}

class _GridRow extends StatelessWidget {
  final List<Widget> children;
  const _GridRow({required this.children});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SizedBox(
          width: 335,
          child: Row(children: [
            Expanded(child: children[0]),
            const SizedBox(width: 15),
            Expanded(child: children[1]),
          ]),
        ),
      );
}

class _Utility extends StatelessWidget {
  final String title, subtitle, icon;
  final Color top, accent;
  final VoidCallback onTap;
  const _Utility(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.top,
      required this.accent,
      required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 160,
          padding: const EdgeInsets.fromLTRB(16, 16, 10, 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [top, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(15),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset(icon, width: 36, height: 36),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333))),
            const SizedBox(height: 4),
            Text(subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
            const SizedBox(height: 13),
            Container(
                width: 60,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: accent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(28)),
                child: Text('点击使用',
                    style: TextStyle(fontSize: 10, color: accent))),
          ]),
        ),
      );
}
