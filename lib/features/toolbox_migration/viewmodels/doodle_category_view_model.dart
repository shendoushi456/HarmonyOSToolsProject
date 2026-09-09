import '../../../core/constants/app_assets.dart';

class DoodleCategoryItem {
  const DoodleCategoryItem(
      {required this.title,
      required this.asset,
      required this.code,
      required this.offline});

  final String title;
  final String asset;
  final int code;
  final bool offline;
}

/// DoodleCategoryFragment 的静态展示模型；分类页本身负责后续导航。
class DoodleCategoryViewModel {
  const DoodleCategoryViewModel._();

  static const categoryItems = [
    DoodleCategoryItem(
        title: '卡通',
        asset: AppAssets.doodleCategoryCartoon,
        code: 2,
        offline: false),
    DoodleCategoryItem(
        title: '动物',
        asset: AppAssets.doodleCategoryAnimal,
        code: 3,
        offline: false),
    DoodleCategoryItem(
        title: '食物',
        asset: AppAssets.doodleCategoryFood,
        code: 4,
        offline: false),
    DoodleCategoryItem(
        title: '交通',
        asset: AppAssets.doodleCategoryTraffic,
        code: 5,
        offline: false),
    DoodleCategoryItem(
        title: '自然',
        asset: AppAssets.doodleCategoryNature,
        code: 6,
        offline: false),
    DoodleCategoryItem(
        title: '鲜花',
        asset: AppAssets.doodleCategoryFlower,
        code: 1,
        offline: false),
  ];

  static const offlineItems = [
    DoodleCategoryItem(
        title: '水果',
        asset: AppAssets.doodleCategoryFruit,
        code: 0,
        offline: true),
    DoodleCategoryItem(
        title: '字母',
        asset: AppAssets.doodleCategoryLetter,
        code: 0,
        offline: true),
    DoodleCategoryItem(
        title: '数字',
        asset: AppAssets.doodleCategoryNumber,
        code: 0,
        offline: true),
    DoodleCategoryItem(
        title: '曼茶罗',
        asset: AppAssets.doodleCategoryMandala,
        code: 0,
        offline: true),
  ];
}
