// 字体大小设置页 - 对齐 Android TextSizeSettingsActivity
// (tools_extra_lib TipsTextSizeDialog.kt 的 TextSizeSettingsPage Compose 版)。
// 鸿蒙差异:原版写 Settings.System.FONT_SCALE 修改系统字体(需 WRITE_SETTINGS
// 权限),鸿蒙不开放该 API,改为应用内缩放(App 全局 textScaler + 本地持久化),
// 确认弹窗 UI 按 TipsTextSizeDialog/dialog_tips_textsize_layout 保真复刻。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/font_scale_provider.dart';

class FontSizeSettingsPage extends ConsumerWidget {
  const FontSizeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(fontScaleProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // "选择字体大小" - 对齐 "选择系统字体大小"
                  const Text(
                    '选择字体大小',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  // 当前缩放显示 - 对齐 "当前系统设置缩放: %.2fx"(绿色)
                  Text(
                    '当前字体缩放: ${scale.toStringAsFixed(2)}x',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  // 示例文本区 - 对齐 Gray 圆角容器(minHeight 100, padding 16)
                  Container(
                    constraints: const BoxConstraints(minHeight: 100),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: const Text(
                      '示例文本: 静夜思\n床前明月光，疑是地上霜。\n举头望明月，低头思故乡。',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 档位按钮 - 对齐 4 个 Button(vertical 6 间距)
                  for (final option in kFontScaleOptions) ...[
                    _ScaleButton(
                      label: option.label,
                      // "恢复默认"按钮蓝色 - 对齐 ButtonDefaults.buttonColors(Blue)
                      isHighlight: option.scale == 1.0,
                      onTap: () => _showTipsDialog(context, ref, option),
                    ),
                    const SizedBox(height: 6),
                  ],
                  const SizedBox(height: 10),
                  // 底部提示 - 对齐"提示：修改系统字体大小..."文案按应用内场景调整
                  const Text(
                    '提示：修改字体大小仅影响本应用内的文字显示，立即生效。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 顶部栏 - 对齐 TopAppBar("字体大小设置" + 返回),样式随工程二级页
  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 88,
      color: AppColors.settingTheme,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 8,
              bottom: 0,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 48,
                child: Center(
                  child: Text(
                    '字体大小设置',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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

  /// 确认弹窗 - 对齐 TipsTextSizeDialog(showDialog 版):
  /// 点击弹窗外不关闭(dismissOnClickOutside=false)
  void _showTipsDialog(
    BuildContext context,
    WidgetRef ref,
    FontScaleOption option,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _TipsTextSizeDialog(
        onCommit: () async {
          Navigator.of(dialogContext).pop();
          await ref.read(fontScaleProvider.notifier).setScale(option.scale);
          if (context.mounted) {
            // 对齐安卓 Toast "系统字体大小已尝试设置。" 文案按应用内场景调整
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('字体大小已设置为 ${option.scale}x。')),
            );
          }
        },
        onCancel: () {
          // 对齐安卓 Toast "操作已取消"
          Navigator.of(dialogContext).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('操作已取消')),
          );
        },
      ),
    );
  }
}

/// 档位按钮 - 对齐 Material Button(fillMaxWidth, vertical 6)
class _ScaleButton extends StatelessWidget {
  const _ScaleButton({
    required this.label,
    required this.isHighlight,
    required this.onTap,
  });

  final String label;
  final bool isHighlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isHighlight ? const Color(0xFF2196F3) : const Color(0xFF159BD8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// 设置提示弹窗 - 对齐 TipsTextSizeDialog Compose 版:
/// F5F5F5 卡片 + 1dp E0E0E0 边框(水平 35 边距) + 内层白底 padding 10 +
/// 取消(E0E0E0 灰)/设置(007AFF 蓝) 圆角 16 按钮
class _TipsTextSizeDialog extends StatelessWidget {
  const _TipsTextSizeDialog({
    required this.onCommit,
    required this.onCancel,
  });

  final VoidCallback onCommit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 35),
      child: Container(
        // MaterialCardView: cardBackgroundColor F5F5F5 + strokeColor E0E0E0
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题 - 18sp bold 居中(marginTop 15)
            const Padding(
              padding: EdgeInsets.only(top: 15),
              child: Text(
                '设置字体大小提示',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 描述 - 14sp(margin 15),文案按应用内场景调整(原版描述权限申请)
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                '为了您能更舒适地阅读，可选择合适的字体大小。此设置仅对当前应用生效。',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
            // 按钮行 - 对齐 Row(top 20, bottom 10, 间距 10)
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Row(
                children: [
                  // 取消按钮 - E0E0E0 灰底圆角 16, 18sp 黑
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onCancel,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '取消',
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 设置按钮 - 007AFF 蓝底圆角 16, 18sp 白 bold
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onCommit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '设置',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
