import '../../../core/constants/app_assets.dart';

/// AllToolsFragment 的展示数据层；整体换肤时可替换本模型或页面布局。
enum AllToolsDestination {
  create,
  compass,
  selfieAnime,
  travelChecklist,
  mosaic,
  colourize,
  traceDrawing,
  shapeDrawing,
}

class AllToolsItem {
  const AllToolsItem({
    required this.title,
    required this.asset,
    required this.destination,
    this.subtitle = '',
  });

  final String title;
  final String subtitle;
  final String asset;
  final AllToolsDestination destination;
}

class AllToolsViewModel {
  const AllToolsViewModel._();

  static const create = AllToolsItem(
    title: '开始创作',
    asset: AppAssets.allToolsAndroidCreate,
    destination: AllToolsDestination.create,
  );

  /// Android 中“隐藏图”按需求排除；原“特效图”位置改接人像动漫化。
  static const quickTools = [
    AllToolsItem(
      title: '指南针',
      asset: AppAssets.allToolsAndroidCompass,
      destination: AllToolsDestination.compass,
    ),
    AllToolsItem(
      title: '图像动漫化',
      asset: AppAssets.allToolsAndroidAnime,
      destination: AllToolsDestination.selfieAnime,
    ),
    AllToolsItem(
      title: '旅行清单',
      asset: AppAssets.allToolsAndroidTravel,
      destination: AllToolsDestination.travelChecklist,
    ),
  ];

  static const paintingTools = [
    AllToolsItem(
      title: '马赛克',
      subtitle: '保护隐私更安全',
      asset: AppAssets.allToolsAndroidMosaic,
      destination: AllToolsDestination.mosaic,
    ),
    AllToolsItem(
      title: '黑白上色',
      subtitle: '一键轻松还原照片颜色',
      asset: AppAssets.allToolsAndroidColorize,
      destination: AllToolsDestination.colourize,
    ),
    AllToolsItem(
      title: '跟图绘画',
      subtitle: '参照图片随意临摹',
      asset: AppAssets.allToolsAndroidTrace,
      destination: AllToolsDestination.traceDrawing,
    ),
    AllToolsItem(
      title: '形状绘画',
      subtitle: '根据形状随意绘制',
      asset: AppAssets.allToolsAndroidShape,
      destination: AllToolsDestination.shapeDrawing,
    ),
  ];
}
