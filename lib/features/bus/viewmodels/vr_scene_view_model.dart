// VR 实景 ViewModel - 保持数据与可替换 UI 分离，对齐 Android getVrSceneData()。
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_assets.dart';
import '../models/vr_scene.dart';

class VrSceneViewModel extends Notifier<List<VrScene>> {
  @override
  List<VrScene> build() => const [
        VrScene(
          imageAsset: AppAssets.toolboxVr1,
          title: '丽江古城',
          subtitle: '古韵悠悠，流水人家',
          url: 'https://www.720yun.com/t/408jrz4asn8?scene_id=32323067',
        ),
        VrScene(
          imageAsset: AppAssets.toolboxVr2,
          title: '布达拉宫',
          subtitle: '雪域圣殿，信仰之巅',
          url: 'https://www.720yun.com/t/408jrz4asn8?scene_id=32423232',
        ),
        VrScene(
          imageAsset: AppAssets.toolboxVr3,
          title: '甘孜丹巴党岭',
          subtitle: '云端藏寨，秘境党岭',
          url: 'https://www.720yun.com/t/cdvkOb1mzib?scene_id=58856723',
        ),
        VrScene(
          imageAsset: AppAssets.toolboxVr4,
          title: '古滇家宴',
          subtitle: '千年滇韵，一宴风华',
          url: 'https://www.720yun.com/t/48vkiw2lzf7?scene_id=67875422',
        ),
        VrScene(
          imageAsset: AppAssets.toolboxVr5,
          title: '虎跳峡',
          subtitle: '怒江劈石，险峻惊天',
          url: 'https://www.720yun.com/t/408jrz4asn8?scene_id=32323071',
        ),
        VrScene(
          imageAsset: AppAssets.toolboxVr6,
          title: '孔雀山',
          subtitle: '翠羽映霞，仙境如屏',
          url: 'https://www.720yun.com/t/09vkib1qzfb?scene_id=37470967',
        ),
        VrScene(
          imageAsset: AppAssets.toolboxVr7,
          title: '拉乌山口',
          subtitle: '巍峨界碑，云天溢口',
          url: 'https://www.720yun.com/t/408jrz4asn8?scene_id=32323088',
        ),
        VrScene(
          imageAsset: AppAssets.toolboxVr8,
          title: '丽江老君山',
          subtitle: '仙境隐滇西',
          url: 'https://www.720yun.com/t/408jrz4asn8?scene_id=32323070',
        ),
        VrScene(
          imageAsset: AppAssets.toolboxVr9,
          title: '泸沽湖半岛',
          subtitle: '摩梭秘境，湖心遗珠',
          url: 'https://www.720yun.com/t/d7cjtrkm5O2?scene_id=12780617',
        ),
        VrScene(
          imageAsset: AppAssets.toolboxVr10,
          title: '维港璀璨夜',
          subtitle: '幻彩映香江',
          url: 'https://www.720yun.com/t/145jz04nOm4?scene_id=9113098',
        ),
      ];
}

final vrSceneViewModelProvider =
    NotifierProvider<VrSceneViewModel, List<VrScene>>(VrSceneViewModel.new);
