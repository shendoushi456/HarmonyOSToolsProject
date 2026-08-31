// 健康生活方式长文本页 - 对齐 Android ExtendedinformationActivity + extendedinfomation_layout.xml
// 纯白背景 + 顶栏 50dp(返回 icon_black_back + 居中标题 18sp 黑) + ScrollView → CardView(白底圆角10 margin15) → Text(长文本 margin10)
// flag=0 → 标题"营养知识" + health_lifestyle_three（营养）
// flag=1 → 标题"如何缓解压力" + health_lifestyle_four（缓解压力）
// 保真：长文本段落编号错乱(1,3,2,4,6)原样保留不修复
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../constants/health_lifestyle_strings.dart';

class HealthInfoPage extends StatelessWidget {
  /// 内容标志 - 对齐 Android ExtendedinformationActivity.intent.getIntExtra("flag", 0)
  /// 0=营养知识 health_lifestyle_three / 1=如何缓解压力 health_lifestyle_four
  final int flag;

  const HealthInfoPage({super.key, this.flag = 0});

  @override
  Widget build(BuildContext context) {
    // 对齐 Android: flag==0 → 标题"营养知识" + health_lifestyle_three; else → "如何缓解压力" + health_lifestyle_four
    final title = flag == 0 ? '营养知识' : '如何缓解压力';
    final content = flag == 0
        ? HealthLifestyleStrings.nutrition
        : HealthLifestyleStrings.stressRelief;

    return Scaffold(
      // 对齐 Android air_fragment_shap_bg（纯白渐变，等同白）
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶栏 50dp - 对齐 Android FrameLayout(padding lr15, height 50dp)
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 50,
                child: Stack(
                  children: [
                    // 返回按钮 - 对齐 Android ei_back ImageView(icon_black_back, padding 10dp, centerV)
                    Positioned(
                      left: 15,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Image.asset(
                              AppAssets.webviewBackBlack,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 标题 - 对齐 Android ei_title TextView(居中, 18sp black)
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ScrollView + CardView - 对齐 Android ScrollView → CardView(白底圆角10 margin15) → TextView(margin10)
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(15), // 对齐 CardView margin 15dp
                padding: const EdgeInsets.all(10), // 对齐 TextView margin 10dp
                decoration: BoxDecoration(
                  color: Colors.white, // cardBackgroundColor white
                  borderRadius: BorderRadius.circular(10), // cardCornerRadius 10dp
                ),
                child: Text(
                  content,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
