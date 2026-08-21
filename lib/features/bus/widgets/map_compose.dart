// 百度地图 Compose 组件 - 对齐 Android bus/MapCompose.kt
// 迁移说明：
// - AndroidView + com.baidu.mapapi.map.MapView → BMFMapWidget（鸿蒙 Flutter SDK）
// - BaiduMap.addOverlay(MarkerOptions) → BMFMapController.addMarker(BMFMarker)
// - MapStatusUpdateFactory.newLatLngZoom → BMFMapController.setNewLatLngZoom
// - map.animateMapStatus(MapStatusUpdateFactory.zoomTo(z)) → setZoomTo(z)
// - map.clear() → cleanAllMarkers()
// - BitmapDescriptorFactory.fromBitmap() → 通过 MaterialIcons 字体绘制为 PNG 字节数据传给 BMFMarker.iconData
// - 用户拖拽检测：setMapRegionDidChangeWithReasonCallback 中判断 reason == Gesture
// - 生命周期：BMFMapWidget 内部已处理，不需要手动 onResume/onPause/onDestroy
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';

import '../utils/baidu_sdk_initializer.dart';

/// 地图搜索结果 - 对齐 Android bus/viewmodel/BusMapSearchViewModel.kt 中的 SearchResult
/// 简化版数据类，用于在地图上展示搜索结果标记
class MapSearchResult {
  const MapSearchResult({
    required this.id,
    required this.name,
    required this.latLng,
    this.address = '',
    this.description = '',
    this.distance = '',
    this.iconUrl = '',
  });

  /// 唯一标识
  final String id;

  /// 名称（显示在 Marker 标题）
  final String name;

  /// 经纬度坐标
  final BMFCoordinate latLng;

  /// 地址
  final String address;

  /// 描述
  final String description;

  /// 距离文本
  final String distance;

  /// 图标 URL（保留字段，鸿蒙端暂未使用）
  final String iconUrl;
}

/// 百度地图 Compose 组件 - 对齐 Android MapCompose
///
/// 功能说明：
/// - 自动处理 SDK 初始化（BaiduSdkInitializer.ensureInitialized）
/// - 只有在首次进入和用户点击定位按钮后才会自动移动镜头
/// - 用户拖拽地图后，将停止所有自动镜头移动，直到 resetUserDrag 被设置为 true
class MapCompose extends StatefulWidget {
  const MapCompose({
    super.key,
    this.currentLocation,
    this.searchResults = const [],
    this.onMapReady,
    this.onLocationButtonClick,
    this.resetUserDrag = false,
    this.resetLocation = false,
    this.isSearchTargetLocation = false,
  });

  /// 当前位置（蓝色 Marker）
  final BMFCoordinate? currentLocation;

  /// 搜索结果列表（红色 Marker）
  final List<MapSearchResult> searchResults;

  /// 地图就绪回调 - 对齐 Android onMapReady(BaiduMap)
  /// 鸿蒙端 controller 与 Android BaiduMap 角色对应
  final void Function(BMFMapController)? onMapReady;

  /// 定位按钮点击回调 - 对齐 Android onLocationButtonClick
  final VoidCallback? onLocationButtonClick;

  /// 重置用户拖拽状态 - 对齐 Android resetUserDrag
  /// 设置为 true 时清除拖拽标记，恢复自动移动镜头
  final bool resetUserDrag;

  /// 重置位置 - 对齐 Android resetLocation
  final bool resetLocation;

  /// 是否将镜头移动到首个搜索结果 - 对齐 Android isSearchTargetLocation
  final bool isSearchTargetLocation;

  @override
  State<MapCompose> createState() => _MapComposeState();
}

class _MapComposeState extends State<MapCompose> {
  /// 地图控制器 - 对齐 Android BaiduMap
  BMFMapController? _mapController;

  /// 是否已手动拖拽地图 - 对齐 Android hasUserDraggedState
  bool _hasUserDragged = false;

  /// 上一次的位置，用于检测变化 - 对齐 Android lastCurrentLocation
  BMFCoordinate? _lastCurrentLocation;

