import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/recipes_tools_models.dart';

/// 健康妙招页（JianKangMiaoZhaoFragment）静态数据部分。
/// 对应 Android HeathTips.getHeathTips() 与 CalorieSearchListActivity 的入口表。
class HealthTipsViewModel {
  const HealthTipsViewModel();

  static const String _assetBase = 'assets/images/recipes_tools/';

  /// 6 条健康小妙招 —— 对应 HeathTips.getHeathTips()。
  List<HeathTipItem> get heathTips => const [
        HeathTipItem(
          name: '祛湿消肿',
          guanzhu: '改善水肿问题,恢复健康体态',
          coverPath: '${_assetBase}heath_1_ic.png',
          title:
              '祛湿消肿的小妙招可以从多个方面入手，包括饮食、运动、生活习惯以及中医理疗等。以下是一些具体的方'
              '法',
          content:
              '多吃利湿食物：1.绿豆：具有利尿\n'
              '除湿的作用，可以帮助排出体内湿气。2.冬瓜：具有降火利尿、消除水肿的功效，是祛湿的佳品。3.红豆：具有利尿排便的功效，可以快速有效地消除水肿。4.薏米：具有健脾的功效，可以起到一定的祛湿消肿作用。5.芹菜：有助于排除体内的湿气，适用于湿气旺盛导致的\n'
              '肥胖或水肿。 \n\n'
              '•避免湿气重的食物：减少油腻、辛辣、高糖、高盐等食物的摄入，如炸鸡、烧烤、蛋糕、腌制食品等，这些食物容易加重体内湿气。避免生冷食物，如冰激凌、冰镇饮料\n'
              '等，它们会损伤脾胃，影响湿气的排出。',
        ),
        HeathTipItem(
          name: '排毒养颜',
          guanzhu: '排除体内毒素,焕发自然光彩',
          coverPath: '${_assetBase}heath_2_ic.png',
          title: '排毒养颜是一个综合性的过程，涉及饮食、生活习惯、运动等多个方面。\n以下是一些推荐的排毒养颜小妙招：',
          content:
              '多喝水：每天保持足够的水分摄入，有助于冲洗体内的毒素。建议\n'
              '每天至少喝8杯水，尤其是早上起床后空腹喝一杯温水，可以清洗肠道，促进新陈代谢。 \n\n'
              '•多吃富含纤维的食物：如新鲜蔬果、粗杂粮、薯类等，这些食物中的纤维素有助于把食物中不易消化的成分和代谢废物带出体外，保持\n'
              '肠道清洁。\n'
              '•多摄入富含维生素C和E的食物：维生素C和E具有抗氧化作用，可以帮助清除体内的自由基，减少毒素对身体的损害。常见的富含维生素C的食物有柑橘类水果、草莓、猕猴桃等；富含维生素E的食物有坚果、植\n'
              '物油等。',
        ),
        HeathTipItem(
          name: '静心助眠',
          guanzhu: '改善睡眠质量,放松身心',
          coverPath: '${_assetBase}heath_3_ic.png',
          title: '静心助眠的小妙招有很多，这些方法可以帮助你在睡前放松身心，更容易入睡。以下是一些推荐的小妙招：',
          content:
              '\n'
              '•冥想：通过冥想，你可以将注意力集中在呼吸上，或者跟随冥想引导\n'
              '音频，对自己的情绪、思维进行观察，不带有任何评判。这种方法有助于减少杂念，让身心逐渐平静下来。\n'
              '• 自我反省：如果睡前思绪很混乱，可以通过冥想或反省的方式，理清思绪，让自己平静下来，更容易入睡。',
        ),
        HeathTipItem(
          name: '消食养胃',
          guanzhu: '促进消化吸收,养护胃部',
          coverPath: '${_assetBase}heath_4_ic.png',
          title: '消食养胃的小妙招主要包括以下几个方面：',
          content:
              '•糊米茶：做法：取大米30克（或更多，如1公斤），洗净后将锅烧热，锅中不放油，把米倒进锅中小'
              '火加热，用铲子不停翻炒，炒至深黄微焦即可。抓一把炒黄的焦米，放入一个中等大小的碗中，冲入沸水加盖10分钟后，即可饮用，每日数次。功效：米在炒制的过程中，所含的淀粉被破坏分解，变成了活性炭。它可以把附在胃肠的脂肪吸走，排出体外，刮肠刮油，不伤肠胃。此外，大麦炒香后泡水喝也是很好的消食饮品。\n\n'
              '•适当喝醋：做法：在感到油腻的时候，可以适当喝点醋。功效：醋含有挥发性物质及氨基酸，能促进消化液分泌，从而增强消化功能。\n'
              '•山楂绿茶：山楂5g、绿茶3g、冰糖\n'
              '10g，用200ml开水泡饮，冲饮至味淡。功能：消食积，散瘀血，驱缘\n'
              '虫;降压，抗菌。 \n\n'
              '•山楂麦芽茶：麦芽5g、花茶3g，用250ml水煎煮麦芽至水沸后泡茶饮用。功能：消食和中，下气。\n'
              '    ',
        ),
        HeathTipItem(
          name: '养发防脱',
          guanzhu: '强健发根,预防脱发',
          coverPath: '${_assetBase}heath_5_ic.png',
          title: '养发防脱的小妙招可以从多个方面入手，包括日常护理、饮食调理、生活习惯调整等。以下是一些具体的小妙招：',
          content:
              '\n'
              '•选择合适的梳子：推荐梳子使用木梳或牛角梳。这些材质的梳子能减\n'
              '小与头皮的摩擦力，保护头皮，减少掉发。避免使用尼龙梳子和头\n'
              '刷，因为它们易产生静电，对头发和头皮带来不良刺激。 \n\n'
              '•正确洗头：\n'
              '•洗头频率：保持头皮环境干净，议一周洗两次头，具体频率可根据\n'
              '个人发质和头皮状况调整。 \n\n'
              '。洗头方法：先将洗发水打出泡沫，再涂抹在头皮上；洗发时不要用力抓挠头皮，以免头发牵拉脱落；洗后不要立刻用梳子去梳，最好是自然晾千，然后用宽齿的梳子去梳，避免过度牵拉导致脱发。 \n\n'
              '• 使用护发素：选用较好的护发素，每次洗完头发都要均匀涂抹到头\n'
              '上，待到吸收一定时间时再用清水洗掉。  \n\n'
              '\n'
              '• 自然晾干：尽量避免使用吹风机，让头发自然晾干，以减少对头发的热损伤。.头皮按摩：定期用手指轻轻按摩头\n'
              '皮，可以促进头皮血液循环，有助于头发牛长。',
        ),
        HeathTipItem(
          name: '活血经略',
          guanzhu: '促进血液循环,疏通经络',
          coverPath: '${_assetBase}heath_6_ic.png',
          title: '活血经络的小妙招主要包括以下几个方面：',
          content:
              '\n'
              '推荐运动：快走、慢跑、游泳、骑自行车等。这些运动可以促进全身血液循环，有助于打通全身经络，特别是背部和颈部的经络，可以在一定程度上缓解颈背部疼痛。每周进行3-5次，每次持续30分钟以上。  \n\n'
              '•柔韧性训练：瑜伽、太极拳、普拉提等。这些运动可以增加关节的灵活性和活动范围，舒缓肌肉紧张，提高血液流动。  \n\n'
              '•针对性拉伸：针对特定部位（如颈部、肩膀、手臂、腿部等）进行拉伸动作，可以缓解肌肉僵硬和关节不适。',
        ),
      ];

