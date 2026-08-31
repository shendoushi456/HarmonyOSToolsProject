import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../models/scanned_document.dart';
import '../services/document_export_service.dart';
import '../viewmodels/scanned_document_view_model.dart';

/// 对齐 PicLookDetailActivity：查看原图、保存到本地和不可恢复删除确认。
class DocumentDetailPage extends ConsumerStatefulWidget {
  const DocumentDetailPage({super.key, required this.document});
  final ScannedDocument document;

  @override
  ConsumerState<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends ConsumerState<DocumentDetailPage> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(widget.document.name)),
      body: Column(children: [
        Expanded(
            child: InteractiveViewer(
                maxScale: 4,
                child: Center(
                    child: Image.file(File(widget.document.path),
                        fit: BoxFit.contain)))),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(28, 14, 28, 22),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _FooterAction(
                asset: AppAssets.scanSaveLocal,
                label: _exporting ? '保存中...' : '保存到本地',
                onTap: _exporting ? null : _export),
            _FooterAction(
                asset: AppAssets.scanDelete, label: '删除', onTap: _delete),
          ]),
        ),
      ]),
    );
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      await DocumentExportService().exportToGallery(File(widget.document.path),
          name: widget.document.name);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('已保存到系统相册')));
      }
    } on GalleryExportException catch (error) {
      if (mounted && !error.isCanceled) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('保存失败：${error.message}')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('保存到本地失败，请稍后重试')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: const Text('删除文档'),
              content: const Text('确定要删除文档吗？删除后将无法恢复。'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('取消')),
                FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('确认删除'))
              ],
            ));
    if (confirmed != true) return;
    await ref
        .read(scannedDocumentViewModelProvider.notifier)
        .delete(widget.document);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('删除成功')));
      Navigator.pop(context, true);
    }
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction(
      {required this.asset, required this.label, required this.onTap});
  final String asset;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(asset, width: 30, height: 30),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 13))
        ]));
  }
}
