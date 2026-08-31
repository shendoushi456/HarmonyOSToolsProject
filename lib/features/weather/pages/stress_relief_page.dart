// 如何缓解压力 - 对齐 Android ExtendedinformationActivity + extendedinfomation_layout.xml
// flag=1: 标题"如何缓解压力" + 文本 R.string.health_lifestyle_four
// 结构: 背景圆角灰底 + 顶栏(paddingTop50, 返回 icon_black_back + 标题 18sp 居中)
//       + ScrollView + 白卡(圆角10 margin15) + 长文本(10dp margin, 黑色)
import 'package:flutter/material.dart';

class StressReliefPage extends StatelessWidget {
  const StressReliefPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StressReliefPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 对齐 extendedinfomation_layout 背景 air_fragment_shap_bg
    return Scaffold(
      backgroundColor: const Color(0xFFE3EEFF),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // paddingTop 50dp
            const SizedBox(height: 50),
            // 顶栏 FrameLayout 50dp: 返回(左, padding10) + 标题(居中, 18sp 黑)
            SizedBox(
              height: 50,
              child: Stack(
                children: [
                  Positioned(
                    left: 15,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        // 对齐 icon_black_back
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      '如何缓解压力',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ScrollView + 白卡(圆角10 margin15) + 长文本(margin10 黑色)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    stressReliefContent,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// R.string.health_lifestyle_four 原文(对齐 Android strings.xml)
const String stressReliefContent =
    '压力是大多数人的常见经历。你需要回应它，因为它是生活的一部分。但是，如何在它变得太多之前正确管理它是一个问题。有很多方法可以处理它，我们在下面整理了一份缓解压力的最佳方法列表。\n\n'
    '锻炼定期锻炼是缓解压力的有效方法。此外，简单地给自己一个良好的伸展运动可以立即缓解压力情况下的情绪。这是因为当你运动时，你的身体会释放内啡肽，这可以增加快乐和幸福感，还可以减轻疼痛和不适。更重要的是，定期锻炼可以提高您的睡眠质量和自信心，从而有助于改善心理健康。健康饮食当您处于压力下时，您可能会吃得太多、吃垃圾食品或喝酒。从长远来看，这只会让事情变得更糟。健康、均衡的饮食可以帮助您对抗压力。你可以吃各种水果、蔬菜和全谷物，停止依赖酒精、吸烟和咖啡因。LaughLaughLaughter 可以帮助你感觉更好。当你大笑时，你的心脏、肌肉、肺会放松，你的身体会释放荷尔蒙，减轻你的精神负担。从长远来看，笑声可以提高你的免疫系统，减轻你的痛苦，提升你的情绪。所以，现在是看一部有趣的电影或读一些笑话的时候了。\n\n'
    '做放松技巧瑜伽、冥想和深呼吸是缓解压力的三种有效的放松技巧。\n\n'
    '瑜伽可以锻炼你的身心。它可以帮助您在伸展和做慢动作时放松和管理压力。\n\n'
    '冥想是一种帮助您集中注意力而不会因烦恼而分心的方法。它会给你带来平静、平和、平衡的感觉，并提高你的能量水平。深呼吸是一种自然的放松能力，也是最简单的压力缓解剂。当你深呼吸时，你会给你的大脑带来更多的氧气来平静你的神经系统。\n\n'
    '获得足够的睡眠失眠或睡眠不足会让你感到压力。尝试将以下一些更好的睡眠习惯纳入您的日常生活中，以改善您的睡眠质量。\n\n'
    '您可以在睡觉时保持房间黑暗、安静和凉爽。睡前关掉电视和手机。睡前给自己一个很好的伸展运动或洗个热水澡。此外，请确保您有 7 到 8 小时的睡眠。与他人联系与朋友或家人讨论您的压力情况是一个不错的选择。当您告诉他们您为什么感到压力并收到安慰的声音时，您的身体会释放一种荷尔蒙，帮助您平静下来并放松。';
