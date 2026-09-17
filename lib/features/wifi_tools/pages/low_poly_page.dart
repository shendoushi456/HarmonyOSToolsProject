// 特效图页 - 对齐 Android pic_toolslibrary PictureLowPolyActivity + activity_picture_lowpoly.xml
// 白底,Toolbar 居中"LowPoly图片生成"(appbarColor #9B79FF),灰底圆角图片区(ic_null_img 空态),
// 精度 seekbar(600~2400 默认1200,指示#E5E5E5 进度黑),3 个黑色圆角按钮: 选择图片/生成图片/保存图片
// 生成对齐 StartPolyFun(Dart 版见 low_poly_service);保存对齐 UtilsPic.SaveImage 存 /姿洛/LowPoly图片/
// 广告(CSJ 插屏)与 junkcode 已排除
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_assets.dart';
import '../services/low_poly_service.dart';

class LowPolyPage extends StatefulWidget {
  const LowPolyPage({super.key});

  @override
  State<LowPolyPage> createState() => _LowPolyPageState();
}

class _LowPolyPageState extends State<LowPolyPage> {
  final ImagePicker _picker = ImagePicker();
  final LowPolyService _service = LowPolyService.instance;

  Uint8List? _sourceBytes;
  Uint8List? _resultBytes;
  double _precision = 1200; // 对齐 PolyfunKey.pc 默认
  bool _generating = false;

  Future<void> _pickImage() async {
    // 对齐安卓: GET_CONTENT 单选,过大提示由服务端 maxSide 控制等效
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _sourceBytes = bytes;
      _resultBytes = null;
    });
  }

  Future<void> _generate() async {
    if (_sourceBytes == null) {
      _toast('请先选择图片');
      return;
    }
    setState(() => _generating = true);
    // 对齐 StartPolyFun 线程: 耗时计算放后台
    try {
      final result = await _service.generate(_sourceBytes!, _precision.toInt());
      if (!mounted) return;
      setState(() {
        _resultBytes = result;
        _generating = false;
      });
      _toast(result != null ? '生成完成' : '生成失败');
    } catch (_) {
      if (!mounted) return;
      setState(() => _generating = false);
      _toast('生成失败');
    }
  }

  Future<void> _save() async {
    if (_resultBytes == null) {
      _toast('请先生成图片');
      return;
    }
    // 对齐 UtilsPic.SaveImage: /姿洛/LowPoly图片/Image-HH-mm-ss.png
    final saved = await _saveToDocDir(_resultBytes!);
    if (!mounted) return;
    _toast(saved ? '保存成功' : '保存失败');
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
        title: const Text('LowPoly图片生成',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: _generating
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF9B79FF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 图片区(灰底圆角,空态 ic_null_img+请先选择图片)
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5), // 对齐 gray_round_bg
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _previewImage(),
                  ),
                  const SizedBox(height: 20),
                  // 精度行(对齐 DiscreteSeekBar 600~2400 默认1200)
                  Row(
                    children: [
                      const Text('精度',
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      Expanded(
                        child: Slider(
                          value: _precision,
                          min: 600,
                          max: 2400,
                          divisions: 36,
                          activeColor: Colors.black,
                          inactiveColor: const Color(0xFFE5E5E5),
                          label: _precision.toInt().toString(),
                          onChanged: (v) => setState(() => _precision = v),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(_precision.toInt().toString(),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 三按钮(黑色圆角 20,对齐 MaterialButton cornerRadius 20dp)
                  Row(
                    children: [
                      _blackButton('选择图片', _pickImage),
                      const SizedBox(width: 10),
                      _blackButton('生成图片', _generate),
                      const SizedBox(width: 10),
                      _blackButton('保存图片', _save),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _previewImage() {
    if (_resultBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(_resultBytes!, fit: BoxFit.contain),
      );
    }
    if (_sourceBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(_sourceBytes!, fit: BoxFit.contain),
      );
    }
    // 对齐空态: ic_null_img 98dp + "请先选择图片" 18sp
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAssets.wifiToolsNullImg, width: 98, height: 98),
          const SizedBox(height: 10),
          const Text('请先选择图片',
              style: TextStyle(color: Color(0xFF757575), fontSize: 18)),
        ],
      ),
    );
  }

  Widget _blackButton(String label, VoidCallback onTap) {
    return Expanded(
      child: MaterialButton(
        onPressed: onTap,
        color: const Color(0xFF1B2630), // 对齐 success 色黑底
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        height: 44,
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));
  }

  Future<bool> _saveToDocDir(Uint8List bytes) async {
    try {
      final doc = await getApplicationDocumentsDirectory();
      final dir = Directory('${doc.path}/姿洛/LowPoly图片');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final now = DateTime.now();
      final name =
          'Image-${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}.png';
      await File('${dir.path}/$name').writeAsBytes(bytes);
      return true;
    } catch (_) {
      return false;
    }
  }
}
