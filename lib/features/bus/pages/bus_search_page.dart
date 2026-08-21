// 搜索选址页 - 对齐 Android bus/BusSearchActivity.kt
// 含搜索框、输入联想、POI 结果列表、搜索历史
//
// 鸿蒙端差异：
// - Android ComponentActivity + Compose → Flutter ConsumerStatefulWidget + Riverpod
// - Android ImmersionBar → Flutter SafeArea
// - Android setResult(RESULT_OK, intent) 回传 → Flutter GoRouter.of(context).pop(Map)
// - Android Intent.getStringExtra/getBooleanExtra → Flutter extra as Map<String, dynamic>
// - Android R.mipmap.ic_bus_search_empty → Flutter AppAssets.icBusSearchEmpty
// - Android R.mipmap.ic_bus_stop_go → Flutter AppAssets.icBusStopGo
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../router/route_names.dart';
import '../utils/bus_theme_colors.dart';
import '../viewmodels/bus_search_view_model.dart';

/// 搜索选址页 - 对齐 Android BusSearchActivity
class BusSearchPage extends ConsumerStatefulWidget {
  const BusSearchPage({super.key, this.extra});

  /// 路由参数（对齐 Android Intent extra）
  /// 接收: is_from_location(bool?)、current_city(String)
  final Map<String, dynamic>? extra;

  @override
  ConsumerState<BusSearchPage> createState() => _BusSearchPageState();
}

class _BusSearchPageState extends ConsumerState<BusSearchPage> {
  /// 对齐 Android: isFromLocation = intent.getBooleanExtra("is_from_location", false)
  late final bool _isFromLocation;

  /// 对齐 Android: isForResult = intent.hasExtra("is_from_location")
  late final bool _isForResult;

  /// 对齐 Android: val currentCity = intent.getStringExtra("current_city") ?: "北京"
  late final String _currentCity;

