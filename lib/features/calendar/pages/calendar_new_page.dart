import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/lunar_util.dart';
import '../../../router/route_names.dart';

class CalendarNewPage extends StatefulWidget {
  const CalendarNewPage({super.key});
  @override
  State<CalendarNewPage> createState() => _CalendarNewPageState();
}

class _CalendarNewPageState extends State<CalendarNewPage> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month),
      selected = DateTime.now();
  @override
  Widget build(BuildContext c) => Scaffold(
      backgroundColor: const Color(0xFFE4F6FF),
      body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(children: [
                SizedBox(
                    height: 72,
                    child: Stack(children: [
                      const Center(
                          child: Text('日历',
                              style: TextStyle(
                                  color: Color(0xFF1E1E1E),
                                  fontSize: 23,
                                  fontWeight: FontWeight.w500))),
                      Positioned(
                          right: 20,
                          top: 12,
                          child: IconButton(
                              onPressed: () => c.push(RoutePaths.setting),
                              icon: Image.asset(AppAssets.zyytCalendarProfile,
                                  width: 24, height: 24)))
                    ])),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                      onPressed: () => setState(
                          () => month = DateTime(month.year, month.month - 1)),
                      icon: const Text('‹',
                          style: TextStyle(
                              fontSize: 32, color: Color(0xFF969696)))),
                  Text('${month.year}年${month.month}月',
                      style: const TextStyle(
                          color: Color(0xFF515151),
                          fontSize: 20,
                          fontWeight: FontWeight.w600)),
                  IconButton(
                      onPressed: () => setState(
                          () => month = DateTime(month.year, month.month + 1)),
                      icon: const Text('›',
                          style: TextStyle(
                              fontSize: 32, color: Color(0xFF969696))))
                ]),
                _Calendar(
                    month: month,
                    selected: selected,
                    onSelect: (d) => setState(() => selected = d)),
                const SizedBox(height: 10),
                GestureDetector(
                    onTap: () => c.push(RoutePaths.longTrip),
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image: AssetImage(
                                    AppAssets.zyytCalendarTripBanner),
                                fit: BoxFit.cover)))),
                const SizedBox(height: 30),
                _HealthCard()
              ]))));
}

class _Calendar extends StatelessWidget {
  final DateTime month, selected;
  final ValueChanged<DateTime> onSelect;
  const _Calendar(
      {required this.month, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext c) {
    final first = DateTime(month.year, month.month, 1),
        lead = first.weekday - 1,
        days = DateTime(month.year, month.month + 1, 0).day;
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        elevation: 1,
        color: const Color(0xFFE9F9FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(
                  children: ['一', '二', '三', '四', '五', '六', '日']
                      .map((x) => Expanded(
                          child: Center(
                              child: Text(x,
                                  style: const TextStyle(
                                      color: Color(0xFF5F5F5F),
                                      fontSize: 13)))))
                      .toList()),
              const SizedBox(height: 10),
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 42,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7),
                  itemBuilder: (_, i) {
                    final n = i - lead + 1;
                    if (n < 1 || n > days) return const SizedBox();
                    final d = DateTime(month.year, month.month, n),
                        sel = d.year == selected.year &&
                            d.month == selected.month &&
                            d.day == selected.day;
                    return GestureDetector(
                        onTap: () => onSelect(d),
                        child: Container(
                            margin: const EdgeInsets.all(3),
                            decoration: sel
                                ? BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: const [
                                        BoxShadow(
                                            blurRadius: 3,
                                            color: Color(0x33000000))
                                      ])
                                : null,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('$n',
                                      style: const TextStyle(
                                          color: Color(0xFF5B5B5B),
                                          fontSize: 16)),
                                  Text(LunarUtil.lunarLabel(d),
                                      style: const TextStyle(
                                          color: Color(0xFF999999),
                                          fontSize: 9),
                                      maxLines: 1)
                                ])));
                  })
            ])));
  }
}

class _HealthCard extends StatelessWidget {
  @override
  Widget build(BuildContext c) => Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('健康生活方式',
                style: TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 15),
            Row(children: [
              _item(c, '营养', AppAssets.zyytCalendarNutrition,
                  () => c.push(RoutePaths.nutrition)),
              _item(c, '如何缓解压力?', AppAssets.zyytCalendarStress,
                  () => c.push(RoutePaths.stress))
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _item(c, '24节气', AppAssets.zyytCalendarSolarTerm,
                  () => c.push(RoutePaths.solarTerms)),
              _item(c, '历史上的今天', AppAssets.zyytCalendarHistory,
                  () => c.push(RoutePaths.historyToday))
            ])
          ])));
}

Widget _item(BuildContext context, String t, String icon, VoidCallback onTap) =>
    Expanded(
        child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
                height: 60,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: const Color(0xFFE6F7FD),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Image.asset(icon, width: 32, height: 32),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(t,
                          style: const TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 13,
                              fontWeight: FontWeight.w500)))
                ]))));
