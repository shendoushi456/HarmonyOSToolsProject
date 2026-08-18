import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/license_plate_options_repository.dart';
import '../services/external_app_service.dart';

/// 车牌选项仓库 provider
final licensePlateOptionsProvider =
    Provider<LicensePlateOptionsRepository>((ref) {
  return LicensePlateOptionsRepository();
});

/// 外部应用跳转服务 provider
final externalAppServiceProvider = Provider<ExternalAppService>((ref) {
  return ExternalAppService();
});

/// 能源类型当前选择（初始 "请选择"）
/// 对应 Android: SearchCarInfoFragment energyTypeSelected
final energyTypeSelectedProvider = StateProvider<String>((ref) => '请选择');

/// 车牌前缀当前选择（初始 "请选择"）
/// 对应 Android: SearchCarInfoFragment platePrefixSelected
final platePrefixSelectedProvider = StateProvider<String>((ref) => '请选择');

/// 车牌号码当前输入（初始空）
/// 对应 Android: SearchCarInfoFragment plateNumberSelected
final plateNumberSelectedProvider = StateProvider<String>((ref) => '');

/// 车牌类型当前选择（初始 "请选择"）
/// 对应 Android: SearchCarInfoFragment plateTypeSelected
final plateTypeSelectedProvider = StateProvider<String>((ref) => '请选择');
