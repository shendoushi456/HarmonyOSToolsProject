// 长途规划页：Android LongTripPlanActivity 的 Flutter 迁移，业务状态由 ViewModel 管理。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/standard_page_header.dart';
import '../../weather/models/weather_warning.dart';
import '../models/long_trip_models.dart';
import '../viewmodels/long_trip_view_model.dart';
import 'trip_city_picker_page.dart';

class LongTripPage extends ConsumerStatefulWidget {
  const LongTripPage({super.key});
  @override
  ConsumerState<LongTripPage> createState() => _LongTripPageState();
}

class _LongTripPageState extends ConsumerState<LongTripPage> {
  bool editing = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(longTripViewModelProvider);
    final warnings = _visibleWarnings(state.plans, state.weatherByCity);
    final weatherLoading =
        state.weatherByCity.values.any((item) => item.loading);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D0E),
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          StandardPageHeader(
              title: '沿途天气预警',
              leading: IconButton(
                  tooltip: '返回',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 22))),
          _RouteSelector(draft: state.draft, onTap: _addPoint),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  if (!editing &&
                      !state.draft.hasContent &&
                      state.plans.isEmpty)
                    const _EmptyContent(),
                  if (editing || state.draft.hasContent)
                    _DraftEditor(
                      draft: state.draft,
                      saving: state.saving,
                      onRemove: (role, index) => ref
                          .read(longTripViewModelProvider.notifier)
                          .removePoint(role, index),
                      onSave: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final result = await ref
                            .read(longTripViewModelProvider.notifier)
                            .saveDraft();
                        if (!mounted) {
                          return;
                        }
                        if (result.planSaved) {
                          setState(() => editing = false);
                        }
                        messenger.showSnackBar(SnackBar(
                            content: Text(result.message ?? '长途规划已保存')));
                      },
                    ),
                  if (state.plans.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const _PlanTitle(),
                    const SizedBox(height: 14),
                    ...state.plans.map((plan) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _SavedPlanCard(
                            plan: plan,
                            weatherByCity: state.weatherByCity,
                            onLongPress: () => _confirmDelete(plan),
                          ),
                        )),
                  ],
                  if (warnings.isNotEmpty)
                    ...warnings.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TravelWarningCard(item: item))),
                  if (state.plans.isNotEmpty &&
                      !weatherLoading &&
                      warnings.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: _NoTravelWarnings(),
                    ),
                  const SizedBox(height: 4),
                  const _TravelSuggestions(),
                ]),
          ),
        ]),
      ),
    );
  }

  Future<void> _addPoint(LongTripPointRole role) async {
    if (role != LongTripPointRole.start &&
        ref.read(longTripViewModelProvider).draft.start == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请先选择起点')));
      return;
    }
    setState(() => editing = true);
    final point = await showDialog<LongTripPoint>(
        context: context, builder: (_) => _PointDialog(role: role));
    if (point == null || !mounted) {
      return;
    }
    final message =
        ref.read(longTripViewModelProvider.notifier).addPoint(role, point);
    if (message != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmDelete(LongTripPlan plan) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('确认删除'),
              content: const Text('是否确认删除这条长途规划？删除后无法恢复。'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('取消')),
                FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626)),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('确认删除'))
              ],
            ));
    if (confirmed == true) {
      await ref.read(longTripViewModelProvider.notifier).deletePlan(plan.id);
    }
  }
}

class _RouteSelector extends StatelessWidget {
  final LongTripDraft draft;
  final ValueChanged<LongTripPointRole> onTap;
  const _RouteSelector({required this.draft, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 96,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        for (final role in LongTripPointRole.values)
          _RouteAction(
              role: role,
              hasValue: role == LongTripPointRole.start
                  ? draft.start != null
                  : role == LongTripPointRole.end
                      ? draft.end != null
                      : draft.waypoints.isNotEmpty,
              onTap: () => onTap(role))
      ]));
}

class _RouteAction extends StatelessWidget {
  final LongTripPointRole role;
  final bool hasValue;
  final VoidCallback onTap;
  const _RouteAction(
      {required this.role, required this.hasValue, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: SizedBox(
          width: 72,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                width: role == LongTripPointRole.waypoint ? 44 : 58,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: role == LongTripPointRole.waypoint
                        ? Colors.white
                        : const Color(0xFF1BCACD),
                    border: role == LongTripPointRole.waypoint
                        ? Border.all(color: const Color(0xFF1BCACD))
                        : null,
                    borderRadius: BorderRadius.circular(
                        role == LongTripPointRole.waypoint ? 22 : 8)),
                child: Text('+',
                    style: TextStyle(
                        color: role == LongTripPointRole.waypoint
                            ? const Color(0xFF1BCACD)
                            : Colors.white,
                        fontSize:
                            role == LongTripPointRole.waypoint ? 27 : 16))),
            const SizedBox(height: 7),
            Text(role.label,
                style: TextStyle(
                    color: hasValue
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600))
          ])));
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 34),
      child: Column(children: [
        Image.asset(AppAssets.longTripEmpty, width: 220),
        const SizedBox(height: 18),
        const Text('暂无长途记录',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        const Text('请选择起点和终点，生成沿途天气预警',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14))
      ]));
}