  /// 上一次的搜索结果，用于检测变化 - 对齐 Android lastSearchResults
  List<MapSearchResult> _lastSearchResults = const [];

  /// 当前位置 Marker 的图标数据（蓝色）- 对齐 Android createBitmapDescriptorFromIcon(Color.Blue)
  Uint8List? _blueIconData;

  /// 搜索结果 Marker 的图标数据（红色）- 对齐 Android createBitmapDescriptorFromIcon(Color.Red)
  Uint8List? _redIconData;

  /// SDK 是否已初始化 - 对齐 Android BaiduMapSdkManager.ensureInitialized
  bool _sdkReady = false;

  @override
  void initState() {
    super.initState();
    // 对齐 Android remember(context) { BaiduMapSdkManager.ensureInitialized(context) }
    // 必须在 BMFMapWidget 构造前完成 SDK 初始化，避免从首页直接进入时崩溃
    _initializeSdk();
    // 预生成 Marker 图标数据 - 对齐 Android createBitmapDescriptorFromIcon 的预生成
    _generateMarkerIcons();
  }

  Future<void> _initializeSdk() async {
    final ready = await BaiduSdkInitializer.ensureInitialized();
    if (!mounted) return;
    setState(() => _sdkReady = ready);
  }

  @override
  void didUpdateWidget(covariant MapCompose oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 对齐 Android LaunchedEffect(resetUserDrag)
    if (widget.resetUserDrag && !oldWidget.resetUserDrag) {
      _hasUserDragged = false;
      debugPrint('MapCompose: 用户拖拽状态已重置，允许自动移动镜头');
    }

    // 检测数据变化 - 对齐 Android update 回调中的 locationChanged/searchResultsChanged
    final locationChanged = _lastCurrentLocation != widget.currentLocation;
    final searchResultsChanged = _lastSearchResults != widget.searchResults;

    if (locationChanged || searchResultsChanged) {
      _updateMarkers();
    }
  }

  /// 生成 Marker 图标数据 - 对齐 Android createBitmapDescriptorFromIcon
  /// 通过 MaterialIcons 字体绘制为 PNG 字节数据，传给 BMFMarker.iconData
  Future<void> _generateMarkerIcons() async {
    try {
      // 对齐 Android Icons.Default.LocationOn + Color.Blue
      _blueIconData = await _buildIconData(const Color(0xFF2196F3));
      // 对齐 Android Icons.Default.LocationOn + Color.Red
      _redIconData = await _buildIconData(const Color(0xFFF44336));
      if (mounted) {
        setState(() {});
        // 图标就绪后若已有 controller，立即更新一次标记
        if (_mapController != null) {
          _updateMarkers();
        }
      }
    } catch (e) {
      debugPrint('MapCompose: 生成 Marker 图标失败: $e');
    }
  }

