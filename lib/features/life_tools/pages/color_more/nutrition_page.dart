import 'package:flutter/material.dart';
import '../widgets/tool_top_bar.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});
  static Future<void> push(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const NutritionPage()));
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: const ToolTopBar(title: '营养知识'),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: const [
            _NutritionSection(
                title: '健康饮食基础',
                body:
                    '你吃的东西会影响你的能量、外表和健康。食物通过向身体输送营养来提供能量。想要健康饮食，首先需要了解食物中的基本营养信息。'),
            _NutritionSection(
                title: '宏量营养素',
                body:
                    '宏量营养素包括碳水化合物、蛋白质和脂肪，它们是饮食的基石。碳水化合物为身体提供葡萄糖；蛋白质由氨基酸组成，帮助构建和修复组织；脂肪能够储存能量、保护器官，并支持神经系统和皮肤功能。'),
            _NutritionSection(
                title: '蛋白质与脂肪',
                body:
                    '肉类、蛋类、奶类、豆类中含有丰富蛋白质。一般建议成年人每天每公斤体重摄入约 0.8 克蛋白质。脂肪应占每日能量摄入的约 20% 至 35%，应优先选择更健康的不饱和脂肪。'),
            _NutritionSection(
                title: '微量营养素',
                body:
                    '维生素和矿物质虽然需要量较少，却参与能量生成、免疫、血液凝固、骨骼健康和体液平衡。维生素 C、B 族维生素、维生素 A、D、E、K，以及钙、铁、镁、锌等都应通过多样化饮食获得。'),
            _NutritionSection(
                title: '日常建议',
                body:
                    '保持食物多样，适量摄入蔬菜、水果、全谷物、奶类和优质蛋白；减少高盐、高糖和反式脂肪。规律运动、戒烟限酒、保持良好作息同样重要。本文为健康科普，不能替代医生或营养师的个体化建议。'),
          ]));
}

class _NutritionSection extends StatelessWidget {
  const _NutritionSection({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF352570))),
        const SizedBox(height: 8),
        Text(body,
            style: const TextStyle(
                fontSize: 15, height: 1.65, color: Color(0xFF444444)))
      ]));
}
