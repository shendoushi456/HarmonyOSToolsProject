import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../services/document_image_service.dart';
import 'document_camera_page.dart';
import 'document_crop_page.dart';
import 'document_save_page.dart';

/// 对齐 Android DisplayPicActivity：
///   标题栏 + 中间图片 + 底部 [裁剪 / 重拍 / 水印 / 下一步]。
///
/// UI 按 [activity_display_pic.xml] 还原；功能复用 [DocumentImageService] 的
/// 裁剪 / 水印实现，跳转下一级 [DocumentSavePage]。
class DocumentCapturePreviewPage extends StatefulWidget {
  const DocumentCapturePreviewPage({super.key, required this.file});
  final File file;

  /// 文档扫描完整链路入口：相机拍照 → 拍照后预览页(裁剪/重拍/水印/下一步)。
  /// 对齐 Android MenuFragment 点击"文档扫描" → CameraWenDangActivity
  /// 拍照 → DisplayPicActivity 的链式跳转。
  static Future<void> startFlow(
    BuildContext context, {
    String title = '拍照存档',
  }) async {
    final file = await DocumentCameraPage.capture(context, title: title);
    if (file == null || !context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/document/preview'),
        builder: (_) => DocumentCapturePreviewPage(file: file),
      ),
    );
  }

  @override
  State<DocumentCapturePreviewPage> createState() =>
      _DocumentCapturePreviewPageState();
}

class _DocumentCapturePreviewPageState
    extends State<DocumentCapturePreviewPage> {
  late File _file;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _file = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFFBF8F1),
      body: Stack(
        children: [
          // 全屏背景纹理(对齐 activity_display_pic.xml 中 android:background="@drawable/shap_topbar_bg")
          Positioned.fill(
            child: Image.asset(
              AppAssets.tbcShapTopbarBg,
              fit: BoxFit.cover,
            ),
          ),
          // 对齐源布局根节点 android:fitsSystemWindows="true"：
          // 标题栏从状态栏下方开始布局。
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                const _PreviewTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Image.file(
                      _file,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 底部按钮行 - 对应 activity_display_pic.xml 的 LinearLayout
  /// (paddingLeft 66 / paddingRight 48 / height 83)
  Widget _buildBottomBar() {
    return Container(
      height: 153,
      padding: const EdgeInsets.only(left: 66, right: 48, bottom: 2),
      child: Row(
        children: [
          _ActionColumn(
            icon: AppAssets.tbcIcCaijian,
            label: '裁剪',
            onTap: _processing ? null : _crop,
          ),
          _ActionColumn(
            icon: AppAssets.tbcIcChongpai,
            label: '重拍',
            onTap: _processing ? null : _retake,
          ),
          _ActionColumn(
            icon: AppAssets.tbcIcShuiyin,
            label: '水印',
            onTap: _processing ? null : _watermark,
          ),
          const Spacer(),
          Center(
            child: _NextButton(
              loading: _processing,
              onPressed: _processing ? null : _next,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _crop() async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/document/crop'),
        builder: (_) => DocumentCropPage(file: _file),
      ),
    );
    if (result != null && mounted) {
      setState(() => _file = result);
    }
  }

  Future<void> _retake() async {
    final result = await DocumentCameraPage.capture(context, title: '拍照存档');
    if (result != null && mounted) {
      setState(() => _file = result);
    }
  }

  Future<void> _watermark() async {
    // final controller = TextEditingController(text: '默认水印');
    final text = await showDialog<String>(
        context: context, builder: (_) => const _WatermarkDialog());
    if (text == null || text.trim().isEmpty) return;
    if (!mounted) return;
    setState(() => _processing = true);
    try {
      final result =
          await DocumentImageService().addWatermark(_file, text.trim());
      if (mounted) setState(() => _file = result);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('添加水印失败')));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _next() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/document/save'),
        builder: (_) => DocumentSavePage(file: _file),
      ),
    );
    if (saved == true && mounted) Navigator.pop(context, true);
  }
}

/// 水印输入框自行管理控制器生命周期，避免弹框关闭时父页面提前释放
/// TextEditingController，导致鸿蒙 Flutter 引擎在 InheritedElement 销毁阶段
/// 触发 `_dependents.isEmpty` 断言。
class _WatermarkDialog extends StatefulWidget {
  const _WatermarkDialog();

  @override
  State<_WatermarkDialog> createState() => _WatermarkDialogState();
}

class _WatermarkDialogState extends State<_WatermarkDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '默认水印');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置水印文字'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: '输入要添加的水印'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('添加'),
        ),
      ],
    );
  }
}

/// 顶部标题栏 - 对应 activity_display_pic.xml 的 title_rl
/// (height 50dp, 返回按钮左侧 16dp, 标题居中 22sp #444444)
class _PreviewTopBar extends StatelessWidget {
  const _PreviewTopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              '文档扫描',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF444444),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.maybePop(context),
                child: Image.asset(
                  AppAssets.tbcIconBlackBack,
                  width: 22,
                  height: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部 [裁剪 / 重拍 / 水印] 列 - 对应 LinearLayout 子项
class _ActionColumn extends StatelessWidget {
  const _ActionColumn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 58,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(icon, width: 32, height: 32),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF444444),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 下一步按钮 - 对应 net.csdn.roundview.RoundTextView
/// (width 62 / height 26 / radius 13 / bg #168EC6 / white 14sp)
class _NextButton extends StatelessWidget {
  const _NextButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 62,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF168EC6),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Text(
          loading ? '...' : '下一步',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
