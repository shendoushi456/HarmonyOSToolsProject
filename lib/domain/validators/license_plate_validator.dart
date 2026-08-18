/// 车牌号校验器
///
/// 对应 Android: SearchCarInfoFragment.kt:71-103
/// - isValidLicensePlate: 正则校验
/// - getLicensePlateErrorMessage: 分级错误提示
class LicensePlateValidator {
  /// 普通车牌格式：字母+5位数字或字母（如 A12345）
  static final _normalPattern = RegExp(r'^[A-Z][A-Z0-9]{5}$');

  /// 新能源车牌格式：字母+6位数字或字母（如 AD12345）
  static final _newEnergyPattern = RegExp(r'^[A-Z][A-Z0-9]{6}$');

  /// 校验车牌号格式是否合法
  static bool isValid(String plateNumber) {
    if (plateNumber.isEmpty) return false;
    return _normalPattern.hasMatch(plateNumber) ||
        _newEnergyPattern.hasMatch(plateNumber);
  }

  /// 获取车牌号错误提示（null 表示无错误）
  static String? errorMessage(String plateNumber) {
    if (plateNumber.isEmpty) {
      return '请输入车牌号码';
    }
    if (plateNumber.length < 6) {
      return '车牌号码长度不够';
    }
    if (plateNumber.length > 7) {
      return '车牌号码长度过长';
    }
    if (!isValid(plateNumber)) {
      return '车牌号码格式不正确';
    }
    return null;
  }
}
