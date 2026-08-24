import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/offline_graffiti_item.dart';

/// 素材数据层。本次入口与 Android ColorMoreFragment 一致，只迁移“水果”。
class OfflineGraffitiViewModel extends Notifier<List<OfflineGraffitiItem>> {
  @override
  List<OfflineGraffitiItem> build() => const [
        OfflineGraffitiItem(
            id: 'image_1560179256',
            assetPath:
                'assets/images/coloring_book/fruits/image_1560179256.webp',
            category: '水果'),
        OfflineGraffitiItem(
            id: 'image_1560179273',
            assetPath:
                'assets/images/coloring_book/fruits/image_1560179273.jpg',
            category: '水果'),
        OfflineGraffitiItem(
            id: 'image_1560179282',
            assetPath:
                'assets/images/coloring_book/fruits/image_1560179282.jpg',
            category: '水果'),
        OfflineGraffitiItem(
            id: 'image_1560179294',
            assetPath:
                'assets/images/coloring_book/fruits/image_1560179294.jpg',
            category: '水果'),
        OfflineGraffitiItem(
            id: 'image_1560179306',
            assetPath:
                'assets/images/coloring_book/fruits/image_1560179306.jpg',
            category: '水果'),
        OfflineGraffitiItem(
            id: 'image_1560179411',
            assetPath:
                'assets/images/coloring_book/fruits/image_1560179411.jpg',
            category: '水果'),
        OfflineGraffitiItem(
            id: 'image_1560179478',
            assetPath:
                'assets/images/coloring_book/fruits/image_1560179478.jpg',
            category: '水果'),
        OfflineGraffitiItem(
            id: 'image_1560179496',
            assetPath:
                'assets/images/coloring_book/fruits/image_1560179496.jpg',
            category: '水果'),
        OfflineGraffitiItem(
            id: 'image_1560179510',
            assetPath:
                'assets/images/coloring_book/fruits/image_1560179510.jpg',
            category: '水果'),
        OfflineGraffitiItem(
            id: 'image_1560179528',
            assetPath:
                'assets/images/coloring_book/fruits/image_1560179528.jpg',
            category: '水果'),
        OfflineGraffitiItem(
            id: 'image_yingtao',
            assetPath: 'assets/images/coloring_book/fruits/image_yingtao.webp',
            category: '水果'),
        OfflineGraffitiItem(
            id: 'image_boluo',
            assetPath: 'assets/images/coloring_book/fruits/image_boluo.webp',
            category: '水果'),
      ];
}

final offlineGraffitiProvider =
    NotifierProvider<OfflineGraffitiViewModel, List<OfflineGraffitiItem>>(
        OfflineGraffitiViewModel.new);
