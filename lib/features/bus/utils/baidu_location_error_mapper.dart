// 百度定位错误码映射 - 对齐 Android bus/utils/BaiduLocationErrorMapper.kt
// 将百度定位 SDK 的原始状态码转换为可处理的业务错误文案
// 鸿蒙端差异：Android 用 BDLocation.locType，Flutter 用 BaiduLocation.locType（int?）
import 'package:flutter_bmflocation/flutter_bmflocation.dart';

/// 将百度定位 SDK 的原始状态码转换为可处理的业务错误 - 对齐 Android BaiduLocationErrorMapper
class BaiduLocationErrorMapper {
  BaiduLocationErrorMapper._();

  /// 根据 BaiduLocation 返回错误文案 - 对齐 Android messageFor(location: BDLocation?)
  static String messageFor(BaiduLocation? location) {
    if (location == null) return '定位服务未返回位置信息';
    // 鸿蒙定位插件仅在成功时填充 locType；失败时错误码放在 errorCode。
    // 不能只读取 locType，否则 AK、权限、定位服务开关等关键原因都会丢失。
    final message = messageForCode(location.locType ?? location.errorCode);
    final detail = location.errorInfo?.trim();
    return detail == null || detail.isEmpty ? message : '$message（$detail）';
  }

  /// 根据状态码返回错误文案
  /// 鸿蒙端状态码与 Android BDLocation 一致
  static String messageForCode(int? locType) {
    if (locType == null) return '定位服务未返回位置信息';

    switch (locType) {
      case 61: // TypeGpsLocation - GPS 定位成功
      case 66: // TypeOffLineLocation - 离线定位成功
      case 161: // TypeNetWorkLocation - 网络定位成功
      case 62: // TypeCacheLocation - 缓存定位成功
        return '定位成功';
      case 167: // TypeServerError - 服务端网络定位失败
        return '定位服务暂不可用，请稍后重试';
      case 162: // TypeNetWorkException - 网络不通
        return '网络不可用，无法获取当前位置';
      case 163: // TypeCriteriaException - 定位参数异常
        return '定位参数异常，请重试';
      case 164: // TypeServerCheckKeyError - AK 校验失败
        return '定位失败，错误码：$locType';
      case 165: // TypeServerCheckFlowError - 配额受限
        return '地图服务调用额度受限，请检查百度地图控制台配额';
      case 166: // TypeServerDecryptError - 响应校验失败
        return '地图服务响应校验失败，请稍后重试';
      case 168: // TYPE_NO_PERMISSION_LOCATION_FAIL - 未授予权限
      case 171: // TYPE_NO_PERMISSION_AND_CLOSE_SWITCH_FAIL
        return '未授予定位权限，请在系统设置中开启定位权限';
      case 169: // TYPE_CLOSE_LOCATION_SERVICE_SWITCH_FAIL - 定位服务未开启
        return '系统定位服务未开启，请在系统设置中开启定位服务';
      case 505: // 鸿蒙端 AK 校验失败（bundle/appSignature 与百度控制台不匹配）
        return '定位服务授权失败（505）：';
      default:
        return '定位失败，错误码：$locType';
    }
  }
}
