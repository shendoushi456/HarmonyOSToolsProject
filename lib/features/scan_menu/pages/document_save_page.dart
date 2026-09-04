import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_assets.dart';
import '../../home/viewmodels/home_tab_view_model.dart';
import '../services/document_export_service.dart';
import '../viewmodels/scanned_document_view_model.dart';

/// 对齐 Android FileSaveEndActivity：
///   名称输入 + 保存至入口 + [保存至本地 / 完成] 按钮组。
///
/// UI 按 [activity_file_save_end.xml] 还原；功能复用鸿蒙项目原有的导出服务
/// 和文档保存仓库，保证马甲包替换 UI 时数据行为不变。
class DocumentSavePage extends ConsumerStatefulWidget {
  const DocumentSavePage({super.key, required this.file});
  final File file;

  @override
  ConsumerState<DocumentSavePage> createState() => _DocumentSavePageState();
}

class _DocumentSavePageState extends ConsumerState<DocumentSavePage> {
  late final TextEditingController _nameController;
  bool _exporting = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: '文档扫描${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      body: Stack(
        children: [
          // 与 Android layout 中 android:background="@drawable/shap_topbar_bg" 一致
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
                const _SaveTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '名称',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3C3C3C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _ShapedField(
                          height: 36,
                          child: EditableText(
                            controller: _nameController,
                            focusNode: FocusNode(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF444444),
                            ),
                            cursorColor: const Color(0xFF444444),
                            backgroundCursorColor: const Color(0xFF444444),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          '保存至',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF444444),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const _ShapedField(
                          height: 36,
                          paddingLeft: 18,
                          paddingRight: 8,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '文档首页',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF444444),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                        _buildButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// [保存至本地 / 完成] 按钮组 - 对应布局底部 LinearLayout(居中)
  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StrokeButton(
          label: _exporting ? '保存中...' : '保存至本地',
          onTap: _exporting ? null : _export,
        ),
        const SizedBox(width: 20),
        _SolidButton(
          label: _saving ? '保存中...' : '完成',
          onTap: _saving ? null : _finish,
        ),
      ],
    );
  }

  Future<void> _export() async {
    final name = _nameController.text.trim().isEmpty
        ? '文档扫描'
        : _nameController.text.trim();
    setState(() => _exporting = true);
    try {
      await DocumentExportService().exportToGallery(widget.file, name: name);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('已保存到系统相册')));
      }
    } on GalleryExportException catch (error) {
      if (mounted && !error.isCanceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：${error.message}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存到本地失败，请稍后重试')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _finish() async {
    final name = _nameController.text.trim().isEmpty
        ? '文档扫描'
        : _nameController.text.trim();
    setState(() => _saving = true);
    try {
      await ref
          .read(scannedDocumentRepositoryProvider)
          .saveCapturedDocument(widget.file, displayName: name);
      await ref.read(scannedDocumentViewModelProvider.notifier).refresh();
      ref.read(homeTabIndexProvider.notifier).state = 1;
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('文档保存失败，请重试')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// 顶部 50dp 标题栏 - 对应布局 title_rl(返回隐藏，标题"文档扫描")
class _SaveTopBar extends StatelessWidget {
  const _SaveTopBar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 50,
      child: Stack(
        children: [
          Center(
            child: Text(
              '文档扫描',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF444444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 输入框 / TextView 的统一白色圆角 6dp 背景 - 对应 @drawable/shape
class _ShapedField extends StatelessWidget {
  const _ShapedField({
    required this.child,
    this.height = 36,
    this.paddingLeft = 0,
    this.paddingRight = 0,
  });

  final Widget child;
  final double height;
  final double paddingLeft;
  final double paddingRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: EdgeInsets.only(left: paddingLeft, right: paddingRight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

/// 保存至本地 - 对应 RoundTextView(stroke #168EC6, radius 22, text #168EC6)
class _StrokeButton extends StatelessWidget {
  const _StrokeButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 132,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF168EC6), width: 2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF168EC6),
          ),
        ),
      ),
    );
  }
}

/// 完成 - 对应 RoundTextView(bg #168EC6, radius 22, text white)
class _SolidButton extends StatelessWidget {
  const _SolidButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 132,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF168EC6),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
