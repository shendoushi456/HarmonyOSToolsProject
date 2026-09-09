// 乐山峨眉攻略页 - 对齐 Android LeShanScenicDetailActivity.kt（446行）
// 含头部图+返回、简介、游玩攻略（乐山大佛+峨眉山）、美食、住宿、最佳时间、注意事项、总结
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';

/// 乐山峨眉攻略页 - 对齐 Android LeShanScenicDetailActivity
class LeShanScenicDetailPage extends StatelessWidget {
  const LeShanScenicDetailPage({super.key});

  // 颜色常量 - 对齐 Android pageBackgroundColor / primaryTextColor / secondaryTextColor
  static const Color _pageBg = Color(0xFFF7FBFE);
  static const Color _primaryText = Color(0xFF3D3D3D);
  static const Color _secondaryText = Color(0xFF5B5B5B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: CustomScrollView(
        slivers: [
          // 头部图片 + 返回按钮 - 对齐 Android HeaderSection
          SliverToBoxAdapter(child: _HeaderSection()),
          // 内容区域 - 对齐 Android Column(padding=horizontal 20dp)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IntroSection(),
                  const SizedBox(height: 20),
                  _PlayGuideSection(),
                  const SizedBox(height: 20),
                  _FoodSection(),
                  const SizedBox(height: 20),
                  _AccommodationSection(),
                  const SizedBox(height: 10),
                  _BestTimeSection(),
                  const SizedBox(height: 10),
                  _NotesSection(),
                  const SizedBox(height: 18),
                  _SummarySection(),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

/// 头部区域 - 对齐 Android HeaderSection（200dp 高图片 + 返回按钮）
class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          Image.asset(
            AppAssets.leshanHead,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          // 返回按钮 - 对齐 Android IconButton(padding=16dp)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
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
    );
  }
}

/// 简介 - 对齐 Android IntroSection
class _IntroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          '乐山 & 峨眉山:佛国仙山，人间胜境',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '位于四川省西南部，相距约30公里，是四川省著名的旅游胜地，拥有世界文化与自然双重遗产的殊荣。乐山以雄伟的大佛闻名，峨眉山则以秀丽的自然风光和悠久的佛教文化著称，两者相辅相成共同构成了四川旅游的黄金线路。',
          style: TextStyle(
            color: LeShanScenicDetailPage._secondaryText,
            fontSize: 10,
            height: 14 / 10,
          ),
        ),
        SizedBox(height: 20),
        Text(
          '一、乐山 & 峨眉山简介',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10),
        _InfoParagraph(
          title: '乐山市:',
          content: '古称嘉州，是一座拥有悠久历史和文化的城市。乐山大佛是世界上最大的石刻弥勒佛坐像，通高71米，开凿于唐代，历时90年完成，堪称人类艺术的瑰宝。',
        ),
        SizedBox(height: 14),
        _InfoParagraph(
          title: '峨眉山:',
          content: '中国四大佛教名山之一，普贤菩萨的道场。峨眉山以其秀丽的自然风光和丰富的动植物资源闻名，素有"峨眉天下秀"之称。主峰金顶海拔3079米，登顶可观赏云海、日出、佛光等奇观。',
        ),
      ],
    );
  }
}

/// 游玩攻略 - 对齐 Android PlayGuideSection
class _PlayGuideSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '二、游玩攻略',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 16),
        // --- 1. 乐山大佛 ---
        Text(
          '1.乐山大佛',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 22),
        _GuideImage(image: AppAssets.leshanDafo, description: '乐山大佛'),
        SizedBox(height: 20),
        _InfoParagraph(title: '交通:', content: ' 从成都乘坐高铁或汽车约1.5小时可到达乐山。乐山市内可乘坐公交车或出租车前往乐山大佛景区。'),
        SizedBox(height: 12),
        _InfoParagraph(title: '门票:', content: ' 80元/人'),
        SizedBox(height: 16),
        Text(
          '游玩路线',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        _RouteItem(title: '麻浩崖墓:', content: '位于大佛左侧，是汉代崖墓群，具有重要的考古价值。'),
        _RouteItem(title: '九曲栈道:', content: '沿着栈道下行，可以近距离观赏大佛的雄伟壮观。'),
        _RouteItem(title: '凌云寺:', content: '位于大佛右侧，是一座历史悠久的佛教寺庙。'),
        _RouteItem(title: '乌尤寺:', content: '位于大佛对面，可以乘坐游船前往，从江面上欣赏大佛全景。'),
        SizedBox(height: 10),
        _TipsSection(tips: [
          '建议早上前往，避开人流高峰。',
          '九曲栈道较为陡峭，注意安全。',
          '可以乘坐游船从江面上欣赏大佛全景。',
        ]),
        SizedBox(height: 14),
        // --- 2. 峨眉山 ---
        Text(
          '2.峨眉山',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 22),
        _GuideImage(image: AppAssets.emeishan, description: ''),
        SizedBox(height: 6),
        _InfoParagraph(title: '交通:', content: '从乐山乘坐汽车约1小时可到达峨眉山。峨眉山市内可乘坐公交车或出租车前往峨眉山景区。'),
        _InfoParagraph(title: '门票:', content: '160元/人(旺季)，110元/人(淡季)'),
        SizedBox(height: 14),
        Text(
          '游玩路线',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        _RouteItem(title: '报国寺:', content: '峨眉山第一大寺，是登山起点。'),
        _RouteItem(title: '伏虎寺:', content: '寺内供奉着普贤菩萨的坐骑六牙白象。'),
        _RouteItem(title: '清音阁:', content: '位于牛心岭下，是观赏峨眉山十景之一"双桥清音"的最佳地点。'),
        _RouteItem(title: '万年寺:', content: '寺内供奉着普贤菩萨的铜像。'),
        _RouteItem(title: '洗象池:', content: '传说普贤菩萨在此洗象。'),
        _RouteItem(title: '金顶:', content: '峨眉山主峰，海拔3079米，可观赏云海、日出、佛光等奇观。'),
        SizedBox(height: 14),
        _TipsSection(tips: [
          '峨眉山面积较大，建议安排2-3天时间游玩。',
          '可以选择徒步登山或乘坐缆车。',
          '山上气候多变，注意防寒保暖。',
          '注意防范猴子抢夺食物。',
        ]),
      ],
    );
  }
}

