// 自制二维码页 - 对齐 Android smalltoolslibrary QRCodeActivity + activity_third_qr_code.xml
// 白底,Toolbar 标题"二维码生成"(appbarColor/blue/zts #F6C766),内容输入+无LOGO/有LOGO 切换
// +前景/背景色卡(默认 #000000/#FF0000,色轮选择)+尺寸 seekbar(96~960 默认512)
// +FAB 生成(zts 底 touch_app 图标)→预览弹窗(9/10 屏宽)→确定直接保存
// /工具箱/二维码生成/Image-HH-mm-ss.png(fileType=0 分支,原版不跳 QrCodeSaveEndActivity)
// 数据层复用 qrGenerateViewModelProvider(早前迁移已对齐 QRCodeActivity)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../menu_home/viewmodels/qr_generate_state.dart';
import '../../menu_home/viewmodels/qr_generate_view_model.dart';
import '../../scan_menu/services/document_export_service.dart';
import '../widgets/color_picker_dialog.dart';

class QrCodePage extends ConsumerStatefulWidget {
  const QrCodePage({super.key});

  @override
  ConsumerState<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends ConsumerState<QrCodePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 对齐安卓默认: 前景 #000000 / 背景 #FF0000(VM 默认白底,此处校正为原版红底)
    Future.microtask(() {
      ref.read(qrGenerateViewModelProvider.notifier).setBackgroundColor(
            const Color(0xFFFF0000),
          );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrGenerateViewModelProvider);
    final vm = ref.read(qrGenerateViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6C766), // 对齐 smalltoolslibrary appbarColor
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('二维码生成',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF6C766), // 对齐 zts
        child: const Icon(Icons.touch_app, color: Colors.black),
        onPressed: () => _onGenerate(state.inputText.isEmpty),
      ),
      body: state.showPreviewDialog && state.generatedQrBytes != null
          ? _buildPreview(context, state)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 内容输入(对齐 TextInputLayout OutlinedBox.Dense + text_fields 图标)
                  TextField(
                    controller: _controller,
                    onChanged: vm.setInputText,
                    decoration: InputDecoration(
                      hintText: '请输入二维码内容',
                      prefixIcon: const Icon(Icons.text_fields),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorText:
                          state.inputText.isEmpty && _controller.text.isEmpty
                              ? null
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 无LOGO/有LOGO 切换(对齐 MaterialButtonToggleGroup)
                  Row(
                    children: [
                      _toggleButton('无LOGO', state.logoPath == null,
                          () => vm.clearLogo()),
                      const SizedBox(width: 10),
                      _toggleButton('有LOGO', state.logoPath != null, () async {
                        await vm.pickLogo();
                      }),
                    ],
                  ),
                  if (state.logoPath != null) ...[
                    const SizedBox(height: 12),
                    // LOGO 卡(对齐「LOGO图片/请选择二维码的LOGO图片」+选择按钮)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50), // itemBackColor
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('LOGO图片/请选择二维码的LOGO图片',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12)),
                          ),
                          TextButton(
                            onPressed: () async {
                              await vm.pickLogo();
                            },
                            child: const Text('选择',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // 前景色/背景色卡
                  Row(
                    children: [
                      _colorCard('前景色', state.foregroundColor,
                          () => _pickColor(context, state.foregroundColor,
                              (c) => vm.setForegroundColor(c))),
                      const SizedBox(width: 16),
                      _colorCard('背景色', state.backgroundColor,
                          () => _pickColor(context, state.backgroundColor,
                              (c) => vm.setBackgroundColor(c))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 尺寸行(对齐 DiscreteSeekBar 96~960 默认512,进度色 zts)
                  Row(
                    children: [
                      const Text('尺寸',
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      Expanded(
                        child: Slider(
                          value: state.size < 96 ? 512 : state.size,
                          min: 96,
                          max: 960,
                          divisions: 54,
                          activeColor: const Color(0xFF6FBFFF), // zts
                          inactiveColor: const Color(0xFFE5E5E5),
                          label: state.size.toInt().toString(),
                          onChanged: vm.setSize,
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(state.size.toInt().toString(),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  /// 生成(FAB): 空内容报错(对齐 setError),否则弹预览
  void _onGenerate(bool isEmpty) {
    if (isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('请输入二维码内容'), duration: Duration(seconds: 1)));
      return;
    }
    ref.read(qrGenerateViewModelProvider.notifier).generate();
  }

  /// 预览弹窗(对齐 MaterialAlertDialog 宽 9/10 屏 + 确定/取消)
  Widget _buildPreview(BuildContext context, QrGenerateState state) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.memory(state.generatedQrBytes!,
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                onPressed: () {
                  ref.read(qrGenerateViewModelProvider.notifier).dismissPreview();
                },
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  // 保存到系统相册(DocumentGalleryPlugin 安全组件授权写入)
                  final bytes = state.generatedQrBytes;
                  if (bytes == null) return;
                  final now = DateTime.now();
                  final name =
                      '二维码_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
                  try {
                    await DocumentExportService()
                        .exportBytesToGallery(bytes, name: name);
                    if (!context.mounted) return;
                    ref
                        .read(qrGenerateViewModelProvider.notifier)
                        .dismissPreview();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('已保存到系统相册'),
                        duration: Duration(seconds: 2)));
                  } on GalleryExportException catch (error) {
                    if (!context.mounted) return;
                    if (!error.isCanceled) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('保存失败：${error.message}'),
                          duration: const Duration(seconds: 2)));
                    }
                  }
                },
                child: const Text('确定'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String label, bool selected, VoidCallback onTap) {
    // 对齐 MaterialButtonToggleGroup: 选中蓝底白字,未选中白底黑字
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF6FBFFF) : Colors.white,
            border: Border.all(color: const Color(0xFF6FBFFF)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.black, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _colorCard(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBDBDBD)),
                ),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickColor(
      BuildContext context, Color initial, ValueChanged<Color> onPicked) async {
    final color = await showColorPickerDialog(context, initial);
    if (color != null) onPicked(color);
  }
}
