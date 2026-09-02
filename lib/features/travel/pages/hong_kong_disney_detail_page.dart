// 香港迪士尼攻略 - 对齐 Android DisneyHongKongDetailActivity。
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';

class HongKongDisneyDetailPage extends StatelessWidget {
  const HongKongDisneyDetailPage({super.key});

  static const _primary = Color(0xFF3D3D3D);
  static const _secondary = Color(0xFF5B5B5B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Image.asset(
                  AppAssets.toolboxHongKongDisneyGate,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 35,
                  left: 15,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      AppAssets.toolboxHongKongDisneyBack,
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GuideTitle('香港迪士尼乐园：梦幻王国全攻略'),
                  SizedBox(height: 10),
                  _GuideTitle('一、乐园简介'),
                  SizedBox(height: 10),
                  _IntroText(),
                  SizedBox(height: 20),
                  _GuideImage(
                    asset: AppAssets.toolboxHongKongDisneyPark,
                    label: 'Arendelle城堡',
                  ),
                  SizedBox(height: 20),
                  _GuideTitle('二、七大主题乐园'),
                  SizedBox(height: 6),
                  _NumberedItems([
                    '美国小镇大街: 复古风情主街，适合拍照购物，邂逅迪士尼朋友。',
                    '探险世界: 丛林河流之旅，体验泰森树屋和原野剧场《狮子王庆典》。',
                    '幻想世界: 经典童话世界，包含小小世界、灰姑娘旋转木马等设施。',
                    '明日世界: 未来科技感十足，必玩星战极速穿梭和铁甲奇侠飞行之旅。',
                    '反斗奇兵大本营: 玩具总动员主题，适合家庭游玩。',
                    '迷离庄园: 独家神秘探险，探索亨利爵士的珍奇藏品。',
                    '灰熊山谷: 西部矿车主题过山车，刺激与乐趣并存。',
                  ]),
                  SizedBox(height: 16),
                  _GuideTitle('三、游玩攻略'),
                  SizedBox(height: 6),
                  _GuideBlock(
                    title: '1. 行前准备',
                    items: [
                      '官网购票（可享优惠）',
                      '下载官方APP（查看地图、排队时间）',
                      '准备防晒用品、舒适鞋服',
                      '可带未开封食物入园'
                    ],
                  ),
                  SizedBox(height: 10),
                  _GuideBlock(
                    title: '2. 交通方式',
                    items: ['地铁迪士尼线直达', '酒店接驳巴士', '自驾（收费停车场）'],
                  ),
                  SizedBox(height: 10),
                  _GuideBlock(
                    title: '3. 必玩项目推荐',
                    items: [
                      '灰熊山极速矿车（刺激过山车）',
                      '星战极速穿梭（室内黑暗过山车）',
                      '迷离庄园（独家特色项目）',
                      '米奇幻想曲（4D音乐短片）',
                      '迪士尼魔法书房（舞台表演）'
                    ],
                  ),
                  SizedBox(height: 10),
                  _GuideBlock(
                    title: '4. 餐饮建议',
                    items: ['提前购买餐券', '推荐皇室宴会厅（中西式套餐）', '小食推荐：米奇华夫饼、迪士尼造型冰淇淋'],
                  ),
                  SizedBox(height: 20),
                  _GuideImage(
                    asset: AppAssets.toolboxHongKongDisneyFood,
                    label: '米奇华夫饼',
                  ),
                  SizedBox(height: 20),
                  _GuideBlock(
                    title: '5. 住宿推荐',
                    items: ['迪士尼乐园酒店（欧式风格）', '好莱坞酒店（美式风情）', '探索家度假酒店（探险主题）'],
                  ),
                  SizedBox(height: 16),
                  _GuideTitle('四、实用贴士'),
                  SizedBox(height: 6),
                  _NumberedItems([
                    '开园时间: 10:30-20:30（每日不同，建议查询官网）',
                    '快速通行: 部分项目可使用“迪士尼尊享卡”',
                    '最佳拍照点: 城堡前、幻想世界花园、美国小镇大街',
                    '巡游时间: 下午和晚上各一场（具体时间以当日为准）',
                    '烟花表演: 通常20:30开始（天气允许情况下）',
                  ]),
                  SizedBox(height: 16),
                  _GuideTitle('五、特别体验'),
                  SizedBox(height: 6),
                  _BodyText(
                      '1. 与迪士尼朋友见面（提前查看APP获取见面时间）\n2. 购买独家迪士尼纪念品\n3. 生日游客可领取特别徽章\n4. 酒店住客可享提前入园特权'),
                  SizedBox(height: 16),
                  _BodyText(
                      '香港迪士尼乐园虽面积不大，但精致紧凑，适合1-2日游玩。无论是亲子家庭、情侣还是朋友结伴，都能在这里找到属于自己的魔法时刻。提前规划行程，合理安排时间，能让您的迪士尼之旅更加完美！'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideTitle extends StatelessWidget {
  const _GuideTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: HongKongDisneyDetailPage._primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
        ),
      );
}

class _IntroText extends StatelessWidget {
  const _IntroText();

  @override
  Widget build(BuildContext context) => RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '香港迪士尼乐园',
              style: TextStyle(
                color: HongKongDisneyDetailPage._primary,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            TextSpan(
              text:
                  '是全球第五座、中国第一座迪士尼乐园，于2005年9月12日开幕。乐园秉承迪士尼经典魔法与传统文化，融合香港特色，打造七大主题园区，为游客带来沉浸式童话体验。',
              style: TextStyle(
                color: HongKongDisneyDetailPage._secondary,
                fontSize: 10,
                height: 14 / 10,
              ),
            ),
          ],
        ),
      );
}

class _GuideImage extends StatelessWidget {
  const _GuideImage({required this.asset, required this.label});
  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(asset,
            width: double.infinity,
            height: 182,
            fit: BoxFit.cover,
            semanticLabel: label),
      );
}

class _NumberedItems extends StatelessWidget {
  const _NumberedItems(this.items);
  final List<String> items;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < items.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _BodyText('${index + 1}. ${items[index]}'),
            ),
        ],
      );
}

class _GuideBlock extends StatelessWidget {
  const _GuideBlock({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: HongKongDisneyDetailPage._primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 18 / 10)),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _BodyText('- $item'),
            ),
        ],
      );
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: HongKongDisneyDetailPage._secondary,
          fontSize: 10,
          height: 18 / 10,
        ),
      );
}
