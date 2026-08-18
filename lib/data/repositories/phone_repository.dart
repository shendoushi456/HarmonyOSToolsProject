import '../../domain/models/phone_info.dart';

/// 电话信息静态数据仓库
///
/// 对应 Android: TelephoneCarFragment.kt:193-210
/// 道路救援电话 6 条 + 保险公司电话 6 条，均硬编码。
class PhoneRepository {
  /// 道路救援电话（对应 roadRescuePhones）
  static final List<PhoneInfo> _roadRescuePhones = [
    PhoneInfo(title: '平安车险免费救援', phone: '95511转5转2'),
    PhoneInfo(title: '太平洋车险免费救援', phone: '95500转3转3'),
    PhoneInfo(title: '人保车险免费救援', phone: '95518转9'),
    PhoneInfo(title: '大陆汽车免费救援', phone: '400-818-1010'),
    PhoneInfo(title: '中石化免费救援', phone: '95105988转7'),
    PhoneInfo(title: '中联车盟道路救援', phone: '400-810-820'),
  ];

  /// 保险公司电话（对应 insurancePhones）
  static final List<PhoneInfo> _insurancePhones = [
    PhoneInfo(title: '平安保险', phone: '95512'),
    PhoneInfo(title: '人寿保险', phone: '95519'),
    PhoneInfo(title: '太平洋保险', phone: '95500'),
    PhoneInfo(title: '人保保险', phone: '95518'),
    PhoneInfo(title: '平安财险', phone: '95505'),
    PhoneInfo(title: '中华财险', phone: '95585'),
  ];

  List<PhoneInfo> getRoadRescuePhones() => _roadRescuePhones;
  List<PhoneInfo> getInsurancePhones() => _insurancePhones;
}