  /// 将 Material Icons.location_on 绘制为 PNG 字节数据
  /// 对齐 Android Bitmap.createBitmap + Canvas + drawable.draw(canvas)
  Future<Uint8List> _buildIconData(Color color) async {
    const int size = 72;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    final TextPainter textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.location_on.codePoint),
      style: TextStyle(
        fontSize: size.toDouble(),
        color: color,
        fontFamily: Icons.location_on.fontFamily,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, ui.Offset.zero);

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(size, size);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// 更新地图标记 - 对齐 Android update 回调中的标记更新逻辑
  Future<void> _updateMarkers() async {
    final controller = _mapController;
    if (controller == null) {
      debugPrint('MapCompose: controller 未就绪，跳过标记更新');
      return;
    }

    final currentLocation = widget.currentLocation;
    final searchResults = widget.searchResults;

    final locationChanged = _lastCurrentLocation != currentLocation;
    final searchResultsChanged = _lastSearchResults != searchResults;

    if (!locationChanged && !searchResultsChanged) {
      debugPrint('MapCompose: 数据无变化，跳过地图标记更新');
      return;
    }

    debugPrint(
        'MapCompose: 检测到数据变化 - 位置变化: $locationChanged, 搜索结果变化: $searchResultsChanged');

    _lastCurrentLocation = currentLocation;
    _lastSearchResults = searchResults;

    try {
      // 对齐 Android map.clear()：清空所有覆盖物
      await controller.cleanAllMarkers();
      debugPrint('MapCompose: 地图标记已清空');

      // 对齐 Android adjustMapViewToTargetLocation
      if (widget.isSearchTargetLocation && searchResults.isNotEmpty) {
        await _adjustMapViewToTargetLocation(
            controller, searchResults.first.latLng);
      } else {
        await _adjustMapViewToTargetLocation(controller, currentLocation);
      }

      // 添加当前位置标记 - 对齐 Android currentLocation?.let { MarkerOptions().position(...).icon(蓝色) }
      if (currentLocation != null) {
        await _addMarker(
          controller: controller,
          position: currentLocation,
          title: '我的位置',
          iconData: _blueIconData,
        );
        debugPrint(
            'MapCompose: 当前位置标记已添加: ${currentLocation.latitude}, ${currentLocation.longitude}');

        // 对齐 Android：只有在用户未拖拽过地图时才移动相机到当前位置
        if (searchResults.isEmpty && !_hasUserDragged) {
          try {
            // 对齐 Android MapStatusUpdateFactory.newLatLngZoom(location, 16f)
            await controller.setNewLatLngZoom(
              coordinate: currentLocation,
              zoom: 16,
            );
            debugPrint('MapCompose: 自动移动相机到当前位置: $currentLocation');
          } catch (e) {
            debugPrint('MapCompose: 移动相机失败: $e');
          }
        } else {
          debugPrint(
              'MapCompose: 跳过自动移动相机 - 有搜索结果: ${searchResults.isNotEmpty}, 用户已拖拽: $_hasUserDragged');
        }
      }

      // 添加搜索结果标记 - 对齐 Android searchResults.forEachIndexed { MarkerOptions().position(...).icon(红色) }
      if (searchResults.isNotEmpty) {
        debugPrint('MapCompose: 开始添加${searchResults.length}个搜索结果标记');
        int addedCount = 0;
        for (int index = 0; index < searchResults.length; index++) {
          final result = searchResults[index];
          // 对齐 Android 跳过无效坐标
          if (result.latLng.latitude == 0.0 && result.latLng.longitude == 0.0) {
            debugPrint(
                'MapCompose: 跳过无效坐标的标记: ${result.name} - 坐标: ${result.latLng.latitude}, ${result.latLng.longitude}');
            continue;
          }
          try {
            await _addMarker(
              controller: controller,
              position: result.latLng,
              title: result.name,
              iconData: _redIconData,
            );
            addedCount++;
            debugPrint(
                'MapCompose: 标记${index + 1}已添加: ${result.name} at ${result.latLng.latitude}, ${result.latLng.longitude}');
          } catch (e) {
            debugPrint('MapCompose: 添加搜索结果标记${index + 1}时出错: $e');
          }
        }
        debugPrint('MapCompose: 标记添加完成 - 成功添加的标记数: $addedCount');
      } else {
        debugPrint('MapCompose: 没有搜索结果需要添加标记');
      }
    } catch (e) {
      debugPrint('MapCompose: 更新地图标记时出错: $e');
    }
  }

  /// 添加单个 Marker - 对齐 Android map.addOverlay(MarkerOptions) as Marker
  Future<void> _addMarker({
    required BMFMapController controller,
    required BMFCoordinate position,
    required String title,
    required Uint8List? iconData,
  }) async {
    try {
      // 对齐 Android MarkerOptions().position().title().icon()
      // 鸿蒙端：BMFMarker.iconData(position, iconData, title)
      // 兼容 icon 数据未就绪的情况：iconData 为 null 时 SDK 使用默认大头针
      final BMFMarker marker = iconData != null
          ? BMFMarker.iconData(
              position: position,
              iconData: iconData,
              title: title,
            )
          : BMFMarker.icon(
              position: position,
              icon: '', // 空字符串触发默认图标
              title: title,
            );
      await controller.addMarker(marker);
    } catch (e) {
      debugPrint('MapCompose: 添加 Marker 失败: $e');
      // TODO: 鸿蒙端 SDK 在部分机型上 addMarker 可能因 iconData 编码问题失败，
      // 后续可考虑改用 icon 路径或预置 asset 图片
      rethrow;
    }
  }

