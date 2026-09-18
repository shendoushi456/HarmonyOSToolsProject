// 隐藏图页 - 对齐 Android pic_toolslibrary PictureHideActivity + activity_picture_hide.xml
// 紫色顶栏"隐藏图制作"(pic_toolslibrary appbarColor),两张灰底圆角图片卡(上层/下层),
// "上层图片/下层图片"黑色按钮选图,两图就绪后底部出现通宽"生成图片"按钮,
// 合成对齐 BitmapPixelUtil.makeHideImage(见 hidden_image_service),
// 生成即保存,保存改用系统图库(SaveButton 流程)，文件名对齐安卓 Image-HH-mm-ss。
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_assets.dart';
import '../../scan_menu/services/document_export_service.dart';
import '../services/hidden_image_service.dart';

class HiddenImagePage extends StatefulWidget {
  const HiddenImagePage({super.key});

  static Future<void> push(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HiddenImagePage()),
      );

  @override
  State<HiddenImagePage> createState() => _HiddenImagePageState();
}

class _HiddenImagePageState extends State<HiddenImagePage> {
  final ImagePicker _picker = ImagePicker();
  final HiddenImageService _service = HiddenImageService.instance;

  Uint8List? _topBytes;
  Uint8List? _bottomBytes;
  bool _generating = false;

  bool get _bothReady => _topBytes != null && _bottomBytes != null;

  Future<void> _pickImage({required bool top}) async {
    // 对齐安卓 ACTION_GET_CONTENT(多选但只取第一张)，这里直接单选。
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      if (top) {
        _topBytes = bytes;
      } else {
        _bottomBytes = bytes;
      }
    });
  }

  Future<void> _generate() async {
    if (!_bothReady || _generating) return;
    setState(() => _generating = true);
    try {
      // 对齐安卓: 合成成功后立即保存，无结果预览(tp3 已注释)。
      final result =
          await _service.makeHideImage(_topBytes!, _bottomBytes!);
      if (!mounted) return;
      setState(() => _generating = false);
      if (result == null) {
        // 对齐安卓: savedFile == null 时仅关闭弹窗，无提示。
        return;
      }
      // 保存到系统图库(SaveButton 安全组件流程)；文件名对齐安卓 Image-HH-mm-ss。
      try {
        await DocumentExportService()
            .exportBytesToGallery(result, name: _imageStamp());
        if (!mounted) return;
        _toast('保存成功');
      } on GalleryExportException catch (e) {
        if (!mounted) return;
        // 用户主动取消不当作错误提示。
        if (!e.isCanceled) _toast('保存失败：${e.message}');
      } catch (e) {
        if (!mounted) return;
        _toast('保存失败：$e');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _generating = false);
      _toast('生成失败');
    }
  }

  /// 对齐安卓保存命名 Image-HH-mm-ss。
  String _imageStamp() {
    final now = DateTime.now();
    return 'Image-${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B79FF), // 对齐 pic_toolslibrary appbarColor
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('隐藏图制作',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // 两张图片卡(高 220dp,背景 #F5F5F5,描边,圆角)
              SizedBox(
                height: 220,
                child: Row(children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: _imageCard(_topBytes))),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: _imageCard(_bottomBytes))),
                ]),
              ),
              const SizedBox(height: 4),
              // 上层/下层选图按钮(黑底白字)
              Row(children: [
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: _blackButton(
                            '上层图片', () => _pickImage(top: true)))),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: _blackButton(
                            '下层图片', () => _pickImage(top: false)))),
              ]),
            ],
          ),
        ),
        // 对齐 fab: 两图就绪后底部出现通宽"生成图片"。
        if (_bothReady)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SizedBox(
              height: 48,
              child: MaterialButton(
                onPressed: _generating ? null : _generate,
                color: const Color(0xFF1B2630),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child: const Text('生成图片',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        if (_generating)
          // 对齐安卓 LoadingDialog。
          Container(
            color: const Color(0x66000000),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: Color(0xFF9B79FF)),
          ),
      ]),
    );
  }

  Widget _imageCard(Uint8List? bytes) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: bytes == null
          ? Center(
              child: Image.asset(AppAssets.otherScanNullImg,
                  width: 60, height: 60, color: const Color(0xFFBDBDBD)),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
    );
  }

  Widget _blackButton(String label, VoidCallback onTap) {
    return MaterialButton(
      onPressed: onTap,
      color: const Color(0xFF1B2630), // 对齐 backgroundTint black
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      height: 44,
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }
}
