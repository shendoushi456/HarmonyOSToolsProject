// 旅行规划主页 - 对齐 Android ViewpointFragment.kt
// 替换原鸿蒙 Flutter 项目的 tab[2]（新增），放在畅行右边
// 含头部标题栏 + 9 个旅行卡片列表
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../router/route_names.dart';
import '../models/travel_plan.dart';

/// 旅行规划主页 - 对齐 Android ViewpointFragment
class ViewpointFragmentPage extends StatelessWidget {
  const ViewpointFragmentPage({super.key});

  /// 9 个旅行目的地 - 对齐 Android TravelPlanScreen 中的 listOf(...)
  static const List<TravelPlan> _plans = [
    TravelPlan(
      title: '上海 迪士尼度假区',
      description: '梦幻的童话世界，让您重温儿时梦想，与家人共度欢乐时光。',
      image: AppAssets.travelDisney,
      action: TravelAction.disney,
    ),
    TravelPlan(
      title: '上海 外滩',
      description: '十里洋场的历史风情与现代的摩天大楼交相辉映，感受上海魅力。',
      image: AppAssets.travelBund,
      action: TravelAction.imageGuide,
      guideType: '外滩',
    ),
    TravelPlan(
      title: '北京 故宫博物院',
      description: '走进红墙黄瓦的宫殿群，感受恢宏建筑与悠久历史。',
      image: AppAssets.travelForbiddenCity,
      action: TravelAction.imageGuide,
      guideType: '故宫博物院',
    ),
    TravelPlan(
      title: '北京 环球度假区',
      description: '沉浸式体验经典电影场景，开启充满惊喜的奇幻旅程。',
      image: AppAssets.travelUniversalBeijing,
      action: TravelAction.imageGuide,
      guideType: '环球度假区',
    ),
    TravelPlan(
      title: '北京 八达岭长城',
      description: '登临雄伟长城远眺群山，领略蜿蜒山脊的壮阔景色。',
      image: AppAssets.travelGreatWall,
      action: TravelAction.imageGuide,
      guideType: '八达岭长城',
    ),
    TravelPlan(
      title: '西安 秦始皇陵博物馆（兵马俑）',
      description: '穿越千年，感受秦始皇雄伟壮志与兵马俑的震撼。',
      image: AppAssets.travelTerracottaWarriors,
      action: TravelAction.imageGuide,
      guideType: '兵马俑',
    ),
    TravelPlan(
      title: '九寨沟 九寨沟风景区',
      description: '碧水映天、彩林如画，每一处景色都仿佛是大自然的杰作。',
      image: AppAssets.travelHuanglong,
      action: TravelAction.imageGuide,
      guideType: '九寨沟',
    ),
    TravelPlan(
      title: '乐山 峨眉山',
      description: '云海、日出与佛光，自然与人文在山水之间完美结合。',
      image: AppAssets.travelLeshanBuddha,
      action: TravelAction.leshanGuide,
    ),
    TravelPlan(
      title: '杭州 西湖风景名胜区',
      description: '泛舟湖上赏三潭印月，在湖光山色间品味江南诗意。',
      image: AppAssets.travelWestLake,
      action: TravelAction.imageGuide,
      guideType: '西湖',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          // 头部标题栏 - 对齐 Android TravelHeader
          SliverToBoxAdapter(child: _TravelHeader()),
          // 9 个旅行卡片 - 对齐 Android items(plans)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final plan = _plans[index];
                return _TravelPlanCard(
                  plan: plan,
                  onClick: () => _openPlan(context, plan),
                );
              },
              childCount: _plans.length,
            ),
          ),
          // 底部留白 - 对齐 Android Spacer(Modifier.height(14.dp))
          const SliverToBoxAdapter(
            child: SizedBox(height: 14),
          ),
        ],
      ),
    );
  }

  /// 打开旅行详情 - 对齐 Android ViewpointFragment.openPlan
  void _openPlan(BuildContext context, TravelPlan plan) {
    switch (plan.action) {
      case TravelAction.disney:
        // 对齐 Android: context.startActivity(Intent(context, DisneyShangHaiScenicDetailActivity::class.java))
        GoRouter.of(context).push(RoutePaths.disneyScenic);
        return;
      case TravelAction.imageGuide:
        // 对齐 Android: context.startActivity(Intent(context, EditorPicTipsActivity).putExtra("type", plan.guideType))
        GoRouter.of(context).push(
          RoutePaths.editorPicTips,
          extra: {'type': plan.guideType},
        );
        return;
      case TravelAction.leshanGuide:
        // 对齐 Android: context.startActivity(Intent(context, LeShanScenicDetailActivity::class.java))
        GoRouter.of(context).push(RoutePaths.leShanScenic);
        return;
    }
  }
}

/// 头部标题栏 - 对齐 Android TravelHeader
/// 渐变背景 + "旅行规划"标题
class _TravelHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 105,
      // 对齐 Android Brush.verticalGradient(listOf(Color(0xFFBCFFFF), Color.White))
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.jbcxHeaderGradientStart, Colors.white],
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      alignment: Alignment.center,
      child: const Text(
        '旅行规划',
        style: TextStyle(
          color: AppColors.jbcxText,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 单个旅行卡片 - 对齐 Android TravelPlanCard
class _TravelPlanCard extends StatelessWidget {
  const _TravelPlanCard({required this.plan, required this.onClick});

  final TravelPlan plan;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 18),
      child: Container(
        width: double.infinity,
        height: 219,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onClick,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 卡片图片 - 对齐 Android AsyncImage(height=154dp, ContentScale.Crop)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.asset(
                    plan.image,
                    width: double.infinity,
                    height: 154,
                    fit: BoxFit.cover,
                  ),
                ),
                // 标题 + 描述 - 对齐 Android Column(padding=start=24, top=11, end=18)
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 11, right: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 对齐 Android Text(title, color=0xFF515151, fontSize=16sp, fontWeight=Medium, maxLines=1)
                      Text(
                        plan.title,
                        style: const TextStyle(
                          color: Color(0xFF515151),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // 对齐 Android Text(description, color=0xFF898989, fontSize=10sp, maxLines=1, Ellipsis)
                      Text(
                        plan.description,
                        style: const TextStyle(
                          color: Color(0xFF898989),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
