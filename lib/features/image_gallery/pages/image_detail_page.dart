import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../scan_menu/services/document_export_service.dart';
import '../models/image_gallery_item.dart';
import '../viewmodels/image_gallery_view_model.dart';

/// 对齐 toolbox_c PicLookDetailActivity + activity_pic_look.xml：
/// ic_sao_main_bg 背景 + "详情"顶栏 + fitStart 图片 + 保存到本地/删除
class ImageDetailPage extends ConsumerStatefulWidget {
  const ImageDetailPage({super.key, required this.item});

  final ImageGalleryItem item;

  @override
  ConsumerState<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends ConsumerState<ImageDetailPage> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 对齐背景 ImageView: image_gallery_background(fitXY)
          Positioned.fill(
            child: Image.asset(
              AppAssets.saoMainBg,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(),
                // 对齐 imageview: weight1, margin L16 R16 T20 B30, fitStart
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                    child: Image.file(
                      File(widget.item.path),
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                _buildBottomBar(),
                // 对齐底部 38sdp 占位 View
                const SizedBox(height: 38),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 对齐顶栏: 50dp，icon_black_back 左侧 16dp，"详情" 22sp 黑色居中
  Widget _buildTopBar() {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            '详情',
            style: TextStyle(
              color: Colors.black, // color_title_text
              fontSize: 22,
            ),
          ),
          Positioned(
            left: 16,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // 对齐 lookBackIv: setResult(RESULT_OK) + finish()
              onTap: () => Navigator.pop(context, true),
              child: Image.asset(
                AppAssets.igBlackBack,
                width: 21.3,
                height: 21.3,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 对齐底部 83dp 操作栏(paddingH20): 保存到本地 + 删除 各占一半，
  /// 图标 28dp + 文字 10sp #444444，marginTop 16
  Widget _buildBottomBar() {
    return SizedBox(
      height: 83,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildAction(
                  icon: AppAssets.igSaveLocal,
                  label: _exporting ? '保存中...' : '保存到本地',
                  onTap: _exporting ? null : _export,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildAction(
                  icon: AppAssets.igDelete,
                  label: '删除',
                  onTap: _delete,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction({
    required String icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(icon, width: 28, height: 28, fit: BoxFit.fill),
          const SizedBox(height: 0),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF444444),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// 对齐 saveLocal 点击 -> BasePicActivity.saveFileLocal：保存到系统相册
  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      await DocumentExportService()
          .exportToGallery(File(widget.item.path), name: widget.item.name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已保存到系统相册')),
        );
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

  /// 对齐 delete_ll 点击：匹配路径后直接删除 + Toast"删除成功"
  /// (安卓端无确认框、不自动返回列表；返回时经 RESULT_OK 刷新)
  Future<void> _delete() async {
    await ref.read(imageGalleryViewModelProvider.notifier).delete(widget.item);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除成功')),
      );
    }
  }
}
