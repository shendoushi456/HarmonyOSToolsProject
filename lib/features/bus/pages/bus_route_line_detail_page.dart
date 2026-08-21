// 公交换乘详情页 - 对齐 Android bus/BusRouteLineDetailActivity.kt
// 从 RouteDataManager 获取路线数据，调用 viewModel.setBusRouteData 后展示换乘步骤
//
// 鸿蒙端差异：
// - Android ComponentActivity + Compose → Flutter ConsumerWidget + Riverpod
// - Android Intent + temporaryTransitRouteLines 静态变量传递 → Flutter RouteDataManager 单例
// - Android ImmersionBar → Flutter SafeArea
// - Android finish() → Flutter GoRouter.of(context).pop()
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/bus_transfer_data.dart';
import '../utils/bus_theme_colors.dart';
import '../utils/route_data_manager.dart';
import '../viewmodels/bus_route_line_detail_view_model.dart';

/// 公交换乘详情页 - 对齐 Android BusRouteLineDetailActivity
class BusRouteLineDetailPage extends ConsumerStatefulWidget {
  const BusRouteLineDetailPage({super.key, this.extra});

  /// 路由参数（对齐 Android Intent extra）
  /// 鸿蒙端差异：Android 用 Intent + 静态变量 temporaryTransitRouteLines 传递 TransitRouteLine
  /// 鸿蒙端: 直接从 RouteDataManager 单例取，extra 仅占位以对齐其他页面签名
  final Map<String, dynamic>? extra;

  @override
  ConsumerState<BusRouteLineDetailPage> createState() =>
      _BusRouteLineDetailPageState();
}

