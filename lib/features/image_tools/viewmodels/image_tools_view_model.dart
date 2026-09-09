import '../../../core/constants/app_assets.dart';

/// ImageToolsFragment 的展示数据层。
/// 页面只消费这些模型，后续整体换肤时无需改动功能路由。
enum ImageToolsDestination {
  styleTransfer,
  plant,
  fruit,
  animal,
  bankCard,
  magnifier,
  currency,
}

class ImageToolsRecognitionItem {
  const ImageToolsRecognitionItem({
    required this.title,
    required this.asset,
    required this.destination,
  });

  final String title;
  final String asset;
  final ImageToolsDestination destination;
}

class ImageToolsListItem {
  const ImageToolsListItem({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.destination,
  });

  final String title;
  final String subtitle;
  final String asset;
  final ImageToolsDestination destination;
}

class ImageToolsViewModel {
  const ImageToolsViewModel._();

  static const recognitionItems = <ImageToolsRecognitionItem>[
    ImageToolsRecognitionItem(
      title: '花草识别',
      asset: AppAssets.imageToolsPlant,
      destination: ImageToolsDestination.plant,
    ),
    ImageToolsRecognitionItem(
      title: '水果识别',
      asset: AppAssets.imageToolsFruit,
      destination: ImageToolsDestination.fruit,
    ),
    ImageToolsRecognitionItem(
      title: '动物识别',
      asset: AppAssets.imageToolsAnimal,
      destination: ImageToolsDestination.animal,
    ),
    ImageToolsRecognitionItem(
      title: '银行卡识别',
      asset: AppAssets.imageToolsBankCard,
      destination: ImageToolsDestination.bankCard,
    ),
  ];

  static const utilityItems = <ImageToolsListItem>[
    ImageToolsListItem(
      title: '放大镜',
      subtitle: '小字清晰可见',
      asset: AppAssets.imageToolsMagnifier,
      destination: ImageToolsDestination.magnifier,
    ),
    ImageToolsListItem(
      title: '汇率换算',
      subtitle: '精准换算各国汇率',
      asset: AppAssets.imageToolsCurrency,
      destination: ImageToolsDestination.currency,
    ),
  ];
}
