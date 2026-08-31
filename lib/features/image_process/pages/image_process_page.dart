import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../scan_menu/services/document_export_service.dart';
import '../models/image_process_state.dart';
import '../models/image_process_type.dart';
import '../viewmodels/image_process_view_model.dart';

/// 后置相机预览、拍照、相册选图和结果保存；不包含扫描或扫描动画。
class ImageProcessPage extends ConsumerStatefulWidget {
  const ImageProcessPage({super.key, required this.type});

  final ImageProcessType type;

  @override
  ConsumerState<ImageProcessPage> createState() => _ImageProcessPageState();
}

class _ImageProcessPageState extends ConsumerState<ImageProcessPage>
    with WidgetsBindingObserver {
  static const _permissionChannel = MethodChannel('toolbox.camera/permission');

  CameraController? _camera;
  String? _cameraError;
  bool _initializingCamera = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camera = _camera;
    if (state == AppLifecycleState.inactive &&
        camera?.value.isInitialized == true) {
      _camera = null;
      unawaited(camera!.dispose());
    } else if (state == AppLifecycleState.resumed && _camera == null) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (_initializingCamera || _camera?.value.isInitialized == true) return;
    if (mounted) {
      setState(() {
        _initializingCamera = true;
        _cameraError = null;
      });
    }
    try {
      // 先完成原生运行时授权，再创建 camera_ohos 控制器。首次授权会暂时使
      // Ability 失活；此处的初始化锁会让 resumed 回调复用当前流程，避免预览
      // 在相机会话刚建立时被销毁，从而出现首次进入黑屏。
      final granted = await _permissionChannel
          .invokeMethod<bool>('requestCameraPermission');
      if (granted != true) throw const _ImageProcessCameraException('未获得相机权限');

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw const _ImageProcessCameraException('未找到可用相机');
      }
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      final previous = _camera;
      setState(() {
        _camera = controller;
        _cameraError = null;
      });
      if (previous != null && previous != controller) {
        unawaited(previous.dispose());
      }
    } on _ImageProcessCameraException catch (error) {
      if (mounted) setState(() => _cameraError = error.message);
    } on CameraException catch (error) {
      if (mounted) {
        setState(() => _cameraError = error.description ?? '相机初始化失败');
      }
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() => _cameraError = error.message ?? '相机权限申请失败');
      }
    } catch (_) {
      if (mounted) setState(() => _cameraError = '相机初始化失败，请重试');
    } finally {
      if (mounted) setState(() => _initializingCamera = false);
    }
  }

  Future<void> _select(XFile? source) async {
    if (source == null) return;
    await ref
        .read(imageProcessViewModelProvider(widget.type).notifier)
        .select(File(source.path));
  }

  Future<void> _save() async {
    final bytes =
        ref.read(imageProcessViewModelProvider(widget.type)).resultBytes;
    if (bytes == null || _saving) return;
    setState(() => _saving = true);
    try {
      await DocumentExportService().exportBytesToGallery(
        bytes,
        name: widget.type.title,
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('已保存到系统相册')));
      }
    } on GalleryExportException catch (error) {
      if (mounted) {
        if (!error.isCanceled) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('保存失败：${error.message}')));
        }
      }
    } on FileSystemException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：${error.message}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imageProcessViewModelProvider(widget.type));
    final vm = ref.read(imageProcessViewModelProvider(widget.type).notifier);
    if (state.hasSource) return _buildResult(context, state, vm);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.type.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(children: [
        Positioned.fill(
          child: _camera?.value.isInitialized == true
              ? CameraPreview(_camera!)
              : Center(
                  child: _cameraError == null
                      ? const Column(mainAxisSize: MainAxisSize.min, children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 14),
                          Text('正在打开相机…',
                              style: TextStyle(color: Colors.white)),
                        ])
                      : Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(_cameraError!,
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _initializeCamera,
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white),
                            child: const Text('重试'),
                          ),
                        ]),
                ),
        ),
        _buildCaptureBar(),
      ]),
    );
  }

  Widget _buildCaptureBar() => Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: '从相册选择',
                  onPressed: () async => _select(await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                    maxWidth: 1920,
                  )),
                  icon: const Icon(Icons.photo_library_outlined,
                      color: Colors.white, size: 32),
                ),
                GestureDetector(
                  onTap: () async => _select(await _camera?.takePicture()),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      );

  Widget _buildResult(
    BuildContext context,
    ImageProcessState state,
    ImageProcessViewModel vm,
  ) =>
      Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          title: Text(widget.type.title),
          backgroundColor: const Color(0xFF477AFF),
          foregroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: state.hasResult && !_saving ? _save : null,
              child: Text(_saving ? '保存中' : '保存',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
        body: Column(children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: state.isProcessing
                    ? const Column(mainAxisSize: MainAxisSize.min, children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('正在处理图片…'),
                      ])
                    : InteractiveViewer(
                        child: state.hasResult
                            ? Image.memory(state.resultBytes!,
                                fit: BoxFit.contain)
                            : Image.file(state.sourceFile!,
                                fit: BoxFit.contain),
                      ),
              ),
            ),
          ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(state.errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            ),
          SafeArea(top: false, child: _buildResultActions(state, vm)),
        ]),
      );

  Widget _buildResultActions(
          ImageProcessState state, ImageProcessViewModel vm) =>
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (widget.type.needsStyleSelection)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ImageStyleOption.values
                  .map((style) => ChoiceChip(
                        label: Text(style.label),
                        selected: state.style == style,
                        onSelected: state.isProcessing
                            ? null
                            : (_) => vm.selectStyle(style),
                        selectedColor: const Color(0xFF477AFF),
                        labelStyle: TextStyle(
                          color: state.style == style ? Colors.white : null,
                        ),
                      ))
                  .toList(),
            ),
          if (widget.type.needsStyleSelection) const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state.isProcessing
                    ? null
                    : () async => _select(await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                          maxWidth: 1920,
                        )),
                child: const Text('重新选择'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: state.isProcessing ? null : vm.process,
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF477AFF)),
                child: Text(state.isProcessing ? '处理中…' : '开始转换'),
              ),
            ),
          ]),
        ]),
      );
}

class _ImageProcessCameraException implements Exception {
  const _ImageProcessCameraException(this.message);

  final String message;
}
