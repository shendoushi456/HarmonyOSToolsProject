// 路线选择数据类 - 对齐 Android HomeFragment.kt 末尾的 RouteChoice
// 注：Android 端 icon 为 Int（mipmap 资源 id），Flutter 端改为 String（资源路径）
import '../models/address_info.dart';

/// 路线选择项 - 对齐 Android HomeFragment.RouteChoice
/// 用于 HomeFragment.RoutePlanningCard 的 4 种交通方式展示
class RouteChoice {
  const RouteChoice({
    required this.mode,
    required this.title,
    required this.icon,
  });

  /// 交通方式（用于 MapRouteActivity 跳转传参）
  /// 注意：Android 端此字段类型为 com.p.a_b.bus.TransportMode（sealed class）
  /// Flutter 端用 TransportMode 枚举（持久化版）+ index 转换
  final TransportMode mode;

  /// 显示标题（步行路线/骑行路线/驾车路线/公交路线）
  final String title;

  /// 图标资源路径（Flutter 端为 String，对应 AppAssets.jbcxRouteXxx）
  final String icon;
}
