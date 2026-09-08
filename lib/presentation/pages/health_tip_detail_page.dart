import 'package:flutter/material.dart';

import '../../data/models/recipes_tools_models.dart';

/// 健康小妙招详情 —— 对应 Android JKMiaoZhaoDetailActivity +
/// activity_health_tip_detail.xml：顶部头图（heath_rp_head 198dp fitXY）、
/// 返回键、"$name小妙招" 大标题（28sp）、装饰图与渐变条、
/// 简介卡片（白底底部圆角 9dp）、绿色方法标题胶囊 + 内容正文。
class HealthTipDetailPage extends StatelessWidget {
  const HealthTipDetailPage({super.key, required this.tip});

  final HeathTipItem tip;

  /// methodTitle 联动逻辑：活血经略→运动锻炼、静心助眠→冥想·反省、
  /// 养发防脱→日常护理，默认"饮食调理"。
  String get _methodTitle {
    switch (tip.name) {
      case '活血经略':
        return '运动锻炼';
      case '静心助眠':
        return '冥想·反省';
      case '养发防脱':
        return '日常护理';
      default:
        return '饮食调理';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top:true,
          child: SingleChildScrollView(
        child: SizedBox(
          // 竖向滚动区承载 Android 的层叠 + NestedScrollView 结构
          width: double.infinity,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头图 198dp fitXY
                  SizedBox(
                    height: 198,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/recipes_tools/heath_rp_head.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  // 渐变条（health_tip_gradient：透明→#C3EFF1，高 26dp，marginH 15）
                  Container(
                    height: 26,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00FFFFFF), Color(0xFFC3EFF1)],
                      ),
                    ),
                  ),
                  // 简介卡片：白底、底部圆角 9dp、paddingTop 26、marginH 15
                  // 与渐变条叠加 1dp（203 vs 202），这里按顺序排列保持观感。
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.only(
                        top: 26, left: 13, right: 13, bottom: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(9),
                        bottomRight: Radius.circular(9),
                      ),
                    ),
                    child: Text(
                      tip.title,
                      style: const TextStyle(
                        color: Color(0xFF565050),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // 方法区
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 22, 15, 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // methodTitle：白字 20sp、#9FDE6E 圆角 20dp 胶囊
                        Container(
                          height: 36,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9FDE6E),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _methodTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 小三角装饰图（12x14dp，marginTop 5）
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Image.asset(
                                'assets/images/recipes_tools/heath_rp_img_triangle.png',
                                width: 12,
                                height: 14,
                                fit: BoxFit.contain,
                              ),
                            ),
                            // 内容正文 18sp，marginStart 21
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 21),
                                child: Text(
                                  tip.content,
                                  style: const TextStyle(
                                    color: Color(0xFF2D2D2D),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 返回键：26dp，marginTop 11、marginStart 18
              Positioned(
                top: 11,
                left: 18,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Image.asset(
                    'assets/images/recipes_tools/navigation_bar_ic_left.png',
                    width: 26,
                    height: 26,
                  ),
                ),
              ),
              // "$name小妙招" 标题：28sp #2D2D2D，marginTop 114、marginStart 22
              Positioned(
                top: 114,
                left: 22,
                child: Text(
                  '${tip.name}小妙招',
                  style: const TextStyle(
                    color: Color(0xFF2D2D2D),
                    fontSize: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
