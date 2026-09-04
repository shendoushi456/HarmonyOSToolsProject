import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../home/viewmodels/home_tab_view_model.dart';
import '../services/document_export_service.dart';
import '../viewmodels/scanned_document_view_model.dart';

/// 对齐 FileSaveEndActivity：编辑名称、导出相册并保存到文档列表。
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
        text:
            '文档扫描${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('保存文档')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('文档名称',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
              controller: _nameController,
              maxLength: 60,
              decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _exporting ? null : _export,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(_exporting ? '保存中...' : '保存到本地'),
          ),
          const Spacer(),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: _saving ? null : _finish,
                  child: Text(_saving ? '保存中...' : '完成'))),
        ]),
      ),
    );
  }

  String get _name => _nameController.text.trim().isEmpty
      ? '文档扫描'
      : _nameController.text.trim();

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      await DocumentExportService().exportToGallery(widget.file, name: _name);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('已保存到本地')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('保存到本地失败，请重试')));
      }
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(scannedDocumentRepositoryProvider)
          .saveCapturedDocument(widget.file, displayName: _name);
      await ref.read(scannedDocumentViewModelProvider.notifier).refresh();
      ref.read(homeTabIndexProvider.notifier).state = 1;
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('文档保存失败，请重试')));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
