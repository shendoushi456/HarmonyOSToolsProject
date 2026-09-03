import 'package:flutter/material.dart';

/// Android ExtendedinformationActivity 的 Flutter 迁移页。
/// 通过 topic 复用同一套详情 UI，后续替换马甲时只需替换展示层。
class HealthKnowledgePage extends StatelessWidget {
  final HealthKnowledgeTopic topic;

  const HealthKnowledgePage({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final isNutrition = topic == HealthKnowledgeTopic.nutrition;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        title: Text(isNutrition ? '营养知识' : '如何缓解压力'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F8FC),
        foregroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Text(
          isNutrition ? _nutritionText : _stressText,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 15,
            height: 1.75,
          ),
        ),
      ),
    );
  }
}

enum HealthKnowledgeTopic { nutrition, stress }

const _nutritionText =
    '''你吃的东西会影响你的能量、外表和健康。食物通过向身体输送营养来提供能量。想要健康饮食，需要了解营养素并保持均衡搭配。

常量营养素包括碳水化合物、蛋白质和脂肪，它们是饮食的基石。碳水化合物为身体提供葡萄糖；蛋白质由氨基酸组成，有助于构建和修复组织；脂肪能够储存能量、保护器官并维持神经系统和皮肤功能。

建议每天摄入多种蔬菜、水果、全谷物、豆类、奶类、鱼肉和蛋类。蛋白质可参考每公斤体重约 0.8 克的日摄入量，并根据年龄、运动量和健康状况调整。

维生素和矿物质属于微量营养素。维生素 A、D、E、K 以及 B 族维生素和维生素 C，各自参与视力、骨骼、免疫和能量代谢。钙、铁、镁、钾、锌等矿物质也不可缺少，应优先从天然食物中获取。

少吃高盐、高糖、高脂和过度加工食品，适量饮水，规律进餐。若有慢性疾病、过敏或特殊饮食需求，请咨询医生或营养师。''';

const _stressText = '''压力是大多数人的常见经历。你需要回应它，因为它是生活的一部分；但在压力变得过多之前，及时管理非常重要。

规律运动是缓解压力的有效方法。散步、伸展、瑜伽或其他适度运动能够帮助身体释放内啡肽，改善情绪、睡眠质量和自信心。

保持健康饮食。压力大时容易吃得过多、选择垃圾食品或饮酒，这会让情况更糟。多吃水果、蔬菜和全谷物，减少酒精、吸烟和过量咖啡因。

尝试笑一笑、听音乐、阅读、冥想和深呼吸。深呼吸能帮助神经系统放松；瑜伽和冥想则有助于集中注意力、恢复平静。

保证充足睡眠：保持卧室黑暗、安静、凉爽，睡前减少手机和电视使用，尽量每晚睡 7 至 8 小时。与朋友或家人交流压力和感受，也能获得支持与安慰。

如果持续感到无法应对、情绪低落或影响日常生活，请及时寻求专业心理或医疗帮助。''';