class _DraftEditor extends StatelessWidget {
  final LongTripDraft draft;
  final bool saving;
  final void Function(LongTripPointRole, int) onRemove;
  final VoidCallback onSave;
  const _DraftEditor(
      {required this.draft,
      required this.saving,
      required this.onRemove,
      required this.onSave});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (!draft.hasContent)
          const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text('请先选择起点，再添加途径点或选择终点',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14))),
        if (draft.start != null)
          _DraftPoint(
              title: '起点',
              point: draft.start!,
              image: AppAssets.longTripStart,
              onRemove: () => onRemove(LongTripPointRole.start, 0)),
        ...List.generate(
            draft.waypoints.length,
            (index) => _DraftPoint(
                title: '途径点 ${index + 1}',
                point: draft.waypoints[index],
                image: AppAssets.longTripWaypoint,
                onRemove: () => onRemove(LongTripPointRole.waypoint, index))),
        if (draft.end != null)
          _DraftPoint(
              title: '终点',
              point: draft.end!,
              image: AppAssets.longTripEnd,
              onRemove: () => onRemove(LongTripPointRole.end, 0)),
        const SizedBox(height: 14),
        FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1F70BD),
                minimumSize: const Size.fromHeight(48)),
            onPressed: saving ? null : onSave,
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('保存长途规划'))
      ]);
}

class _DraftPoint extends StatelessWidget {
  final String title, image;
  final LongTripPoint point;
  final VoidCallback onRemove;
  const _DraftPoint(
      {required this.title,
      required this.point,
      required this.image,
      required this.onRemove});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Container(
            height: 73,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Image.asset(image, width: 34, height: 34),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(point.cityName,
                        style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const Text('24小时天气',
                        style:
                            TextStyle(color: Color(0xFF64748B), fontSize: 12))
                  ])),
              Text(_date(point.date),
                  style:
                      const TextStyle(color: Color(0xFF1E293B), fontSize: 13)),
              IconButton(
                  onPressed: onRemove,
                  icon: Image.asset(AppAssets.longTripRemove,
                      width: 18, height: 18))
            ]))
      ]));
}

class _PlanTitle extends StatelessWidget {
  const _PlanTitle();
  @override
  Widget build(BuildContext context) => const Row(children: [
        Text('长途规划列表',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        Spacer(),
        Text('自动避开恶劣天气  ◉', style: TextStyle(color: Colors.white, fontSize: 12))
      ]);
}

class _SavedPlanCard extends StatelessWidget {
  final LongTripPlan plan;
  final Map<String, LongTripCityWeather> weatherByCity;
  final VoidCallback onLongPress;
  const _SavedPlanCard(
      {required this.plan,
      required this.weatherByCity,
      required this.onLongPress});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onLongPress: onLongPress,
      child: AspectRatio(
          aspectRatio: 1005 / 513,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(AppAssets.longTripRouteBackground, fit: BoxFit.fill),
            ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(14),
                itemCount: plan.points.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, index) {
                  final point = plan.points[index];
                  final role = index == 0
                      ? '起点'
                      : index == plan.points.length - 1
                          ? '终点'
                          : '途径点';
                  final cityWeather = weatherByCity[point.weatherKey];
                  final forecast = cityWeather?.forecasts
                      .where((item) =>
                          item.fxDate ==
                          DateFormat('yyyy-MM-dd').format(point.date))
                      .cast()
                      .firstOrNull;
                  final weather = cityWeather == null || cityWeather.loading
                      ? '天气获取中'
                      : forecast?.textDay ?? '暂无天气';
                  return SizedBox(
                      width: 98,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(point.cityName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                            Text(_date(point.date),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11)),
                            const SizedBox(height: 8),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                    color: role == '途径点'
                                        ? Colors.white
                                        : const Color(0xFF1BCACD),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(role,
                                    style: TextStyle(
                                        color: role == '途径点'
                                            ? const Color(0xFFD97706)
                                            : const Color(0xFF2563EB),
                                        fontSize: 11))),
                            const SizedBox(height: 8),
                            Text(weather,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12))
                          ]));
                })
          ])));
}

