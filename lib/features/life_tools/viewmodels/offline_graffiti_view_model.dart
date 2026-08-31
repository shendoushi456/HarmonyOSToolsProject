import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/offline_graffiti_item.dart';

/// 离线涂鸦素材数据层 - 对齐 Android OffLineTypeActivity.java:59-227
/// 4 分类：水果(12)/数字(11)/字母(11)/曼茶罗(6)
/// 用 loadByClassify(classify) 方法按分类加载列表
class OfflineGraffitiViewModel
    extends Notifier<List<OfflineGraffitiItem>> {
  @override
  List<OfflineGraffitiItem> build() => const [];

  /// 按分类加载列表 - 对齐 OffLineTypeActivity.getImageItems(classify)
  List<OfflineGraffitiItem> loadByClassify(String classify) {
    switch (classify) {
      case '数字':
        return _numbers;
      case '字母':
        return _alphabets;
      case '曼茶罗':
        return _mandala;
      case '水果':
      default:
        return _fruits;
    }
  }

  /// 水果 12 张（对齐 OffLineTypeActivity.java:62-90）
  /// 保真 Bug：f12/f13 的 imageName 重复 "image_1560179528"（resId 不同）
  static const _fruits = [
    OfflineGraffitiItem(
        id: 'image_1560179256',
        assetPath: 'assets/images/coloring_book/fruits/image_1560179256.webp',
        category: '水果'),
    OfflineGraffitiItem(
        id: 'image_1560179273',
        assetPath: 'assets/images/coloring_book/fruits/image_1560179273.jpg',
        category: '水果'),
    OfflineGraffitiItem(
        id: 'image_1560179282',
        assetPath: 'assets/images/coloring_book/fruits/image_1560179282.jpg',
        category: '水果'),
    OfflineGraffitiItem(
        id: 'image_1560179294',
        assetPath: 'assets/images/coloring_book/fruits/image_1560179294.jpg',
        category: '水果'),
    OfflineGraffitiItem(
        id: 'image_1560179306',
        assetPath: 'assets/images/coloring_book/fruits/image_1560179306.jpg',
        category: '水果'),
    OfflineGraffitiItem(
        id: 'image_1560179411',
        assetPath: 'assets/images/coloring_book/fruits/image_1560179411.jpg',
        category: '水果'),
    OfflineGraffitiItem(
        id: 'image_1560179478',
        assetPath: 'assets/images/coloring_book/fruits/image_1560179478.jpg',
        category: '水果'),
    OfflineGraffitiItem(
        id: 'image_1560179496',
        assetPath: 'assets/images/coloring_book/fruits/image_1560179496.jpg',
        category: '水果'),
    OfflineGraffitiItem(
        id: 'image_1560179510',
        assetPath: 'assets/images/coloring_book/fruits/image_1560179510.jpg',
        category: '水果'),
    OfflineGraffitiItem(
        id: 'image_1560179528',
        assetPath: 'assets/images/coloring_book/fruits/image_1560179528.jpg',
        category: '水果'),
    // 保真 Bug：id 重复 "image_1560179528"，但 assetPath 是 yingtao
    OfflineGraffitiItem(
        id: 'image_1560179528',
        assetPath: 'assets/images/coloring_book/fruits/image_yingtao.webp',
        category: '水果'),
    // 保真 Bug：id 重复 "image_1560179528"，但 assetPath 是 boluo
    OfflineGraffitiItem(
        id: 'image_1560179528',
        assetPath: 'assets/images/coloring_book/fruits/image_boluo.webp',
        category: '水果'),
  ];

  /// 数字 11 张（对齐 OffLineTypeActivity.java:91-116）
  static const _numbers = [
    OfflineGraffitiItem(
        id: 'image_1559733137',
        assetPath: 'assets/images/coloring_book/numbers/image_1559733137.png',
        category: '数字'),
    OfflineGraffitiItem(
        id: 'image_1559733145',
        assetPath: 'assets/images/coloring_book/numbers/image_1559733145.png',
        category: '数字'),
    OfflineGraffitiItem(
        id: 'image_1559733240',
        assetPath: 'assets/images/coloring_book/numbers/image_1559733240.png',
        category: '数字'),
    OfflineGraffitiItem(
        id: 'image_1559733220',
        assetPath: 'assets/images/coloring_book/numbers/image_1559733220.png',
        category: '数字'),
    OfflineGraffitiItem(
        id: 'image_1559733301',
        assetPath: 'assets/images/coloring_book/numbers/image_1559733301.png',
        category: '数字'),
    OfflineGraffitiItem(
        id: 'image_1559733313',
        assetPath: 'assets/images/coloring_book/numbers/image_1559733313.png',
        category: '数字'),
    OfflineGraffitiItem(
        id: 'image_1559733329',
        assetPath: 'assets/images/coloring_book/numbers/image_1559733329.png',
        category: '数字'),
    OfflineGraffitiItem(
        id: 'image_1559733340',
        assetPath: 'assets/images/coloring_book/numbers/image_1559733340.png',
        category: '数字'),
    OfflineGraffitiItem(
        id: 'image_1559733393',
        assetPath: 'assets/images/coloring_book/numbers/image_1559733393.png',
        category: '数字'),
    OfflineGraffitiItem(
        id: 'image_1559733423',
        assetPath: 'assets/images/coloring_book/numbers/image_1559733423.png',
        category: '数字'),
    OfflineGraffitiItem(
        id: 'image_1670656777',
        assetPath: 'assets/images/coloring_book/numbers/image_1670656777.jpeg',
        category: '数字'),
  ];

  /// 字母 11 张（对齐 OffLineTypeActivity.java:117-141）
  static const _alphabets = [
    OfflineGraffitiItem(
        id: 'image_1559733191',
        assetPath: 'assets/images/coloring_book/alphabets/image_1559733191.png',
        category: '字母'),
    OfflineGraffitiItem(
        id: 'image_1559733199',
        assetPath: 'assets/images/coloring_book/alphabets/image_1559733199.png',
        category: '字母'),
    OfflineGraffitiItem(
        id: 'image_1559733263',
        assetPath: 'assets/images/coloring_book/alphabets/image_1559733263.png',
        category: '字母'),
    OfflineGraffitiItem(
        id: 'image_1559733206',
        assetPath: 'assets/images/coloring_book/alphabets/image_1559733206.png',
        category: '字母'),
    OfflineGraffitiItem(
        id: 'image_1559733277',
        assetPath: 'assets/images/coloring_book/alphabets/image_1559733277.png',
        category: '字母'),
    OfflineGraffitiItem(
        id: 'image_1559733287',
        assetPath: 'assets/images/coloring_book/alphabets/image_1559733287.png',
        category: '字母'),
    OfflineGraffitiItem(
        id: 'image_1559733366',
        assetPath: 'assets/images/coloring_book/alphabets/image_1559733366.png',
        category: '字母'),
    OfflineGraffitiItem(
        id: 'image_1559733356',
        assetPath: 'assets/images/coloring_book/alphabets/image_1559733356.png',
        category: '字母'),
    OfflineGraffitiItem(
        id: 'image_1559733406',
        assetPath: 'assets/images/coloring_book/alphabets/image_1559733406.png',
        category: '字母'),
    OfflineGraffitiItem(
        id: 'image_1559733378',
        assetPath: 'assets/images/coloring_book/alphabets/image_1559733378.png',
        category: '字母'),
    OfflineGraffitiItem(
        id: 'image_1559733437',
        assetPath: 'assets/images/coloring_book/alphabets/image_1559733437.png',
        category: '字母'),
  ];

  /// 曼茶罗 6 张（对齐 OffLineTypeActivity.java:142-160，m7/m8 注释忽略）
  static const _mandala = [
    OfflineGraffitiItem(
        id: 'image_1559564960',
        assetPath: 'assets/images/coloring_book/mandala/image_1559564960.png',
        category: '曼茶罗'),
    OfflineGraffitiItem(
        id: 'image_1559565039',
        assetPath: 'assets/images/coloring_book/mandala/image_1559565039.png',
        category: '曼茶罗'),
    OfflineGraffitiItem(
        id: 'image_1559564913',
        assetPath: 'assets/images/coloring_book/mandala/image_1559564913.png',
        category: '曼茶罗'),
    OfflineGraffitiItem(
        id: 'image_1559564876',
        assetPath: 'assets/images/coloring_book/mandala/image_1559564876.png',
        category: '曼茶罗'),
    OfflineGraffitiItem(
        id: 'image_1559638166',
        assetPath: 'assets/images/coloring_book/mandala/image_1559638166.png',
        category: '曼茶罗'),
    OfflineGraffitiItem(
        id: 'image_1559564859',
        assetPath: 'assets/images/coloring_book/mandala/image_1559564859.png',
        category: '曼茶罗'),
  ];
}

/// 普通 Notifier provider，page 侧调 loadByClassify(classify) 加载数据
final offlineGraffitiProvider =
    NotifierProvider<OfflineGraffitiViewModel, List<OfflineGraffitiItem>>(
        OfflineGraffitiViewModel.new);
