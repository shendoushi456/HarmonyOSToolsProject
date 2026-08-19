import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// 原文显示页面
///
/// 对应原 Android `OriginalTranslationActivity`，保真还原：
/// 蓝色顶栏（返回 + "原文"标题）+ 背景图 ic_text_bg + 原文内容（可滚动）+ 复制按钮。
class OriginalTranslationPage extends StatelessWidget {
  const OriginalTranslationPage({super.key, required this.originalText});

  final String originalText;

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: originalText));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: _buildContentCard(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 顶部蓝色栏
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  '原文',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 内容卡片（背景图 + 文本 + 复制按钮）
  Widget _buildContentCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // 背景图
            Positioned.fill(
              child: Image.asset(
                'assets/images/ic_text_bg.png',
                fit: BoxFit.fill,
              ),
            ),
            // 内容
            Column(
              children: [
                // "原文"标签
                const Padding(
                  padding: EdgeInsets.only(top: 20, left: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '原文',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.langSwitchText,
                      ),
                    ),
                  ),
                ),
                // 原文内容（可滚动）
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: SingleChildScrollView(
                      child: Text(
                        originalText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.langSwitchText,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // 复制按钮
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _copyToClipboard(context),
                      child: Image.asset(
                        'assets/images/ic_trans_copy.png',
                        width: 22,
                        height: 22,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
