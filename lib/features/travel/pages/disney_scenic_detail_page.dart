// 迪士尼攻略页 - 对齐 Android DisneyShangHaiScenicDetailActivity.kt（348行）
// 含头部图片+返回按钮、乐园介绍、七大主题园区、游玩攻略、总结
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';

/// 迪士尼攻略页 - 对齐 Android DisneyShangHaiScenicDetailActivity
class DisneyScenicDetailPage extends StatelessWidget {
  const DisneyScenicDetailPage({super.key});

  // 颜色常量 - 对齐 Android primaryTextColor / secondaryTextColor / pageBackgroundColor
  static const Color _primaryTextColor = Color(0xFF3D3D3D);
  static const Color _secondaryTextColor = Color(0xFF5B5B5B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 头部图片 + 返回按钮 - 对齐 Android Box { HeaderImage + Image(ic_back) }
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // 头部城堡图片 - 对齐 Android HeaderImage(height=250dp, Crop)
                Image.asset(
                  AppAssets.disneyMenpai,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                // 返回按钮 - 对齐 Android Image(padding=start=15, top=50, clickable=finish)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 50 - 15,
                  left: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(
                        AppAssets.icBackGrayWhite,
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 主要内容区域 - 对齐 Android Column(padding=20dp)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IntroSection(),
                  const SizedBox(height: 22),
                  _ThemeParksSection(),
                  const SizedBox(height: 16),
                  _TravelGuideSection(),
                  const SizedBox(height: 16),
                  _SummarySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 乐园介绍 - 对齐 Android IntroSection
class _IntroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(text: '上海迪士尼乐园：梦幻之旅的终极指南'),
        const SizedBox(height: 10),
        const _SectionTitle(text: '一、乐园介绍'),
        const SizedBox(height: 10),
        // 对齐 Android buildAnnotatedString（粗体"上海迪士尼乐园" + 普通内容）
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '上海迪士尼乐园',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: DisneyScenicDetailPage._primaryTextColor,
                  fontSize: 10,
                ),
              ),
              TextSpan(
                text: '是中国大陆首座迪士尼主题乐园，位于上海市浦东新区川沙新镇，于2016年6月16日正式开园。乐园占地面积约390公顷，拥有七大主题园区：米奇大街、奇想花园、探险岛、宝藏湾、明日世界、梦幻世界和迪士尼·皮克斯玩具总动员主题园区。上海迪士尼乐园融合了迪士尼经典元素和中国文化特色，为游客带来独一无二的沉浸式体验。',
                style: TextStyle(
                  color: DisneyScenicDetailPage._secondaryTextColor,
                  fontSize: 10,
                  height: 14 / 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 七大主题园区亮点 - 对齐 Android ThemeParksSection
class _ThemeParksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(text: '二、七大主题园区亮点'),
        SizedBox(height: 10),
        _InfoBlock(title: '米奇大街:', content: '欢迎来到迪士尼的第一站，这里充满了欢乐的氛围，可以邂逅米奇、米妮等迪士尼朋友，还有各式各样的商店和餐厅。'),
        _InfoBlock(title: '奇想花园:', content: '一个充满想象力和奇迹的花园，适合所有年龄段的游客。推荐项目：小飞象、旋转木马、米奇童话专列（日间花车巡游）。'),
        _InfoBlock(title: '探险岛:', content: '踏上惊险刺激的探险之旅，探索神秘的远古部落。推荐项目：翱翔·飞越地平线（热门项目，建议早领取FP）、雷鸣山漂流（需准备雨衣）。'),
        _InfoBlock(title: '宝藏湾:', content: '加入杰克船长的海盗队伍，开启一场寻宝冒险。推荐项目：加勒比海盗——沉落宝藏之战（沉浸式体验，视觉效果震撼）。'),
        _InfoBlock(title: '明日世界:', content: '充满未来科技感的世界，体验速度与激情。推荐项目：创极速光轮（迪士尼最刺激的项目之一）、巴斯光年星际营救（互动射击游戏）。'),
        _InfoBlock(title: '梦幻世界:', content: '沉浸在经典的迪士尼童话故事中。推荐项目：七个小矮人矿山车（家庭过山车）、奇幻童话城堡（迪士尼地标，夜晚有烟花秀）。'),
        _InfoBlock(title: '迪士尼·皮克斯玩具总动员主题园区:', content: '仿佛置身于《玩具总动员》的电影世界。推荐项目：抱抱龙冲天赛车（U型滑板，失重感强）、弹簧狗团团转（适合亲子）。'),
      ],
    );
  }
}

