// 农业作物类别与灾害指南 - 1:1 对齐 Android CropModels.kt（含全部事件码/别名/文案）。
// UI 层只依赖此目录，便于后续替换整套马甲 UI。
import '../../../core/constants/app_assets.dart';
import 'agriculture_models.dart';

/// 和风天气预警事件码分组 - 对齐 Android WarningEventCodes
const _dryHotWind = {'1011', '1089'};
const _drought = {'1022', '1078', '1215', '1217'};
const _heavyRain = {'1003', '1038', '1049', '1063', '1064'};
const _highTemperature = {'1009', '1010', '1024', '1066'};
const _hail = {'1015'};
const _coldDamage = {
  '1005', '1008', '1016', '1027', '1030', '1034', '1039',
  '1048', '1050', '1056', '1059', '1086', '1087',
};
const _tornado = {'1002'};
const _frost = {'1008', '1016', '1027', '1030', '1056', '1086', '1087'};
const _gale = {'1001', '1006', '1020', '1058', '1085'};
const _coldWave = {'1005', '1034', '1039', '1048', '1050'};
const _snowStorm = {'1004', '1033', '1040'};
const _forestFire = {'1025', '1026', '1041', '1077', '1084'};
const _sandDust = {'1007', '1047', '1051', '1061'};
const _heavyFog = {'1017'};