  /// 卡路里查询 8 大分类入口 —— 对应 CalorieSearchListActivity 的 8 个 ImageView。
  List<CalorieCategoryItem> get calorieCategories => const [
        CalorieCategoryItem(
            imagePath: '${_assetBase}zhushi_ic.png', shipuExtra: '1'),
        CalorieCategoryItem(
            imagePath: '${_assetBase}dannai_ic.png', shipuExtra: '2'),
        CalorieCategoryItem(
            imagePath: '${_assetBase}sucai_ic.png', shipuExtra: '3'),
        CalorieCategoryItem(
            imagePath: '${_assetBase}shuiguo_ic.png', shipuExtra: '4'),
        CalorieCategoryItem(
            imagePath: '${_assetBase}yuxia_ic.png', shipuExtra: '5'),
        CalorieCategoryItem(
            imagePath: '${_assetBase}jianguo_ic.png', shipuExtra: '6'),
        CalorieCategoryItem(
            imagePath: '${_assetBase}jiushui_ic.png', shipuExtra: '7'),
        CalorieCategoryItem(
            imagePath: '${_assetBase}yingyang_ic.png', shipuExtra: '8'),
      ];

  /// SPuActivity 各分类对应的远程页面（cateId 原样保留）。
  static const Map<String, String> spuUrls = {
    '1': 'http://2023060501healthsapismanagerh5.forwinsoft.com:808/#/pageA/foodSearchList/foodSearchList?cateId=1668178014618689537',
    '2': 'http://2023060501healthsapismanagerh5.forwinsoft.com:808/#/pageA/foodSearchList/foodSearchList?cateId=1668178066187657217',
    '3': 'http://2023060501healthsapismanagerh5.forwinsoft.com:808/#/pageA/foodSearchList/foodSearchList?cateId=1668178133418156033',
    '4': 'http://2023060501healthsapismanagerh5.forwinsoft.com:808/#/pageA/foodSearchList/foodSearchList?cateId=1668178171376607233',
    '5': 'http://2023060501healthsapismanagerh5.forwinsoft.com:808/#/pageA/foodSearchList/foodSearchList?cateId=1668554746840371201',
    '6': 'http://2023060501healthsapismanagerh5.forwinsoft.com:808/#/pageA/foodSearchList/foodSearchList?cateId=1668554896916762625',
    '7': 'http://2023060501healthsapismanagerh5.forwinsoft.com:808/#/pageA/foodSearchList/foodSearchList?cateId=1668554950243143682',
    '8': 'http://2023060501healthsapismanagerh5.forwinsoft.com:808/#/pageA/foodSearchList/foodSearchList?cateId=1668555039502127105',
  };