class _BusRouteLineDetailPageState
    extends ConsumerState<BusRouteLineDetailPage> {
  @override
  void initState() {
    super.initState();
    // 对齐 Android onCreate: 从 RouteDataManager 取路线数据 + 调用 setBusRouteData
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRouteData();
    });
  }

  /// 初始化路线数据 - 对齐 Android onCreate 中的数据初始化
  Future<void> _initRouteData() async {
    // 对齐 Android: transitRouteLines = temporaryTransitRouteLines ?: emptyList()
    // 对齐 Android: transitRouteResult = intent.getParcelableExtra("transitRouteResult")
    final transitRouteLines =
        RouteDataManager.instance.getTransitRouteLines() ?? const [];
    final transitRouteResult = RouteDataManager.instance.getTransitRouteResult();

    // 对齐 Android: viewModel.setBusRouteData(transitRouteLines, transitRouteResult)
    await ref
        .read(busRouteLineDetailViewModelProvider.notifier)
        .setBusRouteData(transitRouteLines, transitRouteResult: transitRouteResult);
  }

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: val uiState by viewModel.uiState.collectAsState()
    final uiState = ref.watch(busRouteLineDetailViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _TopAppBar(onBack: () => GoRouter.of(context).pop()),
            Expanded(
              child: _buildBody(uiState),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建 body 内容 - 对齐 Android BusRouteLineDetailScreenContent 中的 when 块
  Widget _buildBody(BusTransferUiState uiState) {
    // 对齐 Android: when { isLoading -> LoadingContent(); error != null -> ErrorContent; transferRoute != null -> ... }
    if (uiState.isLoading) {
      return const _LoadingContent();
    }
    if (uiState.error != null) {
      return _ErrorContent(
        error: uiState.error!,
        onRetry: () {
          ref.read(busRouteLineDetailViewModelProvider.notifier).replanRoute();
        },
      );
    }
    final route = uiState.transferRoute;
    if (route != null) {
      return _BusRouteLineDetailContent(route: route);
    }
    return const _EmptyContent();
  }
}

/// 顶部应用栏 - 对齐 Android BusRouteLineDetailActivity.TopAppBar
class _TopAppBar extends StatelessWidget {
  const _TopAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      color: BusThemeColors.primaryColor,
      child: Stack(
        children: [
          // 返回按钮 - 对齐 Android Box(padding=start 15dp, align=CenterStart, clickable)
          Positioned(
            left: 15,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                color: BusThemeColors.onPrimaryColor,
                padding: const EdgeInsets.all(10),
                onPressed: onBack,
              ),
            ),
          ),
          // 标题 - 对齐 Android Text("公交线路详情", align=Center)
          Center(
            child: Text(
              '公交线路详情',
              style: TextStyle(
                color: BusThemeColors.onPrimaryColor,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 公交换乘详情内容 - 对齐 Android BusRouteLineDetailContent
class _BusRouteLineDetailContent extends StatelessWidget {
  const _BusRouteLineDetailContent({required this.route});

  final BusTransferRoute route;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 路线总览信息 - 对齐 Android RouteOverviewCard
          _RouteOverviewCard(route: route),
          const SizedBox(height: 20),
          // 起点区域 - 对齐 Android StartPointSection
          _PointSection(label: '起', pointName: route.startPoint, isStart: true),
          const SizedBox(height: 10),
          // 换乘路线卡片 - 对齐 Android TransferRouteCard
          _TransferRouteCard(transferSteps: route.transferSteps),
          const SizedBox(height: 10),
          // 终点区域 - 对齐 Android EndPointSection
          _PointSection(label: '终', pointName: route.endPoint, isStart: false),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

/// 路线总览卡片 - 对齐 Android RouteOverviewCard
class _RouteOverviewCard extends StatelessWidget {
  const _RouteOverviewCard({required this.route});

  final BusTransferRoute route;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 对齐 Android Text("总时长: ${transferRoute.totalDuration}")
              Text(
                '总时长: ${route.totalDuration}',
                style: TextStyle(
                  fontSize: 14,
                  color: BusThemeColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // 对齐 Android Text("总距离: ${transferRoute.totalDistance}")
              Text(
                '总距离: ${route.totalDistance}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
              ),
            ],
          ),
          // 对齐 Android: if (transferRoute.taxiCost.isNotEmpty())
          if (route.taxiCost.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              route.taxiCost,
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ],
      ),
    );
  }
}

/// 起终点区域 - 对齐 Android StartPointSection / EndPointSection
class _PointSection extends StatelessWidget {
  const _PointSection({
    required this.label,
    required this.pointName,
    required this.isStart,
  });

  /// "起" / "终"
  final String label;

  /// 起终点名称
  final String pointName;

  /// true=起点（绿色），false=终点（红色）
  final bool isStart;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: 起点 BusThemeColors.PRIMARY_COLOR, 终点 Color(0xFFFF0707)
    final color = isStart ? BusThemeColors.primaryColor : const Color(0xFFFF0707);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 起终点标志圆形 - 对齐 Android Box(size=24dp, background=color, CircleShape)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: BusThemeColors.onPrimaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 起终点名称 - 对齐 Android Text(fontSize=18sp, color=0xFF111111)
          Expanded(
            child: Text(
              pointName,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF111111),
                height: 25 / 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 换乘路线卡片 - 对齐 Android TransferRouteCard
class _TransferRouteCard extends StatelessWidget {
  const _TransferRouteCard({required this.transferSteps});

  final List<TransferStep> transferSteps;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // 对齐 Android: padding(start=52dp, end=20dp)
      margin: const EdgeInsets.only(left: 52, right: 20),
      padding: const EdgeInsets.only(left: 16, right: 6, top: 14, bottom: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final step in transferSteps) ...[
            _TransferStepItem(step: step),
            if (step != transferSteps.last) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

/// 换乘步骤项 - 对齐 Android TransferStepItem
class _TransferStepItem extends StatefulWidget {
  const _TransferStepItem({required this.step});

  final TransferStep step;

  @override
  State<_TransferStepItem> createState() => _TransferStepItemState();
}

class _TransferStepItemState extends State<_TransferStepItem> {
  // 对齐 Android: var isExpanded by remember { mutableStateOf(false) }
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.step;

    // 对齐 Android: 根据类型添加前缀符号
    // WALK/BUS/SUBWAY/TAXI -> "- ${step.description}"，其他 -> step.description
    final prefixedDescription = (step.type == TransferType.walk ||
            step.type == TransferType.bus ||
            step.type == TransferType.subway ||
            step.type == TransferType.taxi)
        ? '- ${step.description}'
        : step.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          // 对齐 Android: clickable(enabled = step.expandable)
          onTap: step.expandable
              ? () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                }
              : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 描述文本 - 对齐 Android Text(weight=1f, fontSize=12sp)
              Expanded(
                child: Text(
                  prefixedDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF111111),
                    height: 17 / 12,
                  ),
                ),
              ),
              // 站数 - 对齐 Android: if (step.stations.isNotEmpty())
              if (step.stations.isNotEmpty)
                Text(
                  step.stations,
                  style: TextStyle(
                    fontSize: 12,
                    color: BusThemeColors.primaryColor,
                    height: 17 / 12,
                  ),
                ),
            ],
          ),
        ),
        // 对齐 Android: 展开的站点列表
        if (_isExpanded && step.stationsList.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final stationName in step.stationsList) ...[
                  Text(
                    '• $stationName',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// 加载中内容 - 对齐 Android LoadingContent
class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: BusThemeColors.primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          // 对齐 Android Text("正在规划路线...")
          const Text(
            '正在规划路线...',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}

/// 错误内容 - 对齐 Android ErrorContent
class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 对齐 Android Text("路线规划失败")
            const Text(
              '路线规划失败',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            // 对齐 Android Text(error, textAlign=Center)
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 20),
            // 对齐 Android Button(onClick=onRetry)
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: BusThemeColors.primaryColor,
                foregroundColor: BusThemeColors.onPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text(
                '重试',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 空内容 - 对齐 Android EmptyContent
class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '暂无换乘路线',
        style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
      ),
    );
  }
}
