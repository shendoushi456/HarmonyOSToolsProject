import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// PDF 子页共用框架 - 顶栏 #F0FFB8 + 内容区 + 底部操作按钮
class PdfToolLayout extends StatelessWidget {
  final String title;
  final String selectButtonText;
  final String actionButtonText;
  final Widget child;
  final VoidCallback? onSelect;
  final VoidCallback? onAction;
  /// AppBar 右上角自定义按钮区（如保存图标），其他 PDF 页不传则不显示。
  final List<Widget>? actions;

  const PdfToolLayout({
    super.key,
    required this.title,
    required this.selectButtonText,
    required this.actionButtonText,
    required this.child,
    this.onSelect,
    this.onAction,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.toolsTopBarBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.toolsTitleText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.toolsTitleText,
          ),
        ),
        centerTitle: true,
        actions: actions,
      ),
      body: Column(
        children: [
          Expanded(child: child),
          if (selectButtonText.isNotEmpty || actionButtonText.isNotEmpty)
            _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (selectButtonText.isNotEmpty)
              Expanded(
                child: OutlinedButton(
                  onPressed: onSelect,
                  child: Text(selectButtonText),
                ),
              ),
            if (selectButtonText.isNotEmpty && actionButtonText.isNotEmpty)
              const SizedBox(width: 12),
            if (actionButtonText.isNotEmpty)
              Expanded(
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.qmtqBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(actionButtonText),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