  @override
  void initState() {
    super.initState();
    final extra = widget.extra ?? const {};
    _isFromLocation = extra['is_from_location'] as bool? ?? false;
    _isForResult = extra['is_from_location'] != null;
    _currentCity = extra['current_city'] as String? ?? '北京';

    // 对齐 Android init: viewModel.setCurrentCity(currentCity)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(busSearchViewModelProvider.notifier)
          .setCurrentCity(_currentCity);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: val uiState = viewModel.uiState
    final uiState = ref.watch(busSearchViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _TopAppBar(
              title: _isForResult
                  // 对齐 Android: if (isFromLocation) "选择出发地" else "选择目的地"
                  ? (_isFromLocation ? '选择出发地' : '选择目的地')
                  : '搜索',
              onBack: () => GoRouter.of(context).pop(),
            ),
            // 搜索输入框区域 - 对齐 Android SearchPageContent 中的 Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: _SearchInputBar(uiState: uiState, ref: ref),
            ),
            // 内容区域 - 对齐 Android when 块
            Expanded(
              child: _buildContent(uiState),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建内容区域 - 对齐 Android SearchPageContent 中的 when 块
  Widget _buildContent(BusSearchUiState uiState) {
    // 对齐 Android: when { isLoading -> LoadingContent(); showSuggestions -> InputSuggestionsContent; poiResults.isNotEmpty() -> PoiResultsContent; searchHistory.isNotEmpty() && searchText.isEmpty() -> SearchHistoryContent; else -> EmptyStateContent }
    if (uiState.isLoading) {
      return const _LoadingContent();
    }
    if (uiState.isLoadingSuggestions) {
      return const _SuggestionLoadingContent();
    }
    if (uiState.showSuggestions && uiState.inputSuggestions.isNotEmpty) {
      return _InputSuggestionsContent(
        suggestions: uiState.inputSuggestions,
        isLoading: uiState.isLoadingSuggestions,
        isForResult: _isForResult,
        isFromLocation: _isFromLocation,
        onSuggestionTapped: _onSuggestionTapped,
      );
    }
    if (uiState.poiResults.isNotEmpty) {
      return _PoiResultsContent(
        poiResults: uiState.poiResults,
        isForResult: _isForResult,
        isFromLocation: _isFromLocation,
        onPoiTapped: _onPoiTapped,
      );
    }
    if (uiState.searchHistory.isNotEmpty && uiState.searchText.isEmpty) {
      return _SearchHistoryContent(
        searchHistory: uiState.searchHistory,
        onHistoryTapped: (keyword) {
          // 对齐 Android: viewModel.updateSearchText(it); viewModel.searchPoi(it)
          ref
              .read(busSearchViewModelProvider.notifier)
              .updateSearchText(keyword);
          ref.read(busSearchViewModelProvider.notifier).searchPoi(keyword);
        },
        onClear: () {
          ref.read(busSearchViewModelProvider.notifier).clearSearchHistory();
        },
      );
    }
    if (uiState.errorMessage != null && uiState.searchText.isNotEmpty) {
      return _SearchErrorContent(message: uiState.errorMessage!);
    }
    return const _EmptyStateContent();
  }

  /// 点击 POI 项 - 对齐 Android PoiResultItem.clickable
  Future<void> _onPoiTapped(BMFPoiInfo poi) async {
    final poiLocation = poi.pt;
    final latitude = poiLocation?.latitude ?? 0.0;
    final longitude = poiLocation?.longitude ?? 0.0;

    if (_isForResult) {
      // 对齐 Android: 选址模式 - setResult(RESULT_OK, intent) + finish()
      // 鸿蒙端: pop(Map) 回传结果
      GoRouter.of(context).pop({
        'location_name': poi.name ?? '',
        'latitude': latitude,
        'longitude': longitude,
        'is_from_location': _isFromLocation,
      });
    } else {
      // 对齐 Android: 正常搜索模式 - 跳转 BusLocationDetailActivity
      // 鸿蒙端: 直接用 Map 传参（Page 接收后构造 BaiduSearchResult）
      await GoRouter.of(context).push(
        RoutePaths.busLocationDetail,
        extra: {
          'id': poi.uid ?? '',
          'name': poi.name ?? '',
          'description': poi.address ?? '',
          'address': poi.city ?? '',
          'latitude': latitude,
          'longitude': longitude,
        },
      );
    }
  }

  /// 点击联想建议 - 对齐 Android SuggestionItem.onItemClicked
  Future<void> _onSuggestionTapped(BMFSuggestionInfo tip) async {
    final tipLocation = tip.location;
    final latitude = tipLocation?.latitude ?? 0.0;
    final longitude = tipLocation?.longitude ?? 0.0;

    if (_isForResult) {
      // 对齐 Android: 选址模式 - setResult + finish
      // 鸿蒙端: pop(Map) 回传结果
      GoRouter.of(context).pop({
        'location_name': tip.key ?? '',
        'latitude': latitude,
        'longitude': longitude,
        'is_from_location': _isFromLocation,
      });
    } else {
      // 对齐 Android: 正常搜索模式 - viewModel.selectSuggestion(selectedTip)
      await ref.read(busSearchViewModelProvider.notifier).selectSuggestion(tip);
    }
  }
}

/// 顶部应用栏 - 对齐 Android BusSearchActivity.TopAppBar
class _TopAppBar extends StatelessWidget {
  const _TopAppBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      color: BusThemeColors.primaryColor,
      child: Stack(
        children: [
          // 返回按钮 - 对齐 Android Box(padding=start 18dp, align=CenterStart)
          Positioned(
            left: 18,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 18),
                color: BusThemeColors.onPrimaryColor,
                padding: const EdgeInsets.all(12),
                onPressed: onBack,
              ),
            ),
          ),
          // 标题 - 对齐 Android Text(fontSize=22sp, fontWeight=SemiBold)
          Center(
            child: Text(
              title,
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

/// 搜索输入框 - 对齐 Android SearchInputBar
// 修复：改为 StatefulWidget，保持 TextEditingController 稳定，避免每次 build 创建新控制器导致焦点丢失
class _SearchInputBar extends StatefulWidget {
  const _SearchInputBar({required this.uiState, required this.ref});

  final BusSearchUiState uiState;
  final WidgetRef ref;

  @override
  State<_SearchInputBar> createState() => _SearchInputBarState();
}

class _SearchInputBarState extends State<_SearchInputBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isUserTyping = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.uiState.searchText);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _SearchInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 同步外部 searchText 变化（仅当用户不在输入中且值不同时）
    // 避免光标跳动和输入丢失
    if (!_isUserTyping && widget.uiState.searchText != _controller.text) {
      _controller.text = widget.uiState.searchText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 搜索图标 - 对齐 Android Icon(Icons.Default.Search, tint=0xFF858585, size=20dp)
          const Icon(Icons.search, color: Color(0xFF858585), size: 20),
          const SizedBox(width: 10),
          // 输入框 - 对齐 Android BasicTextField
          Expanded(
            child: SizedBox(
              height: 17,
              child: Stack(
                children: [
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: (value) {
                      _isUserTyping = true;
                      widget.ref
                          .read(busSearchViewModelProvider.notifier)
                          .updateSearchText(value);
                    },
                    onEditingComplete: () {
                      _isUserTyping = false;
                    },
                    onTapOutside: (_) {
                      _isUserTyping = false;
                      _focusNode.unfocus();
                    },
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF151515),
                      height: 17 / 12,
                    ),
                    cursorColor: BusThemeColors.primaryColor,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                  // 占位符 - 对齐 Android: if (searchText.isEmpty()) Text("搜索线路、站点、目的地")
                  if (widget.uiState.searchText.isEmpty)
                    const Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Text(
                          '搜索线路、站点、目的地',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF979797),
                            height: 17 / 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 搜索按钮 - 对齐 Android Box(background=PRIMARY_COLOR, clickable=searchPoi)
          GestureDetector(
            onTap: () {
              _isUserTyping = false;
              _focusNode.unfocus();
              // 修复：用控制器当前值，确保搜索的是用户实际输入的内容
              widget.ref
                  .read(busSearchViewModelProvider.notifier)
                  .searchPoi(_controller.text);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              decoration: BoxDecoration(
                color: BusThemeColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '搜索',
                  style: TextStyle(
                    fontSize: 14,
                    color: BusThemeColors.onPrimaryColor,
                    fontWeight: FontWeight.w500,
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

/// 空状态 - 对齐 Android EmptyStateContent
class _EmptyStateContent extends StatelessWidget {
  const _EmptyStateContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        // 对齐 Android: offset(y=(-40).dp)
        offset: const Offset(0, -40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 对齐 Android AsyncImage(R.mipmap.ic_bus_search_empty, size=207x153dp)
            Image.asset(
              AppAssets.icBusSearchEmpty,
              width: 207,
              height: 153,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            // 对齐 Android Text("无搜索历史", fontSize=16sp, color=0xFF454545)
            const Text(
              '无搜索历史',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF454545),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 加载中内容 - 对齐 Android LoadingContent
class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF57CC89)),
    );
  }
}

/// 输入联想请求中的反馈，避免请求尚未返回时页面看起来没有任何反应。
class _SuggestionLoadingContent extends StatelessWidget {
  const _SuggestionLoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Color(0xFF57CC89),
              strokeWidth: 2,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '搜索中...',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}

/// 搜索服务明确返回失败时展示原因，便于区分无结果与配置或网络问题。
class _SearchErrorContent extends StatelessWidget {
  const _SearchErrorContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
      ),
    );
  }
}

/// POI 结果列表 - 对齐 Android PoiResultsContent
class _PoiResultsContent extends StatelessWidget {
  const _PoiResultsContent({
    required this.poiResults,
    required this.isForResult,
    required this.isFromLocation,
    required this.onPoiTapped,
  });

  final List<BMFPoiInfo> poiResults;
  final bool isForResult;
  final bool isFromLocation;
  final Future<void> Function(BMFPoiInfo) onPoiTapped;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: poiResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final poi = poiResults[index];
        return _PoiResultItem(
          poi: poi,
          isForResult: isForResult,
          onTapped: () => onPoiTapped(poi),
          onGoToTapped: () async {
            // 对齐 Android: BusRouteActivity.start(destinationLatitude=..., destinationName=poi.name, useMyLocation=true)
            final poiLocation = poi.pt;
            await GoRouter.of(context).push(
              RoutePaths.busRoute,
              extra: {
                'destination_latitude': poiLocation?.latitude ?? 0.0,
                'destination_longitude': poiLocation?.longitude ?? 0.0,
                'destination_name': poi.name ?? '',
                'use_my_location': true,
              },
            );
          },
        );
      },
    );
  }
}

/// POI 结果项 - 对齐 Android PoiResultItem
class _PoiResultItem extends StatelessWidget {
  const _PoiResultItem({
    required this.poi,
    required this.isForResult,
    required this.onTapped,
    required this.onGoToTapped,
  });

  final BMFPoiInfo poi;
  final bool isForResult;
  final VoidCallback onTapped;
  final VoidCallback onGoToTapped;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.zero,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTapped,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 位置图标 - 对齐 Android Icon(Icons.Default.LocationOn, tint=0xFF57CC89, size=24dp)
              const Icon(Icons.location_on, color: Color(0xFF57CC89), size: 24),
              const SizedBox(width: 12),
              // 名称+地址 - 对齐 Android Column(weight=1f)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 对齐 Android Text(poi.name, fontSize=16sp, fontWeight=Medium, maxLines=1)
                    Text(
                      poi.name ?? '未知地点',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF151515),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 对齐 Android Text(poi.address, fontSize=14sp, color=0xFF666666, maxLines=2)
                    Text(
                      poi.address ?? '无详细地址',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // "到这去"按钮 - 对齐 Android: if (!isForResult) Column(clickable -> BusRouteActivity.start)
              if (!isForResult)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onGoToTapped,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 对齐 Android Image(R.mipmap.ic_bus_stop_go, size=18dp)
                        Image.asset(
                          AppAssets.icBusStopGo,
                          width: 18,
                          height: 18,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 2),
                        // 对齐 Android Text("到这去", fontSize=14sp, color=0xFF666666)
                        const Text(
                          '到这去',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 输入联想内容 - 对齐 Android InputSuggestionsContent
class _InputSuggestionsContent extends StatelessWidget {
  const _InputSuggestionsContent({
    required this.suggestions,
    required this.isLoading,
    required this.isForResult,
    required this.isFromLocation,
    required this.onSuggestionTapped,
  });

  final List<BMFSuggestionInfo> suggestions;
  final bool isLoading;
  final bool isForResult;
  final bool isFromLocation;
  final Future<void> Function(BMFSuggestionInfo) onSuggestionTapped;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 对齐 Android: if (isLoading) Row { CircularProgressIndicator + Text("搜索中...") }
          if (isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Color(0xFF57CC89),
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '搜索中...',
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final tip = suggestions[index];
                return _SuggestionItem(
                  tip: tip,
                  onTapped: () => onSuggestionTapped(tip),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 联想建议项 - 对齐 Android SuggestionItem
class _SuggestionItem extends StatelessWidget {
  const _SuggestionItem({required this.tip, required this.onTapped});

  final BMFSuggestionInfo tip;
  final VoidCallback onTapped;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapped,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 位置图标 - 对齐 Android Icon(Icons.Default.LocationOn, tint=0xFF57CC89, size=20dp)
            const Icon(Icons.location_on, color: Color(0xFF57CC89), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 对齐 Android Text(tip.key, fontSize=14sp, color=0xFF333333, fontWeight=Medium)
                  Text(
                    tip.key ?? '未知地点',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // 对齐 Android: if (!district.isNullOrEmpty() && district != key)
                  if (tip.district != null &&
                      tip.district!.isNotEmpty &&
                      tip.district != tip.key) ...[
                    const SizedBox(height: 2),
                    Text(
                      tip.district ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 搜索历史内容 - 对齐 Android SearchHistoryContent
class _SearchHistoryContent extends StatelessWidget {
  const _SearchHistoryContent({
    required this.searchHistory,
    required this.onHistoryTapped,
    required this.onClear,
  });

  final List<String> searchHistory;
  final void Function(String) onHistoryTapped;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 标题 + 清除按钮 - 对齐 Android Row(SpaceBetween)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 对齐 Android Text("搜索历史", fontSize=16sp, fontWeight=Medium)
                const Text(
                  '搜索历史',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF151515),
                  ),
                ),
                // 对齐 Android Text("清除", color=0xFF57CC89, clickable)
                GestureDetector(
                  onTap: onClear,
                  child: const Text(
                    '清除',
                    style: TextStyle(fontSize: 14, color: Color(0xFF57CC89)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: searchHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final keyword = searchHistory[index];
                return _SearchHistoryItem(
                  keyword: keyword,
                  onTapped: () => onHistoryTapped(keyword),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 搜索历史项 - 对齐 Android SearchHistoryItem
class _SearchHistoryItem extends StatelessWidget {
  const _SearchHistoryItem({required this.keyword, required this.onTapped});

  final String keyword;
  final VoidCallback onTapped;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapped,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // 对齐 Android Icon(Icons.Default.DateRange, tint=0xFF999999, size=20dp)
            const Icon(Icons.calendar_month,
                color: Color(0xFF999999), size: 20),
            const SizedBox(width: 12),
            // 对齐 Android Text(keyword, fontSize=14sp, color=0xFF333333)
            Text(
              keyword,
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
          ],
        ),
      ),
    );
  }
}
