import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../scan_menu/services/document_export_service.dart';
import '../models/image_item.dart';
import '../viewmodels/image_gallery_view_model.dart';

/// 对齐 Android `PicLookDetailActivity`：
///   顶部返回 + "详情" 标题，中间 fitStart 图片，底部 [保存到本地 / 删除]。
///
/// 保存功能复用鸿蒙既有的 [DocumentExportService] (导出到系统相册)；
/// 删除通过 view model 的 [ImageGalleryViewModel.deleteItem] 完成。
class ImageDetailPage extends ConsumerStatefulWidget {
  const ImageDetailPage({super.key, required this.item});
  final ImageItem item;

  @override
  ConsumerState<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends ConsumerState<ImageDetailPage> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.tbcShapTopbarBg,
              fit: BoxFit.cover,
            ),
          ),
    SafeArea(
    top: true,
    bottom: true,
    child: Column(
            children: [
              _DetailTopBar(
                onBack: () => Navigator.pop(context, false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                  child: Image.file(
                    File(widget.item.path),
                    width: double.infinity,
                    // Android scaleType="fitStart" 对应 Flutter BoxFit.contain(默认顶部对齐)
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Color(0xFFB0B0B0),
                        size: 80,
                      ),
                    ),
                  ),
                ),
              ),
              _DetailBottomBar(
                exporting: _exporting,
                onSaveLocal: _exporting ? null : _onSaveLocal,
                onDelete: _onDelete,
              ),
            ],
          ),
    ),
        ],
      ),
    );
  }

  /// 保存到本地 - 对齐 BasePicActivity.saveFileLocal / UtilsPic.SaveImage。
  /// Android 端使用 Alerter 弹窗 + MediaScannerConnection；这里对齐到鸿蒙
  /// 项目的 `DocumentExportService.exportToGallery` 走原生相册保存通道。
  Future<void> _onSaveLocal() async {
    setState(() => _exporting = true);
    try {
      await DocumentExportService().exportToGallery(
        File(widget.item.path),
        name: widget.item.name,
      );
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

  /// 删除 - 对齐 PicLookDetailActivity 中 delete_ll 的逻辑。
  /// Android 端在删除后弹 Toast 并依赖 onActivityResult 通知列表刷新；这里
  /// 通过 `Navigator.pop(context, true)` 通知列表页删除成功并触发刷新。
  Future<void> _onDelete() async {
    try {
      await ref
          .read(imageGalleryViewModelProvider.notifier)
          .deleteItem(widget.item.path);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('删除成功')));
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('删除失败')));
      }
    }
  }
}

/// 顶部 50dp 标题栏 - 对应 activity_pic_look.xml 的 RelativeLayout
class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              '详情',
              style: TextStyle(
                color: Color(0xFF444444),
                fontSize: 22,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack,
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

/// 底部 83dp 操作栏 - 对应 activity_pic_look.xml 的 LinearLayout
/// (paddingLeft/Right 20, 内部两个等宽列：[保存到本地 / 删除])
class _DetailBottomBar extends StatelessWidget {
  const _DetailBottomBar({
    required this.exporting,
    required this.onSaveLocal,
    required this.onDelete,
  });

  final bool exporting;
  final VoidCallback? onSaveLocal;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 83,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _BottomAction(
            icon: AppAssets.igSaveLocalIc,
            label: exporting ? '保存中...' : '保存到本地',
            onTap: onSaveLocal,
          ),
          _BottomAction(
            icon: AppAssets.igDeleteIc,
            label: '删除',
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

/// 底部单个图标 + 文字列(28x28 icon + 10sp #444444 文字)
class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(icon, width: 28, height: 28),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF444444),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}