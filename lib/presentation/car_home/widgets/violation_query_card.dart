import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';

/// 违章代码查询主卡片
///
/// 对应 Android: CarFragment.kt:227-304 ViolationQueryCard
/// 绿色卡片 + 背景图 + "违章代码查询"标题 + "立即查询"按钮，点击跳违章代码查询输入页。
class ViolationQueryCard extends StatelessWidget {
  const ViolationQueryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.violationCodeSearch),
        child: Container(
          height: 90,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF39D6AE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 背景图片
              Image.asset(
                'assets/images/che/ic_che_main_1_1.png',
                fit: BoxFit.cover,
              ),
              // 内容层
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '违章代码查询',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const _QueryButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "立即查询" 按钮
class _QueryButton extends StatelessWidget {
  const _QueryButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '立即查询',
            style: TextStyle(
              color: Color(0xFF39D6AE),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 6),
          SizedBox(
            width: 22,
            height: 22,
            child: Image(
              image: AssetImage('assets/images/che/ic_che_main_arrow.png'),
            ),
          ),
        ],
      ),
    );
  }
}
