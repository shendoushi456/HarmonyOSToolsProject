/// 车牌选项静态数据仓库
///
/// 对应 Android: SearchCarInfoFragment.kt:67-115 companion object 的硬编码选项
class LicensePlateOptionsRepository {
  /// 能源类型（对应 energyTypes）
  static const energyTypes = ['默认', '新能源', '非新能源'];

  /// 车牌前缀（对应 licensePlatePrefix，32 项：默认 + 31 省份简称）
  static const licensePlatePrefix = [
    '默认', '京', '皖', '闽', '甘', '粤', '桂', '贵', '琼', '冀', '豫', '黑', '鄂', '湘', '吉',
    '苏', '赣', '辽', '蒙', '宁', '青', '鲁', '晋', '陕', '浙', '沪', '云', '渝', '川', '津', '藏', '新',
  ];

  /// 车牌类型（对应 licensePlateType）
  static const licensePlateType = ['默认', '小型汽车', '大型汽车', '新能源汽车', '挂车'];

  // 注：原 Android 还定义了 licensePlateNumber（与 licensePlateType 相同），
  // 但 UI 中 "车牌号码" 用的是 TextInputItem（输入框）而非 SelectionItem（下拉），
  // 该变量实际未被使用，此处不迁移。

  List<String> getEnergyTypes() => energyTypes;
  List<String> getPlatePrefixes() => licensePlatePrefix;
  List<String> getPlateTypes() => licensePlateType;
}
