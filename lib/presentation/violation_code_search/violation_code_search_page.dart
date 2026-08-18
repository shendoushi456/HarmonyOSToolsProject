import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';

/// 违章代码查询输入页
///
/// 对应 Android: toolCarLib/SearchViolationCodeCarActivity.kt
/// 输入违章代码 + "立即查询"按钮 → 跳查询结果页。
class ViolationCodeSearchPage extends StatefulWidget {
  const ViolationCodeSearchPage({super.key});

  @override
  State<ViolationCodeSearchPage> createState() =>
      _ViolationCodeSearchPageState();
}

class _ViolationCodeSearchPageState extends State<ViolationCodeSearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('违章代码查询')),
      body: ColoredBox(
        color: const Color(0xFFF5F5F5),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // 输入卡片
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 36),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '违章代码',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF404040),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: '请输入',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 说明文字
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  '说明：可通过交通违法代码查询具体交通违法行为，代码以交管部门发布为准，我们会严格保密用户隐私',
                  style: TextStyle(
                    fontSize: 8,
                    color: Color(0xFFF67272),
                    height: 11 / 8,
                  ),
                ),
              ),
              const SizedBox(height: 62),
              // 立即查询按钮
              Center(
                child: SizedBox(
                  width: 228,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      final code = _controller.text.trim();
                      if (code.isNotEmpty) {
                        context.push(
                          AppRoutes.violationCodeResult.replaceFirst(
                            ':code',
                            Uri.encodeComponent(code),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FC093),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(29),
                      ),
                    ),
                    child: const Text(
                      '立即查询',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
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