/// 游玩攻略 - 对齐 Android TravelGuideSection
class _TravelGuideSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(text: '三、游玩攻略'),
        SizedBox(height: 20),
        _GuideImage(image: AppAssets.disneyLeyuan, description: '迪士尼朋友们'),
        SizedBox(height: 20),
        _GuideListBlock(title: '行前准备:', items: [
          '下载"上海迪士尼度假区"APP，查看地图、排队时间、领取FP（快速通行证）。',
          '购买门票：可通过官网、官方APP或各大旅游平台购买，建议提前购票，尤其是节假日。',
          '住宿：可选择迪士尼乐园酒店或玩具总动员酒店，享受提前入园等特权，也可选择周边酒店。',
          '交通：地铁11号线迪士尼站直达，或乘坐公交车、出租车等。',
        ]),
        SizedBox(height: 8),
        _GuideListBlock(title: '入园须知:', items: [
          '安检：禁止携带自拍杆、大型三脚架、玻璃容器等物品。',
          '入园时间：官方公布时间为上午8:30，但实际会提前开放，建议早到排队。',
          '领取FP：通过APP扫描门票二维码领取，每2小时可领取一次，数量有限。',
        ]),
        SizedBox(height: 10),
        _GuideListBlock(title: '游玩路线推荐:', items: [
          '方案一（刺激爱好者）：创极速光轮 → 抱抱龙冲天赛车 → 七个小矮人矿山车 → 雷鸣山漂流 → 加勒比海盗——沉落宝藏之战 → 翱翔·飞越地平线。',
          '方案二（亲子游）：小飞象 → 旋转木马 → 巴斯光年星际营救 → 小熊维尼历险记 → 七个小矮人矿山车 → 米奇童话专列。',
        ]),
        SizedBox(height: 10),
        _GuideListBlock(title: '餐饮推荐:', items: [
          '乐园内有多家餐厅，提供中式、西式等各类美食，价格略高。',
          '推荐尝试：火鸡腿、米奇头披萨、迪士尼造型冰淇淋。',
          '可自带未开封的零食和饮料。',
        ]),
        SizedBox(height: 20),
        _GuideImage(image: AppAssets.disneyFood, description: '迪士尼美食'),
        SizedBox(height: 20),
        _GuideListBlock(title: '购物推荐:', items: [
          '乐园内有多家商店，出售迪士尼周边商品，如玩偶、服饰、文具等。',
          '推荐购买：达菲和朋友系列、星黛露、玲娜贝儿等热门角色商品。',
        ]),
        SizedBox(height: 14),
        _GuideListBlock(title: '其他tips:', items: [
          '穿着舒适的鞋子和衣服，做好防晒措施。',
          '可自带充电宝，乐园内也有租借。',
          '观看烟花秀需提前占位，建议提前1-2小时。',
          '保持耐心和愉快的心情，享受迪士尼的魔法之旅！',
        ]),
      ],
    );
  }
}

/// 总结 - 对齐 Android SummarySection
class _SummarySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(text: '四、总结'),
        SizedBox(height: 10),
        Text(
          '上海迪士尼乐园是一个充满欢乐和魔法的地方，无论你是大人还是小孩，都能在这里找到属于自己的乐趣。希望这份攻略能帮助你规划一次完美的迪士尼之旅！祝你拥有一个难忘的梦幻假期！',
          style: TextStyle(
            color: DisneyScenicDetailPage._primaryTextColor,
            fontSize: 10,
            height: 18 / 10,
          ),
        ),
      ],
    );
  }
}

/// 大标题 - 对齐 Android SectionTitle
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: DisneyScenicDetailPage._primaryTextColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
      ),
    );
  }
}

/// 信息块 - 对齐 Android InfoBlock（粗体标题 + 普通内容）
class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: DisneyScenicDetailPage._primaryTextColor,
                fontSize: 10,
              ),
            ),
            TextSpan(
              text: ' $content',
              style: const TextStyle(
                color: DisneyScenicDetailPage._secondaryTextColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}

/// 攻略列表块 - 对齐 Android GuideListBlock
class _GuideListBlock extends StatelessWidget {
  const _GuideListBlock({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: DisneyScenicDetailPage._primaryTextColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 18 / 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          items.map((item) => '- $item').join('\n'),
          style: const TextStyle(
            color: DisneyScenicDetailPage._secondaryTextColor,
            fontSize: 10,
            height: 18 / 10,
          ),
        ),
      ],
    );
  }
}

/// 攻略图片 - 对齐 Android GuideImage（圆角 182dp 高）
class _GuideImage extends StatelessWidget {
  const _GuideImage({required this.image, required this.description});
  final String image;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        image,
        width: double.infinity,
        height: 182,
        fit: BoxFit.cover,
      ),
    );
  }
}
