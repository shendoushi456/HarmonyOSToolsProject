// QxAir 空气质量页 - 对齐 Android QxAirFragment/QxAirScreen/QxAirComponents
// 迁移自 toolbox_c toolsbox_moduel weather/air（Jetpack Compose UI）
// AQI 六边形徽章卡 + 生活指数网格 + 生活小窍门卡
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../home/pages/home_shell_page.dart';
import '../models/qx_air_ui_state.dart';
import '../viewmodels/qx_air_view_model.dart';

/// 对齐 Android QxMainFontScale：全页字号整体缩放 0.82（sp 缩放，dp 不变）
const double _kQxMainFontScale = 0.82;

/// Compose verticalGradient endY=780px（xxhdpi 3x）≈ 260 逻辑像素处渐变结束
const double _kGradientEnd = 260.0;

class QxAirPage extends ConsumerStatefulWidget {
  const QxAirPage({super.key});

  @override
  ConsumerState<QxAirPage> createState() => _QxAirPageState();
}

class _QxAirPageState extends ConsumerState<QxAirPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 对齐 Android Fragment.onResume：回到前台时刷新
    if (state == AppLifecycleState.resumed) {
      ref.read(qxAirViewModelProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qxAirViewModelProvider);

    // 对齐 Android onHiddenChanged(false)：Tab 切回本页时刷新（空气质量 Tab 当前为 index 2）
    ref.listen<int>(homeTabIndexProvider, (previous, next) {
      const airTabIndex = 2;
      if (previous != airTabIndex && next == airTabIndex) {
        ref.read(qxAirViewModelProvider.notifier).refresh();
      }
    });

    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
          textScaler: const TextScaler.linear(_kQxMainFontScale)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final whiteStop =
                (_kGradientEnd / constraints.maxHeight).clamp(0.0, 1.0);
            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: const [
                          Color(0xFF74C8FA),
                          Color(0xFFEFF8FF),
                          Colors.white,
                        ],
                        stops: [0.0, whiteStop, 1.0],
                      ),
                    ),
                  ),
                ),
                // 对齐 Android qx_air_17：alpha 0.2 + ContentScale.Crop
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      AppAssets.qxAirBackground,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SafeArea(
                  top: true,
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 96),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AirHeader(
                            onSettingsClick: () =>
                                context.push(RoutePaths.setting),
                          ),
                          const SizedBox(height: 26),
                          _AqiOverviewCard(state: state),
                          const SizedBox(height: 28),
                          _LifeIndexSection(state: state),
                          const SizedBox(height: 28),
                          _LifeTipCard(state: state),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 顶部标题栏（对齐 Android AirHeader：居中标题 + 右侧设置图标）
class _AirHeader extends StatelessWidget {
  final VoidCallback onSettingsClick;

  const _AirHeader({required this.onSettingsClick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 38),
      child: SizedBox(
        height: 46,
        child: Stack(
          children: [
            const Center(
              child: Text(
                '空气质量',
                style: TextStyle(
                  color: Color(0xFF202124),
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSettingsClick,
                child: Image.asset(
                  AppAssets.qxAirSettings,
                  width: 26,
                  height: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// AQI 总览卡（对齐 Android AqiOverviewCard：六边形徽章 + 污染物列表）
class _AqiOverviewCard extends StatelessWidget {
  final QxAirUiState state;

  const _AqiOverviewCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 14, right: 10, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 对齐 Android badgeSize = maxWidth * 0.43 coerceIn(126, 148)
          final badgeSize =
              (constraints.maxWidth * 0.43).clamp(126.0, 148.0);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: badgeSize,
                child: Column(
                  children: [
                    const SizedBox(height: 31),
                    _HexAqiBadge(aqi: state.aqi, badgeSize: badgeSize),
                    SizedBox(
                      height: 27,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '实时更新  ',
                            style: TextStyle(
                              color: Color(0xFF33363B),
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            state.category,
                            style: const TextStyle(
                              color: Color(0xFF33363B),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < state.pollutants.length; i++)
                      Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 4),
                        child: _PollutantRow(item: state.pollutants[i]),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 六边形 AQI 徽章（对齐 Android HexAqiBadge：底图 + 居中数字）
class _HexAqiBadge extends StatelessWidget {
  final int aqi;
  final double badgeSize;

  const _HexAqiBadge({required this.aqi, required this.badgeSize});

  @override
  Widget build(BuildContext context) {
    final aqiText = aqi.toString();
    final aqiFontSize = aqiText.length >= 3 ? 34.0 : 44.0;
    return SizedBox(
      width: badgeSize,
      height: badgeSize,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.qxAirBadge, fit: BoxFit.fill),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: badgeSize * (52 / 178),
              right: badgeSize * (53 / 178),
            ),
            child: Center(
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  aqiText,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: aqiFontSize,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 污染物行（对齐 Android PollutantRow）
class _PollutantRow extends StatelessWidget {
  final QxPollutantUi item;

  const _PollutantRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 27,
      child: Row(
        children: [
          Image.asset(item.iconPath, width: 22, height: 22),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                color: Color(0xFF4B4F55),
                fontSize: 15,
                height: 18 / 15,
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 34,
            child: Text(
              item.value,
              style: const TextStyle(
                color: Color(0xFF5DBBFF),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 生活指数区（对齐 Android LifeIndexSection：3 列网格 2 行）
class _LifeIndexSection extends StatelessWidget {
  final QxAirUiState state;

  const _LifeIndexSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final rows = _chunked(state.lifeIndexes, 3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '生活指数',
          style: TextStyle(
            color: Color(0xFF202124),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        for (var r = 0; r < rows.length; r++)
          Padding(
            padding: EdgeInsets.only(bottom: r == rows.length - 1 ? 0 : 14),
            child: Row(
              children: [
                for (final item in rows[r])
                  Expanded(child: _LifeIndexCard(item: item)),
                // 对齐 Android repeat(3 - row.size) { Spacer(weight(1f)) }
                for (var i = 0; i < 3 - rows[r].length; i++)
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  List<List<T>> _chunked<T>(List<T> list, int size) {
    final rows = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      rows.add(list.sublist(
          i, i + size > list.length ? list.length : i + size));
    }
    return rows;
  }
}

/// 生活指数卡（对齐 Android LifeIndexCard：图标 + 数值居中）
class _LifeIndexCard extends StatelessWidget {
  final QxLifeIndexUi item;

  const _LifeIndexCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 42,
              width: double.infinity,
              child: Center(
                child: Image.asset(item.iconPath, width: 42, height: 42),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.value,
              maxLines: 2,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2E3136),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 23 / 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 生活小窍门卡（对齐 Android LifeTipCard：背景图 + 插图 + 文案 + 前景覆盖）
class _LifeTipCard extends StatelessWidget {
  final QxAirUiState state;

  const _LifeTipCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1029 / 534,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.qxAirTipBackground, fit: BoxFit.fill),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 26, top: 38, bottom: 28),
              child: Row(
                children: [
                  Image.asset(
                    AppAssets.qxAirTipIllustration,
                    width: 92,
                    height: 92,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.tipTitle.isEmpty ? '生活小窍门' : state.tipTitle,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            color: Color(0xFF30343A),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.tipBody,
                          maxLines: 4,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            color: Color(0xFF3D4148),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 19 / 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 对齐 Android qx_air_19 前景覆盖层
          Positioned.fill(
            child:
                Image.asset(AppAssets.qxAirTipOverlay, fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }
}
