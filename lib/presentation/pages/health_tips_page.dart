import 'package:flutter/material.dart';

import '../../data/models/recipes_tools_models.dart';
import '../../features/health_tips/health_tips_view_model.dart';
import 'health_tip_detail_page.dart';
import 'tizhilv_page.dart';

/// 健康妙招页（减脂 Tab）—— 对应 Android JianKangMiaoZhaoFragment +
/// fragment_jiankang_miaozhao.xml：顶部体脂率入口图（tizhilv.png，
/// 高 200dp、fitCenter、padding 20dp）+ 2 列网格 6 张妙招卡片
/// （160x140dp、bg_yinyang 背景、封面图 + 标题 + 副标题）。
class HealthTipsPage extends StatelessWidget {
  const HealthTipsPage({super.key, required this.viewModel});

  final HealthTipsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final tips = viewModel.heathTips;
    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          // 体脂率入口图，点击进入体脂率计算页
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => const TiZhiLvPage())),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 160, // 200dp 高度扣除上下 20dp padding
                width: double.infinity,
                child: Image.asset(
                  'assets/images/recipes_tools/tizhilv.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Expanded(
            // GridLayoutManager(context, 2)：2 列网格，无间距
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 160 / 140,
              ),
              itemCount: tips.length,
              itemBuilder: (context, index) {
                final tip = tips[index];
                return _HeathTipCard(
                  tip: tip,
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute<void>(
                    builder: (_) => HealthTipDetailPage(tip: tip),
                  )),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 妙招卡片 —— item_heath_tips.xml：RelativeLayout 160x140dp，
/// bg_yinyang.png 背景，封面图（marginTop 15 居中）、
/// 标题 16sp bold #464646（marginTop 10 居中）、副标题 12sp #818181 居中。
class _HeathTipCard extends StatelessWidget {
  const _HeathTipCard({required this.tip, required this.onTap});

  final HeathTipItem tip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 160,
          height: 140,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage('assets/images/recipes_tools/bg_yinyang.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Image.asset(tip.coverPath,
                  width: 32,
                  height: 32),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  tip.name,
                  style: const TextStyle(
                    color: Color(0xFF464646),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 35,
                  child: Center(
                    child: Text(
                      tip.guanzhu,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF818181),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
