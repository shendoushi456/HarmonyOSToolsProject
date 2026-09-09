// 长途规划页：Android LongTripPlanActivity(Compose 版)的 Flutter 迁移。
// 业务状态复用 longTripViewModelProvider(草稿/保存/删除/天气加载)，
// 本文件只负责展示 UI，方便后续马甲包整体替换。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../weather/models/weather_warning.dart';
import '../models/long_trip_models.dart';
import '../viewmodels/long_trip_view_model.dart';
import 'trip_city_picker_page.dart';

class LongTripPlanPage extends ConsumerStatefulWidget {
  const LongTripPlanPage({super.key});
  @override
  ConsumerState<LongTripPlanPage> createState() => _LongTripPlanPageState();
}

class _LongTripPlanPageState extends ConsumerState<LongTripPlanPage> {
  /// 对齐 Android isEditing：选择了任一角色后进入编辑态
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(longTripViewModelProvider);
    final warnings = _visibleWarnings(state.plans, state.weatherByCity);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 对齐 ImmersionBar.fullScreen + statusBarDarkFont(false)：白字状态栏
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF208FEA), Color(0xFF69C4F3)],
            ),
          ),
          child: Column(children: [
            _LongTripHeader(onBack: () => Navigator.of(context).maybePop()),
            _RouteSelectorCard(
              draft: state.draft,
              onRoleClick: _onRoleClick,
            ),
            if (_editing)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                    _DraftRouteEditor(
                      draft: state.draft,
                      saving: state.saving,
                      onRemove: (role, index) => ref
                          .read(longTripViewModelProvider.notifier)
                          .removePoint(role, index),
                      onSave: _saveDraft,
                    ),
                  ],
                ),
              )
            else if (state.plans.isEmpty)
              const Expanded(child: _EmptyLongTripContent())
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                    const _PlanListTitle(),
                    const SizedBox(height: 14),
                    for (final plan in state.plans) ...[
                      _SavedRouteCard(
                        plan: plan,
                        weatherByCity: state.weatherByCity,
                        onLongPress: () => _confirmDelete(plan),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (warnings.isNotEmpty) ...[
                      for (final warning in warnings) ...[
                        _RealWarningCard(warning: warning),
                        const SizedBox(height: 10),
                      ],
                    ],
                    const _FixedTravelSuggestions(),
                  ],
                ),
              ),
          ]),
        ),
      ),
    );
  }

  /// 对齐 RouteSelectorCard.onRoleClick：途径点/终点需先有起点
  Future<void> _onRoleClick(LongTripPointRole role) async {
    final draft = ref.read(longTripViewModelProvider).draft;
    if (role != LongTripPointRole.start && draft.start == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请先选择起点')));
      return;
    }
    setState(() => _editing = true);
    final point = await showDialog<LongTripPoint>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _AddRoutePointDialog(role: role, draft: draft),
    );
    if (point == null) {
      // 对齐 Android onDismiss：草稿为空时退出编辑态
      if (mounted &&
          !ref.read(longTripViewModelProvider).draft.hasContent) {
        setState(() => _editing = false);
      }
      return;
    }
    if (!mounted) return;
    final message = ref
        .read(longTripViewModelProvider.notifier)
        .addPoint(role, point);
    if (message != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// 对齐 Android saveDraft：保存成功清草稿回列表，失败把原因显示在编辑器内
  Future<void> _saveDraft() async {
    final messenger = ScaffoldMessenger.of(context);
    final result =
        await ref.read(longTripViewModelProvider.notifier).saveDraft();
    if (!mounted) return;
    if (result.planSaved) {
      setState(() => _editing = false);
      if (result.duplicate && result.message != null) {
        messenger.showSnackBar(SnackBar(content: Text(result.message!)));
      }
    } else {
      messenger.showSnackBar(
          SnackBar(content: Text(result.message ?? '长途规划保存失败，请重试')));
    }
  }

  Future<void> _confirmDelete(LongTripPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _DeleteConfirmDialog(
        onDismiss: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    );
    if (confirmed == true) {
      await ref.read(longTripViewModelProvider.notifier).deletePlan(plan.id);
    }
  }
}