const agricultureCategories = <CropCategory>[
  CropCategory(
    id: 'grain',
    title: '粮食作物',
    selectionText: '粮食作物（小麦、水稻、玉米、大豆）',
    inputHint: '请输入你的粮食',
    iconAsset: AppAssets.agricultureCategoryGrain,
    guides: [
      DisasterGuide(
          title: '干热风',
          danger: '仅严重影响小麦灌浆，造成籽粒干瘪减产',
          prevention: '田间及时灌溉补水，喷施叶面肥；麦田提前疏通通风渠，降低田间温度。',
          color: 0xFFFF9145,
          eventCodes: _dryHotWind),
      DisasterGuide(
          title: '干旱',
          danger: '全品类粮食缺水枯死、无法播种',
          prevention: '铺设滴灌 / 喷灌设施，地膜覆盖保墒；缺水地块浅耕松土，减少土壤水分蒸发。',
          color: 0xFF9A3F00,
          eventCodes: _drought),
      DisasterGuide(
          title: '暴雨',
          danger: '水田淹苗、玉米大豆烂根倒伏',
          prevention: '提前开挖田间排水沟；低洼地块起高垄种植；雨后及时排涝，喷施防病药剂',
          color: 0xFF3674A8,
          aliases: ['暴雨', '强降雨', '强降水'],
          eventCodes: _heavyRain),
      DisasterGuide(
          title: '高温',
          danger: '水稻扬花授粉失败、玉米秃尖',
          prevention: '水稻花期清晨灌水降温；玉米行间喷水增湿，避开正午高温灌溉。',
          color: 0xFFE43D0D,
          aliases: ['高温', '热浪', '高温中暑', '中暑气象条件'],
          eventCodes: _highTemperature),
      DisasterGuide(
          title: '冰雹',
          danger: '砸毁茎叶、绝收',
          prevention: '提前布设防雹网；关注气象预警，雹灾前田间灌水缓冲冲击；灾后及时清理残枝，追肥促新叶。',
          color: 0xFF1B2CD3,
          eventCodes: _hail),
      DisasterGuide(
          title: '低温冻伤',
          danger: '春玉米烂种、晚稻寒露风减产',
          prevention: '春播覆盖地膜保温；晚稻寒露风来临前灌深水护穗，喷施抗寒叶面肥。',
          color: 0xFF4F94C3,
          aliases: ['低温', '冻害', '冻伤', '霜冻', '寒潮', '寒露风', '冰冻', '强降温', '降温', '严寒', '寒冷'],
          eventCodes: _coldDamage),
      DisasterGuide(
          title: '龙卷风',
          danger: '玉米、水稻大面积倒伏',
          prevention: '玉米苗期控旺壮秆；水稻灌浆期加固田埂；大风过后及时扶正倒伏作物，少量追肥恢复长势。',
          color: 0xFFC47C00,
          eventCodes: _tornado),
    ],
  ),
  CropCategory(
    id: 'fruit_vegetable',
    title: '果蔬作物',
    selectionText: '果蔬经济作物（果树、露天蔬菜、瓜果）',
    inputHint: '请输入你的果蔬作物',
    iconAsset: AppAssets.agricultureCategoryFruitVegetable,
    guides: [
      DisasterGuide(
          title: '霜冻',
          danger: '冻伤果树花芽、蔬菜幼苗，直接绝收',
          prevention: '果树夜间熏烟防冻；蔬菜搭建简易小拱棚；喷施磷酸二氢钾提升抗寒能力。',
          color: 0xFF39AEE2,
          aliases: ['霜冻', '低温冻害', '低温冻伤', '冰冻', '低温雨雪冰冻', '低温凝冻', '低温冷害'],
          eventCodes: _frost),
      DisasterGuide(
          title: '强降雨',
          danger: '菜地积水烂根、瓜果裂果',
          prevention: '菜地高垄栽培，深挖排水沟；瓜果果实套袋，减少雨水冲刷裂果。',
          color: 0xFF087BFF,
          aliases: ['强降雨', '暴雨', '强降水'],
          eventCodes: _heavyRain),
      DisasterGuide(
          title: '高温',
          danger: '水稻扬花授粉失败、玉米秃尖',
          prevention: '水稻花期清晨灌水降温；玉米行间喷水增湿，避开正午高温灌溉。',
          color: 0xFFE43D0D,
          aliases: ['高温', '热浪', '高温中暑', '中暑气象条件'],
          eventCodes: _highTemperature),
      DisasterGuide(
          title: '冰雹',
          danger: '砸毁茎叶、绝收',
          prevention: '提前布设防雹网；关注气象预警，雹灾前田间灌水缓冲冲击；灾后及时清理残枝，追肥促新叶。',
          color: 0xFF1B2CD3,
          eventCodes: _hail),
      DisasterGuide(
          title: '大风',
          danger: '果树落果、大棚蔬菜棚体损毁',
          prevention: '果树拉枝固定、加固支架；蔬果及时疏果，降低枝条负重。',
          color: 0xFFF2CA00,
          aliases: ['大风', '台风', '强风', '雷雨大风', '雷暴大风', '雷雨强风'],
          eventCodes: _gale),
      DisasterGuide(
          title: '寒潮',
          danger: '越冬蔬菜冻死',
          prevention: '蔬菜加盖保温膜、秸秆覆盖；雨雪天气前搭建防风保温棚。',
          color: 0xFF7A00C7,
          aliases: ['寒潮', '强降温', '降温', '寒冷', '严寒'],
          eventCodes: _coldWave),
    ],
  ),
  CropCategory(
    id: 'greenhouse',
    title: '大棚作物',
    selectionText: '大棚设施农业（大棚蔬菜、花卉、育苗）',
    inputHint: '请输入你的大棚作物',
    iconAsset: AppAssets.agricultureCategoryGreenhouse,
    guides: [
      DisasterGuide(
          title: '暴雪',
          danger: '积雪压塌大棚骨架',
          prevention: '降雪期间持续清扫棚顶积雪；加固大棚钢架，增加支撑立柱。',
          color: 0xFF093975,
          aliases: ['暴雪', '大雪', '雪灾'],
          eventCodes: _snowStorm),
      DisasterGuide(
          title: '大风',
          danger: '掀翻棚膜、损毁温室',
          prevention: '压紧棚膜压膜线；大风来临前关闭通风口，加固棚门。',
          color: 0xFFF2CA00,
          aliases: ['大风', '台风', '强风', '雷雨大风', '雷暴大风', '雷雨强风'],
          eventCodes: _gale),
      DisasterGuide(
          title: '持续低温',
          danger: '棚内低温冻坏幼苗',
          prevention: '开启大棚增温设备；棚内加盖二层保温膜，夜间保温。',
          color: 0xFF4D8DA4,
          aliases: ['持续低温', '低温', '寒潮', '霜冻', '冻害', '冰冻', '强降温', '降温', '严寒', '寒冷'],
          eventCodes: _coldDamage),
      DisasterGuide(
          title: '暴雨',
          danger: '棚区积水倒灌、土壤过湿烂苗',
          prevention: '大棚外围开挖排水渠；棚内垫高育苗畦，雨后及时通风散湿。',
          color: 0xFF09BFE8,
          aliases: ['暴雨', '强降雨', '强降水'],
          eventCodes: _heavyRain),
    ],
  ),
  CropCategory(
    id: 'forest',
    title: '林木作物',
    selectionText: '林果林木（果树、苗木、山林经济作物）',
    inputHint: '请输入林木作物',
    iconAsset: AppAssets.agricultureCategoryForest,
    guides: [
      DisasterGuide(
          title: '森林（草原）火险',
          danger: '高温干旱大风引发山火，烧毁林木',
          prevention: '林区清理枯枝杂草，禁止明火；火险高等级时段安排人员巡山。',
          color: 0xFFFF4307,
          aliases: ['森林火险', '草原火险', '森林（草原）火险', '森林火险气象风险', '森林（草原）火灾气象风险', '草原火灾', '山火'],
          eventCodes: _forestFire),
      DisasterGuide(
          title: '低温冻害',
          danger: '果树花芽冻伤',
          prevention: '花期果园熏烟、树干涂白；寒潮前全园灌水保温。',
          color: 0xFF727CEB,
          aliases: ['低温冻害', '低温', '冻害', '霜冻', '寒潮', '冰冻', '强降温', '降温', '严寒', '寒冷'],
          eventCodes: _coldDamage),
      DisasterGuide(
          title: '龙卷风',
          danger: '树木折断、落果',
          prevention: '幼树捆绑固定；老旧果树提前修剪疏枝，降低风阻。',
          color: 0xFFC57C00,
          eventCodes: _tornado),
      DisasterGuide(
          title: '干旱',
          danger: '苗木枯死、果树减产',
          prevention: '树盘覆盖秸秆保水；定期滴灌补水，搭配抗旱水溶肥。',
          color: 0xFF9A3F00,
          eventCodes: _drought),
      DisasterGuide(
          title: '沙尘',
          danger: '叶片蒙尘，光合减弱',
          prevention: '定期喷淋清水冲洗树叶；林地外围种植防风灌木。',
          color: 0xFF9E9900,
          aliases: ['沙尘', '沙尘暴', '春季沙尘天气', '浮尘', '浓浮尘', '扬尘'],
          eventCodes: _sandDust),
      DisasterGuide(
          title: '高温',
          danger: '树干灼伤、果实日灼',
          prevention: '树干涂白防晒；果树行间种草降温保湿。',
          color: 0xFFE43D0D,
          aliases: ['高温', '热浪', '高温中暑', '中暑气象条件'],
          eventCodes: _highTemperature),
    ],
  ),
  CropCategory(
    id: 'oil_field',
    title: '油料作物',
    selectionText: '油料 / 经济大田作物（花生、油菜、棉花）',
    inputHint: '请输入油料作物',
    iconAsset: AppAssets.agricultureCategoryOil,
    guides: [
      DisasterGuide(
          title: '干旱',
          danger: '结荚、结桃受阻，产量暴跌',
          prevention: '结荚、结桃受阻，产量暴跌',
          color: 0xFF9A3F00,
          eventCodes: _drought,
          // 保真：Android 误配 preventionLabel="危害："
          preventionLabel: '危害：'),
      DisasterGuide(
          title: '暴雨',
          danger: '根系腐烂',
          // 保真：Android 复制了霜冻指南的预防措施文案
          prevention: '花期果园熏烟、树干涂白；寒潮前全园灌水保温。',
          color: 0xFF09BFE8,
          aliases: ['暴雨', '强降雨', '强降水'],
          eventCodes: _heavyRain),
      DisasterGuide(
          title: '冰雹',
          danger: '枝叶、棉桃损毁',
          prevention: '搭建简易防雹网；灾后追肥，促进侧枝重新结荚结桃。',
          color: 0xFF1B2CD3,
          eventCodes: _hail),
      DisasterGuide(
          title: '低温冻害',
          danger: '油菜越冬冻伤',
          prevention: '越冬前培土护根，喷施抗寒肥；寒潮来临前田间灌水保温。',
          color: 0xFF727CEB,
          aliases: ['低温冻害', '低温', '冻害', '霜冻', '寒潮', '冰冻', '强降温', '降温', '严寒', '寒冷'],
          eventCodes: _coldDamage),
      DisasterGuide(
          title: '沙尘',
          danger: '植株倒伏、落荚落桃',
          prevention: '生长期适度控旺，增强茎秆韧性；倒伏后及时扶正培土。',
          color: 0xFFF2CA00,
          aliases: ['沙尘', '沙尘暴', '春季沙尘天气', '浮尘', '浓浮尘', '扬尘'],
          eventCodes: _sandDust),
      DisasterGuide(
          title: '大雾',
          danger: '高湿诱发叶斑病、霜霉病',
          prevention: '大雾过后及时喷施广谱杀菌剂，降低病害风险。',
          color: 0xFF0ECB4D,
          aliases: ['大雾', '浓雾'],
          eventCodes: _heavyFog),
    ],
  ),
];

CropCategory agricultureCategoryForId(String id) =>
    agricultureCategories.firstWhere((category) => category.id == id,
        orElse: () => agricultureCategories.first);