class _TravelSuggestions extends StatelessWidget {
  const _TravelSuggestions();
  @override
  Widget build(BuildContext context) =>
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('出行防灾建议',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _Suggestion(
            image: AppAssets.longTripSuggestionRoute,
            title: '调整路线策略',
            detail: '绕行高风险天气区域，出发前关注最新预警信息。'),
        SizedBox(height: 10),
        _Suggestion(
            image: AppAssets.longTripSuggestionSupply,
            title: '备用应急物资',
            detail: '随车准备雨具、应急手电筒、防滑垫片并检查轮胎气压。')
      ]);
}

class _NoTravelWarnings extends StatelessWidget {
  const _NoTravelWarnings();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified_outlined, color: Color(0xFF1BCACD), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '暂无沿途天气预警信息，请放心出行。',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      );
}

class _Suggestion extends StatelessWidget {
  final String image, title, detail;
  const _Suggestion(
      {required this.image, required this.title, required this.detail});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Image.asset(image, width: 36, height: 36),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(detail,
              style: const TextStyle(
                  color: Color(0xFF64748B), fontSize: 12, height: 1.45))
        ]))
      ]));
}

class _TravelWarning {
  final String city, role;
  final WeatherWarning warning;
  const _TravelWarning(this.city, this.role, this.warning);
}

class _TravelWarningCard extends StatefulWidget {
  final _TravelWarning item;
  const _TravelWarningCard({required this.item});
  @override
  State<_TravelWarningCard> createState() => _TravelWarningCardState();
}

class _TravelWarningCardState extends State<_TravelWarningCard> {
  var expanded = false;

  @override
  Widget build(BuildContext context) {
    final warning = widget.item.warning;
    final detail = warning.description.isNotEmpty
        ? warning.description
        : warning.instruction;
    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4C7),
          border: Border.all(color: const Color(0xFFF0B429)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(AppAssets.longTripAlert, width: 20, height: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.item.role}${widget.item.city}：${warning.headline.isEmpty ? warning.eventName : warning.headline}',
                    style: const TextStyle(
                      color: Color(0xFF7A4A00),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (detail.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        detail,
                        maxLines: expanded ? null : 4,
                        overflow: expanded ? null : TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B4F1D),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointDialog extends StatefulWidget {
  final LongTripPointRole role;
  const _PointDialog({required this.role});
  @override
  State<_PointDialog> createState() => _PointDialogState();
}

class _PointDialogState extends State<_PointDialog> {
  LongTripCitySelection? _city;
  DateTime date = DateTime.now();

  Future<void> _selectCity() async {
    final city = await Navigator.of(context).push<LongTripCitySelection>(
        MaterialPageRoute(builder: (_) => const TripCityPickerPage()));
    if (city != null && mounted) setState(() => _city = city);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: Text('添加${widget.role.label}'),
          content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            InkWell(
              onTap: _selectCity,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 52,
                padding: const EdgeInsets.only(left: 14, right: 8),
                decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FC),
                    border: Border.all(color: const Color(0xFFD5DFEA)),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Expanded(
                    child: Text(_city?.cityName ?? '请从城市列表选择地点',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: _city == null
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF1E293B),
                            fontSize: 15)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1F70BD),
                        borderRadius: BorderRadius.circular(18)),
                    child: const Text('选择',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('时间'),
                subtitle: Text(_date(date)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final result = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 14)));
                  if (result != null) {
                    setState(() => date = result);
                  }
                })
          ])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消')),
            FilledButton(
                onPressed: () {
                  if (_city != null) {
                    Navigator.pop(context, _city!.toPoint(date));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请先从城市列表选择地点')));
                  }
                },
                child: const Text('确定'))
          ]);
}

List<_TravelWarning> _visibleWarnings(
    List<LongTripPlan> plans, Map<String, LongTripCityWeather> weather) {
  final values = <_TravelWarning>[];
  final seen = <String>{};
  for (final plan in plans) {
    for (var index = 0; index < plan.points.length; index++) {
      final point = plan.points[index];
      if (!seen.add(point.weatherKey)) {
        continue;
      }
      final item = weather[point.weatherKey]?.warnings.firstOrNull;
      if (item != null) {
        values.add(_TravelWarning(
            point.cityName,
            index == 0
                ? '起点'
                : index == plan.points.length - 1
                    ? '终点'
                    : '途径点',
            item));
      }
      if (values.length == 2) {
        return values;
      }
    }
  }
  return values;
}

String _date(DateTime value) => DateFormat('yyyy.M.d').format(value);

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