  /// 调整地图视野到目标位置 - 对齐 Android adjustMapViewToTargetLocation
  Future<void> _adjustMapViewToTargetLocation(
    BMFMapController controller,
    BMFCoordinate? target,
  ) async {
    debugPrint('MapCompose: 设置默认的地图中心点: $target');
    if (target == null) return;
    try {
      // 对齐 Android baiduMap.setMapStatus(MapStatusUpdateFactory.newLatLngZoom(it, 15f))
      await controller.setNewLatLngZoom(
        coordinate: target,
        zoom: 15,
      );
    } catch (e) {
      debugPrint('MapCompose: 设置地图中心点失败: $e');
    }
  }

  /// 地图创建完成回调 - 对齐 Android factory { setupMap(...); onMapReady(map) }
  void _onMapCreated(BMFMapController controller) {
    _mapController = controller;
    debugPrint('MapCompose: 地图创建完成');

    try {
      // 对齐 Android setupMap：设置手势监听检测用户拖拽
      // 鸿蒙端通过 setMapRegionDidChangeWithReasonCallback 监听区域变化原因
      controller.setMapRegionDidChangeWithReasonCallback(
        callback:
            (BMFMapStatus mapStatus, BMFRegionChangeReason regionChangeReason) {
          // 对齐 Android isUserTouching && !isProgrammaticChange：reason == Gesture 表示用户手势触发
          if (regionChangeReason == BMFRegionChangeReason.Gesture) {
            _hasUserDragged = true;
            debugPrint('MapCompose: 检测到用户拖拽，停止自动移动镜头');
          }
        },
      );
    } catch (e) {
      debugPrint('MapCompose: 设置区域变化回调失败: $e');
    }

    try {
      // 对齐 Android baiduMap.isMyLocationEnabled = true：启用定位图层
      controller.showUserLocation(true);
    } catch (e) {
      debugPrint('MapCompose: 启用定位图层失败: $e');
    }

    // 对齐 Android onMapReady(map)
    widget.onMapReady?.call(controller);

    // 首次创建后立即更新一次标记
    _updateMarkers();
  }

  /// 缩放按钮点击：放大 - 对齐 Android map.animateMapStatus(MapStatusUpdateFactory.zoomTo(currentZoom + 1))
  void _onZoomIn() {
    _mapController?.zoomIn();
  }

  /// 缩放按钮点击：缩小 - 对齐 Android map.animateMapStatus(MapStatusUpdateFactory.zoomTo(currentZoom - 1))
  void _onZoomOut() {
    _mapController?.zoomOut();
  }

  @override
  Widget build(BuildContext context) {
    // 对齐 Android if (!_sdkReady) return FrameLayout(ctx)（占位）
    if (!_sdkReady) {
      return const SizedBox.shrink();
    }

    // 对齐 Android Box(modifier = modifier) { AndroidView(...); ZoomButton; MapInfoContent }
    return Stack(
      children: [
        // 地图层 - 对齐 Android AndroidView(factory = { MapView(ctx, BaiduMapOptions()) })
        // 对齐 Android setupMap：MAP_TYPE_NORMAL + 不显示缩放控件 + 不显示指南针
        Positioned.fill(
          child: BMFMapWidget(
            onBMFMapCreated: _onMapCreated,
            mapOptions: BMFMapOptions(
              mapType: BMFMapType.Standard, // 对齐 Android MAP_TYPE_NORMAL
              compassEnabled:
                  false, // 对齐 Android uiSettings.isCompassEnabled = false
              showZoomControl:
                  false, // 对齐 Android mapView.showZoomControls(false)
              gesturesEnabled: true,
              zoomEnabled: true,
              scrollEnabled: true,
            ),
          ),
        ),

        // 自定义缩放按钮 - 对齐 Android Column(align BottomEnd, padding end 20 bottom 38)
        Positioned(
          right: 20,
          bottom: 38,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // 对齐 Android Arrangement.spacedBy(8.dp)
            children: [
              ZoomButton(
                isZoomIn: true,
                onClick: _onZoomIn,
              ),
              const SizedBox(height: 8),
              ZoomButton(
                isZoomIn: false,
                onClick: _onZoomOut,
              ),
            ],
          ),
        ),

        // 审图号信息 - 对齐 Android MapInfoContent（align BottomStart）
        const Positioned(
          left: 4,
          bottom: 40,
          child: MapInfoContent(),
        ),
      ],
    );
  }
}

