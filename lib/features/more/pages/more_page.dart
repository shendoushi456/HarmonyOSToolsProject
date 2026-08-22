import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/route_names.dart';
import '../../setting/utils/app_info_util.dart';
import '../../weather/viewmodels/weather_view_model.dart';
import '../models/more_tool.dart';
import '../viewmodels/more_view_model.dart';

const _pageBackground = Color(0xFFF6F8FA);
const _textColor = Color(0xFF222222);
const _subtextColor = Color(0xFF747B83);

/// Android MoreFragment 的第四个 Tab。
/// 不包含放大镜、消息通知、提醒方式和提示音四项。
class MorePage extends ConsumerStatefulWidget {
  const MorePage({super.key});

  @override
  ConsumerState<MorePage> createState() => _MorePageState();
}

class _MorePageState extends ConsumerState<MorePage> {
  Future<void> _selectCity() async {
    final changed = await context.push<bool>(RoutePaths.citySelect);
    if (changed == true && mounted) {
      await ref.read(moreViewModelProvider.notifier).load(refreshWeather: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moreState = ref.watch(moreViewModelProvider);
    final weather = ref.watch(weatherViewModelProvider);
    final today = weather.today;
    final temp = today == null
        ? (weather.isLoading ? '加载中...' : '---')
        : '${today.tempMin}°~${today.tempMax}°';

    const tools = [
      MoreTool(
          title: '时间屏幕',
          icon: Icons.access_time_rounded,
          color: Color(0xFFFFCCAD)),
      MoreTool(
          title: '指南针', icon: Icons.explore_rounded, color: Color(0xFF6FABDC)),
      MoreTool(
          title: '计算器',
          icon: Icons.calculate_rounded,
          color: Color(0xFF71CEC8)),
    ];

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _MoreHeader(
              cityName: moreState.city?.cityName ?? '北京',
              temperature: temp,
              weatherText: today?.textDay ?? '',
              onCityTap: _selectCity),
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List<Widget>.generate(tools.length, (index) {
                          final tool = tools[index];
                          return _ToolCard(
                              tool: tool, onTap: () => _openTool(index));
                        }))),
                const SizedBox(height: 28),
                _SettingsCard(items: [
                  _SettingItem(
                      title: '隐私协议',
                      icon: Icons.verified_user_outlined,
                      onTap: () => context.push(RoutePaths.policy,
                          extra: {'title': '隐私政策', 'url': SettingUrls.policy})),
                  _SettingItem(
                      title: '用户协议',
                      icon: Icons.description_outlined,
                      onTap: () => context.push(RoutePaths.policy,
                          extra: {'title': '用户协议', 'url': SettingUrls.user})),
                  _SettingItem(
                      title: '意见反馈',
                      icon: Icons.chat_bubble_outline_rounded,
                      onTap: () => context.push(RoutePaths.feedback)),
                  _SettingItem(
                      title: '关于我们',
                      icon: Icons.info_outline_rounded,
                      onTap: () => context.push(RoutePaths.about)),
                ])
              ]))
        ]),
      ),
    );
  }

  void _openTool(int index) {
    switch (index) {
      case 0:
        context.push(RoutePaths.timeScreen);
        return;
      case 1:
        context.push(RoutePaths.compass);
        return;
      case 2:
        context.push(RoutePaths.calculator);
        return;
    }
  }
}

class _MoreHeader extends StatelessWidget {
  final String cityName;
  final String temperature;
  final String weatherText;
  final VoidCallback onCityTap;
  const _MoreHeader({
    required this.cityName,
    required this.temperature,
    required this.weatherText,
    required this.onCityTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
      height: 54,
      child: Stack(children: [
        Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
                onPressed: onCityTap,
                icon: const Icon(Icons.location_on_outlined,
                    size: 18, color: _textColor),
                label: Text(cityName,
                    style: const TextStyle(fontSize: 13, color: _textColor)))),
        const Center(
            child: Text('更多',
                style: TextStyle(
                    color: _textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold))),
        Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
                onPressed: onCityTap,
                icon: Text(temperature,
                    style: const TextStyle(fontSize: 12, color: _textColor)),
                label: Icon(_weatherIcon(weatherText),
                    size: 21, color: const Color(0xFFFFB33E))))
      ]));
}

IconData _weatherIcon(String text) {
  if (text.contains('雨') || text.contains('雪')) {
    return Icons.umbrella_outlined;
  }
  if (text.contains('云') || text.contains('阴')) {
    return Icons.cloud_queue_rounded;
  }
  return Icons.wb_sunny_outlined;
}

class _ToolCard extends StatelessWidget {
  final MoreTool tool;
  final VoidCallback onTap;
  const _ToolCard({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
      width: (MediaQuery.sizeOf(context).width - 50) / 2,
      child: Material(
          color: tool.color,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  child: Row(children: [
                    Icon(tool.icon, size: 40, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(tool.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)))
                  ])))));
}

class _SettingItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _SettingItem(
      {required this.title, required this.icon, required this.onTap});
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingItem> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 2,
      shadowColor: const Color(0x16000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
          children: List<Widget>.generate(items.length, (index) {
        final item = items[index];
        return Column(children: [
          ListTile(
              onTap: item.onTap,
              leading:
                  Icon(item.icon, size: 22, color: const Color(0xFF62BFC5)),
              title: Text(item.title,
                  style: const TextStyle(fontSize: 15, color: _textColor)),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: _subtextColor)),
          if (index != items.length - 1)
            const Divider(height: 1, indent: 54, endIndent: 16)
        ]);
      })));
}