/// 美食推荐 - 对齐 Android FoodSection
class _FoodSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3.乐山 & 峨眉山美食',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        _InfoParagraph(title: '乐山:', content: '跷脚牛肉、甜皮鸭、钵钵鸡、豆腐脑、西坝豆腐。'),
        _InfoParagraph(title: '峨眉山:', content: '峨眉山豆腐、雪魔芋烧鸭、峨眉山腊肉、叶儿粑。'),
        SizedBox(height: 22),
        _GuideImage(image: AppAssets.sichuanChuanchuan, description: '乐山美食钵钵鸡'),
      ],
    );
  }
}

/// 住宿推荐 - 对齐 Android AccommodationSection
class _AccommodationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '4.住宿推荐',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        _InfoParagraph(title: '乐山:', content: '乐山金海棠大酒店、乐山盘龙开元名都大酒店。'),
        _InfoParagraph(title: '峨眉山:', content: '峨眉山温泉饭店、峨眉山红珠山宾馆。'),
      ],
    );
  }
}

/// 最佳旅游时间 - 对齐 Android BestTimeSection
class _BestTimeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '5.最佳旅游时间',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '春秋两季(3-5月，9-11月)是乐山和峨眉山的最佳旅游时间，气候宜人，景色优美。',
          style: TextStyle(
            color: LeShanScenicDetailPage._secondaryText,
            fontSize: 10,
            height: 18 / 10,
          ),
        ),
      ],
    );
  }
}

/// 注意事项 - 对齐 Android NotesSection
class _NotesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '6.注意事项',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '乐山和峨眉山是佛教圣地，请注意言行举止，尊重佛教文化。\n景区内注意保护环境，不要乱扔垃圾。\n注意安全，特别是在登山过程中。',
          style: TextStyle(
            color: LeShanScenicDetailPage._secondaryText,
            fontSize: 10,
            height: 18 / 10,
          ),
        ),
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
        Text(
          '三、总结',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '乐山和峨眉山是四川旅游的必去之地，拥有丰富的自然和人文景观。无论是瞻仰乐山大佛的雄伟，还是领略峨眉山的秀丽，都能让人感受到大自然的神奇和人类文明的伟大。希望这篇攻略能够帮助你规划一次愉快的乐山峨眉山之旅!',
          style: TextStyle(
            color: LeShanScenicDetailPage._secondaryText,
            fontSize: 10,
            height: 14 / 10,
          ),
        ),
      ],
    );
  }
}

/// 信息段落 - 对齐 Android InfoParagraph（粗体标题 + 普通内容）
class _InfoParagraph extends StatelessWidget {
  const _InfoParagraph({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: LeShanScenicDetailPage._primaryText,
              fontSize: 10,
            ),
          ),
          TextSpan(
            text: content,
            style: const TextStyle(
              color: LeShanScenicDetailPage._secondaryText,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// 路线条目 - 对齐 Android RouteItem（下划线粗体标题 + 普通内容）
class _RouteItem extends StatelessWidget {
  const _RouteItem({required this.title, required this.content});
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
                color: LeShanScenicDetailPage._primaryText,
                fontSize: 10,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: ' $content',
              style: const TextStyle(
                color: LeShanScenicDetailPage._secondaryText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 小贴士 - 对齐 Android TipsSection
class _TipsSection extends StatelessWidget {
  const _TipsSection({required this.tips});
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tips:',
          style: TextStyle(
            color: LeShanScenicDetailPage._primaryText,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tips.join('\n'),
          style: const TextStyle(
            color: LeShanScenicDetailPage._secondaryText,
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