/// 自定义缩放按钮组件 - 对齐 Android ZoomButton
/// 白色圆角阴影方块，显示 + / -
class ZoomButton extends StatelessWidget {
  const ZoomButton({
    super.key,
    required this.isZoomIn,
    required this.onClick,
  });

  /// 是否为放大按钮（true 显示 +，false 显示 -）
  final bool isZoomIn;

  /// 点击回调
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Box(size 44dp, shadow 4dp, 圆角 8dp, 白底, clickable)
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onClick,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            // 对齐 Android Text("+/-", color Black, fontSize 24, Bold)
            child: Text(
              isZoomIn ? '+' : '-',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 带白色描边的文本组件 - 对齐 Android OutlinedText
/// 通过多层偏移文本叠加形成描边效果
class OutlinedText extends StatelessWidget {
  const OutlinedText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.textColor,
    this.outlineColor = Colors.white,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  /// 文本内容
  final String text;

  /// 字号
  final double fontSize;

  /// 主文本颜色
  final Color textColor;

  /// 描边颜色（默认白色）
  final Color outlineColor;

  /// 最大行数
  final int maxLines;

  /// 溢出处理
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Box { 8 方向偏移白色描边 + 主文本 }
    // strokeWidth 1dp
    const double strokeWidth = 1;
    final List<ui.Offset> offsets = [
      ui.Offset(-strokeWidth, -strokeWidth),
      ui.Offset(-strokeWidth, strokeWidth),
      ui.Offset(strokeWidth, -strokeWidth),
      ui.Offset(strokeWidth, strokeWidth),
      ui.Offset(-strokeWidth, 0),
      ui.Offset(strokeWidth, 0),
      ui.Offset(0, -strokeWidth),
      ui.Offset(0, strokeWidth),
    ];

    return Stack(
      children: [
        // 描边层 - 对齐 Android listOf(...).forEach { Text(offset) }
        for (final offset in offsets)
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: outlineColor,
              ),
              maxLines: maxLines,
              overflow: overflow,
            ),
          ),
        // 主文本层
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
          ),
          maxLines: maxLines,
          overflow: overflow,
        ),
      ],
    );
  }
}

/// 审图号等信息 - 对齐 Android BoxScope.MapInfoContent
/// 显示在地图左下角的合规信息
class MapInfoContent extends StatelessWidget {
  const MapInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Column(align BottomStart, padding start 4 bottom 40)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 对齐 Android OutlinedText("审图号：GS(2023)3206", 12sp, Black)
        const OutlinedText(
          text: '审图号：GS(2023)3206',
          fontSize: 12,
          textColor: Colors.black,
        ),
        const SizedBox(height: 4),
        // 对齐 Android OutlinedText("测绘资质：甲测资字11111342", 12sp, Black)
        const OutlinedText(
          text: '测绘资质：甲测资字11111342',
          fontSize: 12,
          textColor: Colors.black,
        ),
        const SizedBox(height: 4),
        // 对齐 Android OutlinedText("地图服务由北京百度网讯科技有限公司提供", 12sp, Black)
        const OutlinedText(
          text: '地图服务由北京百度网讯科技有限公司提供',
          fontSize: 12,
          textColor: Colors.black,
        ),
      ],
    );
  }
}
