import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../models/viewpoint_attraction.dart';

/// 景点列表状态。Android 端同一时间只允许一项展开。
class ViewpointState {
  const ViewpointState({this.expandedIndex = -1});

  final int expandedIndex;

  ViewpointState copyWith({int? expandedIndex}) {
    return ViewpointState(expandedIndex: expandedIndex ?? this.expandedIndex);
  }
}

class ViewpointViewModel extends Notifier<ViewpointState> {
  static const List<ViewpointAttraction> attractions = [
    ViewpointAttraction(
      name: '北京 故宫博物院',
      description: '穿越历史长廊，感受千年文化的沉淀，这里是中华文明的瑰宝。',
      imageAsset: AppAssets.toolboxViewpoint1,
      destination: ViewpointDestination.imageGuide,
      guideType: '故宫博物院',
    ),
    ViewpointAttraction(
      name: '北京 环球度假区',
      description: '沉浸式电影主题乐园，带你进入梦幻世界，体验不一样的旅程。',
      imageAsset: AppAssets.toolboxViewpoint2,
      destination: ViewpointDestination.imageGuide,
      guideType: '环球度假区',
    ),
    ViewpointAttraction(
      name: '上海 迪士尼度假区',
      description: '梦幻的童话世界，让您重温儿时梦想，与家人共度欢乐时光。',
      imageAsset: AppAssets.toolboxViewpoint3,
      destination: ViewpointDestination.disneyShanghai,
    ),
    ViewpointAttraction(
      name: '北京 八达岭长城',
      description: '雄伟的长城蜿蜒起伏，八达岭更是精华所在，登高远眺。',
      imageAsset: AppAssets.toolboxViewpoint4,
      destination: ViewpointDestination.imageGuide,
      guideType: '八达岭长城',
    ),
    ViewpointAttraction(
      name: '西安 秦始皇陵博物馆（兵马俑）',
      description: '穿越千年，感受秦始皇雄伟壮志，兵马俑的壮观会让你震撼不已。',
      imageAsset: AppAssets.toolboxViewpoint5,
      destination: ViewpointDestination.imageGuide,
      guideType: '兵马俑',
    ),
    ViewpointAttraction(
      name: '杭州 西湖风景名胜区',
      description: '湖光山色相映成趣，古典园林与诗意传说交融人间天堂。',
      imageAsset: AppAssets.toolboxViewpoint6,
      destination: ViewpointDestination.imageGuide,
      guideType: '西湖',
    ),
    ViewpointAttraction(
      name: '香港 迪士尼乐园',
      description: '梦幻童话世界，与心爱的迪士尼角色近距离互动，尽享欢乐时光。',
      imageAsset: AppAssets.toolboxViewpoint7,
      destination: ViewpointDestination.disneyHongKong,
    ),
    ViewpointAttraction(
      name: '上海 外滩',
      description: '十里洋场的历史风情与现代的摩天大楼交相辉映，感受上海魅力。',
      imageAsset: AppAssets.toolboxViewpoint8,
      destination: ViewpointDestination.imageGuide,
      guideType: '外滩',
    ),
    ViewpointAttraction(
      name: '九寨沟 九寨沟风景区',
      description: '碧水映天，彩林如画，这里的每一处景色都仿佛是大自然的杰作。',
      imageAsset: AppAssets.toolboxViewpoint9,
      destination: ViewpointDestination.imageGuide,
      guideType: '九寨沟',
    ),
    ViewpointAttraction(
      name: '乐山 峨眉山',
      description: '云海，日出与佛光，自然与人文的完美结合。',
      imageAsset: AppAssets.toolboxViewpoint10,
      destination: ViewpointDestination.leshan,
    ),
  ];

  @override
  ViewpointState build() => const ViewpointState();

  void toggle(int index) {
    state = state.copyWith(
      expandedIndex: state.expandedIndex == index ? -1 : index,
    );
  }
}

final viewpointViewModelProvider =
    NotifierProvider<ViewpointViewModel, ViewpointState>(
  ViewpointViewModel.new,
);