  /// ShiPuActivity 菜名 → 本地 HTML 映射（原样保留，含缺失文件的分支）。
  static const Map<String, String> shipuAssetHtml = {
    '糖尿病食谱': 'assets/recipes/jianzhi/../tang_shipu.html',
    '减脂食谱': 'assets/recipes/jianzhi/../jianzhi_shipu.html',
    '鸡胸肉沙拉': 'assets/recipes/jianzhi/jianzhi_shipu.html',
    '三文鱼配西兰花': 'assets/recipes/jianzhi/sanwenyu_xilanhua.html',
    '菠菜蘑菇欧姆蛋': 'assets/recipes/jianzhi/bocai_mogu_oumudan.html',
    '番茄虾仁魔芋面': 'assets/recipes/jianzhi/fanqie_xiaren_moyumian.html',
    '韩式辣白菜豆腐汤': 'assets/recipes/jianzhi/hanshi_labaicai_doufu.html',
    '空气炸锅椒盐花菜': 'assets/recipes/jianzhi/kongqi_jiaoyan_huacai.html',
  };
}

/// 体脂率计算页（TiZhiLvActivity）ViewModel。
/// 对应 tianapi 接口 https://www.tianapi.com/apiview/266，key 原样保留。
class TiZhiLvViewModel extends ChangeNotifier {
  TiZhiLvViewModel({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _apiBaseUrl =
      'https://apis.tianapi.com/bfrsum/index?key=0f4bdafb8117aaac4225a7596c8b3d2c';

  int sex = 1;

  /// Android 在 initView 时一次性读取 ageEt 文本（初始为空），
  /// 之后点击计算不再重新读取，此处保真保留该行为。
  final String age = '';

  TiZhiResult? result;
  bool showResult = false;
  String? toastMessage;

  void setSex(int value) {
    sex = value;
    notifyListeners();
  }

  /// 开始计算 —— 对应 startTv 点击逻辑：身高体重实时读取，code==200
  /// 展示结果，否则 Toast "提示：msg"。
  Future<void> calculate({
    required String height,
    required String weight,
  }) async {
    final url = '$_apiBaseUrl&sex=$sex&age=$age&height=$height&weight=$weight';
    try {
      final response = await _dio.get<Map<String, dynamic>>(url);
      final json = response.data;
      if (json == null) return;
      final code = json['code'];
      final msg = json['msg']?.toString();
      if (code == 200) {
        final resultJson = json['result'];
        if (resultJson is Map<String, dynamic>) {
          result = TiZhiResult.fromJson(resultJson);
          showResult = true;
          toastMessage = null;
          notifyListeners();
        }
      } else {
        showResult = false;
        toastMessage = '提示：$msg';
        notifyListeners();
      }
    } on DioException {
      // 对应 Android NetCallBack.onFailure：静默处理。
    }
  }
}
