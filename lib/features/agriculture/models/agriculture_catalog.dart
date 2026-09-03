// 农业作物类别与灾害指南。UI 层只依赖此目录，便于后续替换整套马甲 UI。
import '../../../core/constants/app_assets.dart';
import 'agriculture_models.dart';

const agricultureCategories = <CropCategory>[
  CropCategory(
    id: 'grain',
    title: '粮食作物',
    selectionText: '粮食作物（小麦、水稻、玉米、大豆）',
    inputHint: '请输入你的粮食',
    iconAsset: AppAssets.agricultureZyytCategoryGrain,
    guides: [
      DisasterGuide(
          title: '干热风',
          danger: '严重影响小麦灌浆，造成籽粒干瘪减产',
          prevention: '及时灌溉补水，喷施叶面肥；疏通通风渠降低田间温度。',
          color: 0xFFFF9145,
          aliases: ['干热风'],
          eventCodes: {'1011', '1089'}),
      DisasterGuide(
          title: '干旱',
          danger: '全品类粮食缺水枯死、无法播种',
          prevention: '铺设滴灌或喷灌，地膜覆盖保墒，浅耕松土。',
          color: 0xFF9A3F00,
          aliases: ['干旱'],
          eventCodes: {'1022', '1078', '1215', '1217'}),
      DisasterGuide(
          title: '暴雨',
          danger: '水田淹苗、玉米大豆烂根倒伏',
          prevention: '提前开挖排水沟，雨后及时排涝并防病。',
          color: 0xFF3674A8,
          aliases: ['暴雨', '强降雨'],
          eventCodes: {'1003', '1038', '1049', '1063', '1064'}),
    ],
  ),
  CropCategory(
    id: 'fruit_vegetable',
    title: '果蔬作物',
    selectionText: '果蔬经济作物（果树、露天蔬菜、瓜果）',
    inputHint: '请输入你的果蔬作物',
    iconAsset: AppAssets.agricultureZyytCategoryProduce,
    guides: [
      DisasterGuide(
          title: '霜冻',
          danger: '冻伤果树花芽、蔬菜幼苗',
          prevention: '果树熏烟防冻，蔬菜搭小拱棚，喷施磷酸二氢钾。',
          color: 0xFF39AEE2,
          aliases: ['霜冻', '低温冻害'],
          eventCodes: {'1008', '1016', '1027'}),
      DisasterGuide(
          title: '强降雨',
          danger: '菜地积水烂根、瓜果裂果',
          prevention: '高垄栽培、深挖排水沟，瓜果果实套袋。',
          color: 0xFF087BFF,
          aliases: ['强降雨', '暴雨'],
          eventCodes: {'1003', '1038'}),
      DisasterGuide(
          title: '大风',
          danger: '果树落果、大棚蔬菜棚体损毁',
          prevention: '果树拉枝固定、加固支架，及时疏果降低枝条负重。',
          color: 0xFFF2CA00,
          aliases: ['大风', '台风'],
          eventCodes: {'1001', '1006', '1020'}),
    ],
  ),
  CropCategory(
    id: 'greenhouse',
    title: '大棚作物',
    selectionText: '大棚设施农业（大棚蔬菜、花卉、育苗）',
    inputHint: '请输入你的大棚作物',
    iconAsset: AppAssets.agricultureZyytCategoryGreenhouse,
    guides: [
      DisasterGuide(
          title: '暴雪',
          danger: '积雪压塌大棚骨架',
          prevention: '持续清扫棚顶积雪，加固钢架并增加支撑。',
          color: 0xFF093975,
          aliases: ['暴雪', '大雪'],
          eventCodes: {'1004', '1033', '1040'}),
      DisasterGuide(
          title: '大风',
          danger: '掀翻棚膜、损毁温室',
          prevention: '压紧棚膜压膜线，关闭通风口并加固棚门。',
          color: 0xFFF2CA00,
          aliases: ['大风', '台风'],
          eventCodes: {'1001', '1006', '1020'}),
      DisasterGuide(
          title: '持续低温',
          danger: '棚内低温冻坏幼苗',
          prevention: '开启增温设备，棚内加盖二层保温膜。',
          color: 0xFF4D8DA4,
          aliases: ['低温', '寒潮', '霜冻'],
          eventCodes: {'1005', '1034'}),
    ],
  ),
  CropCategory(
    id: 'forest',
    title: '林木作物',
    selectionText: '林果林木（果树、苗木、山林经济作物）',
    inputHint: '请输入林木作物',
    iconAsset: AppAssets.agricultureZyytCategoryForest,
    guides: [
      DisasterGuide(
          title: '森林火险',
          danger: '高温干旱大风引发山火，烧毁林木',
          prevention: '清理枯枝杂草，禁止明火，高风险时段巡山。',
          color: 0xFFFF4307,
          aliases: ['森林火险', '草原火险', '山火'],
          eventCodes: {'1025', '1026', '1041', '1077'}),
      DisasterGuide(
          title: '低温冻害',
          danger: '果树花芽冻伤',
          prevention: '花期果园熏烟、树干涂白，寒潮前全园灌水。',
          color: 0xFF727CEB,
          aliases: ['低温冻害', '寒潮'],
          eventCodes: {'1005', '1034'}),
      DisasterGuide(
          title: '干旱',
          danger: '苗木枯死、果树减产',
          prevention: '树盘覆盖秸秆保水，定期滴灌补水。',
          color: 0xFF9A3F00,
          aliases: ['干旱'],
          eventCodes: {'1022', '1078'}),
    ],
  ),
  CropCategory(
    id: 'oil_field',
    title: '油料作物',
    selectionText: '油料 / 经济大田作物（花生、油菜、棉花）',
    inputHint: '请输入你的油料作物',
    iconAsset: AppAssets.agricultureZyytCategoryOil,
    guides: [
      DisasterGuide(
          title: '干旱',
          danger: '结荚、结桃受阻，产量下降',
          prevention: '滴灌补水，覆盖保墒，适时补充水溶肥。',
          color: 0xFF9A3F00,
          aliases: ['干旱'],
          eventCodes: {'1022', '1078'}),
      DisasterGuide(
          title: '冰雹',
          danger: '枝叶、棉桃损毁',
          prevention: '搭建防雹网，灾后追肥促进恢复。',
          color: 0xFF1B2CD3,
          aliases: ['冰雹'],
          eventCodes: {'1015'}),
      DisasterGuide(
          title: '低温冻害',
          danger: '油菜越冬冻伤',
          prevention: '越冬前培土护根，寒潮来临前田间灌水保温。',
          color: 0xFF727CEB,
          aliases: ['低温冻害', '寒潮'],
          eventCodes: {'1005', '1034'}),
    ],
  ),
];

CropCategory agricultureCategoryForId(String id) =>
    agricultureCategories.firstWhere((category) => category.id == id,
        orElse: () => agricultureCategories.first);