// ====== 顶部栏 - 对齐 LongTripHeader ======
class _LongTripHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _LongTripHeader({required this.onBack});
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      width: double.infinity,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 48,
                height: 48,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onBack,
                  child: Center(
                    child: Image.asset(AppAssets.longTripBack,
                        width: 27, height: 27),
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: Text(
                  '沿途天气预警',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ====== 路线选择卡 - 对齐 RouteSelectorCard ======
class _RouteSelectorCard extends StatelessWidget {
  final LongTripDraft draft;
  final ValueChanged<LongTripPointRole> onRoleClick;
  const _RouteSelectorCard({required this.draft, required this.onRoleClick});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 96,
      decoration: _whiteCardDecoration(10, 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _RouteSelectorAction(
              role: LongTripPointRole.start,
              hasValue: draft.start != null,
              onClick: () => onRoleClick(LongTripPointRole.start),
            ),
            _RouteSelectorAction(
              role: LongTripPointRole.waypoint,
              hasValue: draft.waypoints.isNotEmpty,
              onClick: () => onRoleClick(LongTripPointRole.waypoint),
            ),
            _RouteSelectorAction(
              role: LongTripPointRole.end,
              hasValue: draft.end != null,
              onClick: () => onRoleClick(LongTripPointRole.end),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单个选择动作 - 对齐 RouteSelectorAction
class _RouteSelectorAction extends StatelessWidget {
  final LongTripPointRole role;
  final bool hasValue;
  final VoidCallback onClick;
  const _RouteSelectorAction({
    required this.role,
    required this.hasValue,
    required this.onClick,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClick,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (role == LongTripPointRole.waypoint)
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD97706)),
                ),
                child: const Text('+',
                    style: TextStyle(
                        color: Color(0xFFD97706),
                        fontSize: 27,
                        fontWeight: FontWeight.w300)),
              )
            else
              Container(
                width: 58,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF238BF2),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text('选择',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 7),
            Text(
              role.label,
              style: TextStyle(
                  color: hasValue
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// 白色卡片通用装饰
BoxDecoration _whiteCardDecoration(double radius, double elevation) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: elevation * 0.05),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
      ),
    ],
  );
}

// ====== 空态 - 对齐 EmptyLongTripContent ======
class _EmptyLongTripContent extends StatelessWidget {
  const _EmptyLongTripContent();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FractionallySizedBox(
              widthFactor: 0.88,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 329),
                child: AspectRatio(
                  aspectRatio: 987 / 834,
                  child: Image.asset(AppAssets.longTripEmpty,
                      fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text('暂无长途记录',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text('每一次出发，都会帮您记录沿途天气',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ====== 草稿编辑器 - 对齐 DraftRouteEditor ======
class _DraftRouteEditor extends StatelessWidget {
  final LongTripDraft draft;
  final bool saving;
  final void Function(LongTripPointRole, int) onRemove;
  final Future<void> Function() onSave;
  const _DraftRouteEditor({
    required this.draft,
    required this.saving,
    required this.onRemove,
    required this.onSave,
  });

  /// 对齐 Android 保存按钮的本地校验文案
  String? _validationMessage() {
    if (draft.start == null) return '请先选择起点';
    if (draft.end == null) return '请先选择终点';
    if (!_hasPointsNotBeforeStart(draft)) return '途径点和终点时间不能早于起点';
    if (!_hasWaypointsNotAfterEnd(draft)) return '途径点时间不能晚于终点';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final validationMessage = _validationMessage();
    final waypointWidgets = <Widget>[];
    if (draft.waypoints.length <= 3) {
      for (var index = 0; index < draft.waypoints.length; index++) {
        waypointWidgets.add(_DraftPointSection(
          title: '途径点 ${index + 1}',
          point: draft.waypoints[index],
          icon: AppAssets.longTripWaypoint,
          onRemove: () => onRemove(LongTripPointRole.waypoint, index),
        ));
      }
    } else {
      waypointWidgets.add(const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text('途径点（上下滑动查看全部）',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ));
      waypointWidgets.add(ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: draft.waypoints.length,
          itemBuilder: (_, index) => _DraftPointSection(
            title: '途径点 ${index + 1}',
            point: draft.waypoints[index],
            icon: AppAssets.longTripWaypoint,
            onRemove: () => onRemove(LongTripPointRole.waypoint, index),
          ),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!draft.hasContent)
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Text('请先选择起点，再添加途径点或选择终点',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        if (draft.start != null)
          _DraftPointSection(
            title: '起点',
            point: draft.start!,
            icon: AppAssets.longTripStart,
            onRemove: () => onRemove(LongTripPointRole.start, 0),
          ),
        ...waypointWidgets,
        if (draft.end != null)
          _DraftPointSection(
            title: '终点',
            point: draft.end!,
            icon: AppAssets.longTripEnd,
            onRemove: () => onRemove(LongTripPointRole.end, 0),
          ),
        if (validationMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 4),
            child: Text(validationMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFFFFE4E6), fontSize: 12)),
          ),
        const SizedBox(height: 14),
        SizedBox(
          height: 43,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF238BF2),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: saving ? null : () => onSave(),
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('保存',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}

/// 对齐 hasPointsNotBeforeStart
bool _hasPointsNotBeforeStart(LongTripDraft draft) {
  final start = draft.start;
  if (start == null) return false;
  final startDate = _dateOnly(start.date);
  return [...draft.waypoints, if (draft.end != null) draft.end!]
      .every((point) => !_dateOnly(point.date).isBefore(startDate));
}

/// 对齐 hasWaypointsNotAfterEnd
bool _hasWaypointsNotAfterEnd(LongTripDraft draft) {
  final end = draft.end;
  if (end == null) return false;
  final endDate = _dateOnly(end.date);
  return draft.waypoints
      .every((point) => !_dateOnly(point.date).isAfter(endDate));
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

/// 单个草稿地点卡 - 对齐 DraftPointSection
class _DraftPointSection extends StatelessWidget {
  final String title;
  final LongTripPoint point;
  final String icon;
  final VoidCallback onRemove;
  const _DraftPointSection({
    required this.title,
    required this.point,
    required this.icon,
    required this.onRemove,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Container(
            height: 73,
            decoration: _whiteCardDecoration(10, 3),
            child: Row(children: [
              const SizedBox(width: 17),
              Image.asset(icon, width: 34, height: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(point.cityName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    const Text('24小时天气',
                        style:
                            TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ),
              Text(_formatRouteDate(point.date),
                  style: const TextStyle(
                      color: Color(0xFF1E293B), fontSize: 13)),
              SizedBox(
                width: 48,
                height: 48,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onRemove,
                  child: Center(
                    child: Image.asset(AppAssets.longTripRemove,
                        width: 17, height: 17),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ====== 列表标题 - 对齐 PlanListTitle ======
class _PlanListTitle extends StatelessWidget {
  const _PlanListTitle();
  @override
  Widget build(BuildContext context) {
    return const Row(children: [
      Text('长途规划列表',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
      Spacer(),
      Text('自动避开恶劣天气  ◉',
          style: TextStyle(color: Colors.white, fontSize: 12)),
    ]);
  }
}

// ====== 已保存路线卡 - 对齐 SavedRouteCard ======
class _SavedRouteCard extends StatelessWidget {
  final LongTripPlan plan;
  final Map<String, LongTripCityWeather> weatherByCity;
  final VoidCallback onLongPress;
  const _SavedRouteCard({
    required this.plan,
    required this.weatherByCity,
    required this.onLongPress,
  });
  @override
  Widget build(BuildContext context) {
    final points = plan.points;
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        decoration: _whiteCardDecoration(10, 3),
        child: SizedBox(
          height: 134,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14),
            itemCount: points.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final point = points[index];
              final roleName = index == 0
                  ? '起点'
                  : index == points.length - 1
                      ? '终点'
                      : '途径点';
              return _SavedRoutePoint(
                point: point,
                roleName: roleName,
                weatherState: weatherByCity[point.weatherKey],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 路线中的城市格 - 对齐 SavedRoutePoint
class _SavedRoutePoint extends StatelessWidget {
  final LongTripPoint point;
  final String roleName;
  final LongTripCityWeather? weatherState;
  const _SavedRoutePoint({
    required this.point,
    required this.roleName,
    required this.weatherState,
  });
  @override
  Widget build(BuildContext context) {
    final forecast = weatherState?.forecasts
        .where((item) => item.fxDate == point.routeDate)
        .firstOrNull;
    final weatherText = weatherState == null || weatherState!.loading
        ? '天气获取中'
        : forecast?.textDay ?? '暂无天气';
    final isWaypoint = roleName == '途径点';
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(point.cityName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          Text(_formatRouteDate(point.date),
              maxLines: 1,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: isWaypoint
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(roleName,
                style: TextStyle(
                    color: isWaypoint
                        ? const Color(0xFFD97706)
                        : const Color(0xFF238BF2),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (forecast != null) ...[
                Image.asset(_dayIcon(forecast.textDay),
                    width: 16, height: 16),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(weatherText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 对齐 WeatherUtils.getWeatherDayIcon(途经点天气小图标)
String _dayIcon(String weatherText) {
  if (weatherText.contains('晴')) return AppAssets.weatherDaySun;
  if (weatherText.contains('阴') || weatherText.contains('多云')) {
    return AppAssets.weatherDayCloudy;
  }
  if (weatherText.contains('雷')) return AppAssets.weatherDayRain;
  if (weatherText.contains('雨')) return AppAssets.weatherDayRain;
  return AppAssets.weatherDaySun;
}

// ====== 预警卡 - 对齐 RealWarningCard ======
class _LocatedWarning {
  final String cityName;
  final String roleName;
  final WeatherWarning alert;
  const _LocatedWarning(this.cityName, this.roleName, this.alert);
}

/// 对齐 buildVisibleWarnings：城市去重，最多 2 条
List<_LocatedWarning> _visibleWarnings(
    List<LongTripPlan> plans, Map<String, LongTripCityWeather> weather) {
  final result = <_LocatedWarning>[];
  final handledCities = <String>{};
  for (final plan in plans) {
    final points = plan.points;
    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      if (!handledCities.add(point.weatherKey)) continue;
      final alert = weather[point.weatherKey]?.warnings.firstOrNull;
      if (alert == null) continue;
      result.add(_LocatedWarning(
          point.cityName,
          index == 0
              ? '起点'
              : index == points.length - 1
                  ? '终点'
                  : '途径点',
          alert));
      if (result.length == 2) return result;
    }
  }
  return result;
}

class _RealWarningCard extends StatefulWidget {
  final _LocatedWarning warning;
  const _RealWarningCard({required this.warning});
  @override
  State<_RealWarningCard> createState() => _RealWarningCardState();
}

class _RealWarningCardState extends State<_RealWarningCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final alert = widget.warning.alert;
    final warningName = alert.headline.isNotEmpty
        ? alert.headline
        : alert.eventName.isNotEmpty
            ? alert.eventName
            : '气象预警';
    final detail = alert.description.isNotEmpty
        ? alert.description
        : alert.instruction.isNotEmpty
            ? alert.instruction
            : alert.criteria;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0B429)),
      ),
      padding: const EdgeInsets.all(14),
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
                  '${widget.warning.roleName}${widget.warning.cityName}：$warningName',
                  style: const TextStyle(
                      color: Color(0xFF7A4A00),
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Text(detail,
                        maxLines: _expanded ? null : 4,
                        overflow:
                            _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF6B4F1D),
                            fontSize: 12,
                            height: 1.5)),
                  ),
                  if (detail.length > 70)
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _expanded ? '收起' : '点击展开完整预警',
                          style: const TextStyle(
                              color: Color(0xFF9A6700), fontSize: 11),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====== 固定出行建议 - 对齐 FixedTravelSuggestions ======
class _FixedTravelSuggestions extends StatelessWidget {
  const _FixedTravelSuggestions();
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('出行防灾建议',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _SuggestionCard(
          icon: AppAssets.longTripSuggestionRoute,
          title: '调整路线策略',
          detail: '绕行汕湛高速，可避开暴雨核心区域，增加耗时约15分钟',
        ),
        SizedBox(height: 10),
        _SuggestionCard(
          icon: AppAssets.longTripSuggestionSupply,
          title: '备用应急物资',
          detail: '随车准备雨具、应急手电筒，防滑垫片并检查轮胎气压',
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String detail;
  const _SuggestionCard({
    required this.icon,
    required this.title,
    required this.detail,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(10, 2),
      child: Row(children: [
        Image.asset(icon, width: 36, height: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(detail,
                  style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.5)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ====== 删除确认弹窗 - 对齐 DeleteLongTripConfirmDialog ======
class _DeleteConfirmDialog extends StatelessWidget {
  final VoidCallback onDismiss;
  final VoidCallback onConfirm;
  const _DeleteConfirmDialog({required this.onDismiss, required this.onConfirm});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('确认删除',
                style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('是否确认删除这条长途规划？删除后无法恢复。',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    height: 1.5)),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE2E8F0),
                      foregroundColor: const Color(0xFF334155),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onDismiss,
                    child: const Text('取消'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onConfirm,
                    child: const Text('确认删除'),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ====== 添加地点弹窗 - 对齐 AddRoutePointDialog ======
class _AddRoutePointDialog extends StatefulWidget {
  final LongTripPointRole role;
  final LongTripDraft draft;
  const _AddRoutePointDialog({required this.role, required this.draft});
  @override
  State<_AddRoutePointDialog> createState() => _AddRoutePointDialogState();
}

class _AddRoutePointDialogState extends State<_AddRoutePointDialog> {
  LongTripCitySelection? _city;
  String? _preselectedCityName;
  DateTime? _selectedDate;
  String? _errorMessage;

  LongTripPointRole get _role => widget.role;

  @override
  void initState() {
    super.initState();
    if (_role == LongTripPointRole.start) {
      _preselectedCityName = widget.draft.start?.cityName;
    } else if (_role == LongTripPointRole.end) {
      _preselectedCityName = widget.draft.end?.cityName;
    } else {
      _preselectedCityName = null;
    }
    _selectedDate = _initialDate.clamp(_minimumDate, _maximumDate);
  }

  /// 对齐 Android 的 minimumDate/maximumDate 计算
  DateTime get _today => _dateOnly(DateTime.now());

  DateTime get _finalSelectableDate => _today.add(const Duration(days: 14));

  DateTime? get _startDate => widget.draft.start == null
      ? null
      : _dateOnly(widget.draft.start!.date);

  DateTime? get _endDate => widget.draft.end == null
      ? null
      : _dateOnly(widget.draft.end!.date);

  DateTime? get _latestWaypointDate {
    final dates = widget.draft.waypoints
        .map((point) => _dateOnly(point.date))
        .toList();
    if (dates.isEmpty) return null;
    dates.sort((a, b) => a.compareTo(b));
    return dates.last;
  }

  List<DateTime> get _followingDates => [
        ...widget.draft.waypoints,
        if (widget.draft.end != null) widget.draft.end!,
      ].map((point) => _dateOnly(point.date)).toList();

  DateTime get _minimumDate {
    switch (_role) {
      case LongTripPointRole.start:
        return _today;
      case LongTripPointRole.waypoint:
        final candidates = [_today, if (_startDate != null) _startDate!];
        return candidates.reduce((a, b) => a.isAfter(b) ? a : b);
      case LongTripPointRole.end:
        final candidates = [
          _today,
          if (_startDate != null) _startDate!,
          if (_latestWaypointDate != null) _latestWaypointDate!,
        ];
        return candidates.reduce((a, b) => a.isAfter(b) ? a : b);
    }
  }

  DateTime get _maximumDate {
    switch (_role) {
      case LongTripPointRole.start:
        var limit = _finalSelectableDate;
        if (_followingDates.isNotEmpty) {
          final earliest = _followingDates.reduce(
              (a, b) => a.isBefore(b) ? a : b);
          if (earliest.isBefore(limit)) limit = earliest;
        }
        return _today.isAfter(limit) ? _today : limit;
      case LongTripPointRole.waypoint:
        var limit = _finalSelectableDate;
        if (_endDate != null && _endDate!.isBefore(limit)) limit = _endDate!;
        return limit;
      case LongTripPointRole.end:
        return _finalSelectableDate;
    }
  }

  DateTime get _initialDate {
    if (_role == LongTripPointRole.start) return _startDate ?? _minimumDate;
    if (_role == LongTripPointRole.end) return _endDate ?? _minimumDate;
    return _minimumDate;
  }

  /// 对齐 dateConstraintText
  String get _dateConstraintText {
    switch (_role) {
      case LongTripPointRole.start:
        return '可选择今天起15日内';
      case LongTripPointRole.waypoint:
        if (_startDate != null && _endDate != null) {
          return '不得早于起点，且不得晚于终点 ${_formatRouteDate(_endDate!)}';
        }
        if (_startDate != null) {
          return '不得早于起点 ${_formatRouteDate(_startDate!)}，且须在15日内';
        }
        return '可选择今天起15日内';
      case LongTripPointRole.end:
        if (_startDate != null && _latestWaypointDate != null) {
          return '不得早于最晚途径点 ${_formatRouteDate(_latestWaypointDate!)}，且须在15日内';
        }
        if (_latestWaypointDate != null) {
          return '不得早于最晚途径点 ${_formatRouteDate(_latestWaypointDate!)}';
        }
        if (_startDate != null) {
          return '不得早于起点 ${_formatRouteDate(_startDate!)}，且须在15日内';
        }
        return '可选择今天起15日内';
    }
  }

  String get _displayCityName =>
      _city?.cityName ?? _preselectedCityName ?? '';

  Future<void> _selectCity() async {
    final city = await Navigator.of(context).push<LongTripCitySelection>(
        MaterialPageRoute(builder: (_) => const TripCityPickerPage()));
    if (city != null && mounted) {
      setState(() {
        _city = city;
        _preselectedCityName = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: _minimumDate,
      lastDate: _maximumDate,
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = _dateOnly(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cityBlank = _displayCityName.trim().isEmpty;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 560),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('添加${_role.label}',
                    style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                const Text('地点',
                    style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 7),
                GestureDetector(
                  onTap: _selectCity,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8FC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _errorMessage != null && cityBlank
                              ? const Color(0xFFB91C1C)
                              : const Color(0xFFD5DFEA)),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          _displayCityName.isEmpty
                              ? '请从城市列表选择地点'
                              : _displayCityName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: _displayCityName.isEmpty
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF1E293B),
                              fontSize: 15),
                        ),
                      ),
                      Container(
                        width: 58,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF238BF2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text('选择',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('时间',
                    style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 7),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8FC),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xFFD5DFEA)),
                    ),
                    child: Text(_formatRouteDate(_selectedDate!),
                        style: const TextStyle(
                            color: Color(0xFF1E293B), fontSize: 15)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(_dateConstraintText,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 11)),
                ),
                if (_errorMessage != null && cityBlank)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_errorMessage!,
                        style: const TextStyle(
                            color: Color(0xFFB91C1C), fontSize: 12)),
                  ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消',
                          style: TextStyle(color: Color(0xFF475569))),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF238BF2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      onPressed: () {
                        final cityName = _displayCityName.trim();
                        if (cityName.isEmpty) {
                          setState(() =>
                              _errorMessage = '请先从城市列表选择地点');
                          return;
                        }
                        // 对齐 Android：确认只依赖城市名与日期；未重新选择时
                        // 沿用预填城市名，重新选择时保留完整定位信息。
                        Navigator.pop(
                          context,
                          _city?.toPoint(_selectedDate!) ??
                              LongTripPoint.fromCity(
                                  cityName: cityName, date: _selectedDate!),
                        );
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 对齐 formatRouteDate："yyyy.M.d"
String _formatRouteDate(DateTime date) => '${date.year}.${date.month}.${date.day}';

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

extension _DateClamp on DateTime {
  DateTime clamp(DateTime minimum, DateTime maximum) {
    if (isBefore(minimum)) return minimum;
    if (isAfter(maximum)) return maximum;
    return this;
  }
}
