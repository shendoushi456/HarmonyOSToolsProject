// 附近首页 ViewModel - 将功能数据从可替换 UI 中抽离。
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../models/nearby_function.dart';

class NearbyViewModel extends Notifier<List<List<NearbyFunction>>> {
  @override
  List<List<NearbyFunction>> build() => const [
        [
          NearbyFunction(
            name: '超市购物',
            imageAsset: AppAssets.toolboxNearbySupermarket,
          ),
          NearbyFunction(
            name: '休闲娱乐',
            imageAsset: AppAssets.toolboxNearbyEntertainment,
          ),
          NearbyFunction(name: '美食', imageAsset: AppAssets.toolboxNearbyFood),
          NearbyFunction(
            name: '地铁站',
            imageAsset: AppAssets.toolboxNearbySubway,
          ),
        ],
        [
          NearbyFunction(name: '酒店', imageAsset: AppAssets.toolboxNearbyHotel),
          NearbyFunction(name: '景点', imageAsset: AppAssets.toolboxNearbyScenic),
          NearbyFunction(name: '美食', imageAsset: AppAssets.toolboxNearbyFood2),
          NearbyFunction(name: '公交站', imageAsset: AppAssets.toolboxNearbyBus),
        ],
      ];
}

final nearbyViewModelProvider =
    NotifierProvider<NearbyViewModel, List<List<NearbyFunction>>>(
  NearbyViewModel.new,
);
