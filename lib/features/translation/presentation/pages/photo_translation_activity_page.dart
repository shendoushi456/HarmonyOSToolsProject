import 'package:camera/camera.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:harmonyos_flutter_empty/core/theme/app_colors.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/providers/ocr_translation_provider.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/states/ocr_translation_ui_state.dart';

/// 拍照翻译功能页
///
/// 对应原 Android `PhotoTranslationActivity`，使用 camera 插件实现：
/// - 相机实时预览（CameraPreview）
/// - 拍照按钮（takePicture → OCR）
/// - 相册导入（file_selector → OCR）
///
/// 去掉了原项目的"拍照点菜"Tab，仅保留"拍照翻译"功能。
class PhotoTranslationActivityPage extends ConsumerStatefulWidget {
  const PhotoTranslationActivityPage({super.key});

  @override
  ConsumerState<PhotoTranslationActivityPage> createState() =>
      _PhotoTranslationActivityPageState();
}

class _PhotoTranslationActivityPageState
    extends ConsumerState<PhotoTranslationActivityPage>
    with WidgetsBindingObserver {
  static const MethodChannel _cameraPermissionChannel = MethodChannel(
    'hm.ruisi.saosaole/camera_permission',
  );
  static const String _cameraPermissionDeniedKey =
      'photo_translation_camera_permission_denied';

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isInitializingCamera = false;
  bool _isRequestingCameraPermission = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ocrTranslationNotifierProvider.notifier).reloadLanguages();
    });
  }

  /// 初始化相机
  Future<void> _initCamera() async {
    if (_isInitializingCamera || _isCameraInitialized) {
      return;
    }
    _isInitializingCamera = true;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _cameraError = '未找到相机');
        }
        return;
      }
      // 优先使用后置摄像头
      final backCamera = cameras.firstWhere(
        (CameraDescription c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      await _cameraController?.dispose();
      _cameraController = controller;
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _cameraError = null;
        });
      }
    } on Exception catch (_) {
      if (mounted) {
        setState(() => _cameraError = '相机初始化失败，请检查权限');
      }
    } finally {
      _isInitializingCamera = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController = null;
      controller.dispose();
      if (mounted) {
        setState(() => _isCameraInitialized = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  /// 点击拍照时才查询/申请相机权限。拒绝状态只保存在应用数据中，
  /// 因此清除数据或重新安装应用后会自动恢复为可申请状态。
  Future<void> _onCapturePressed() async {
    // 相机已就绪时才是真正的拍照操作。首次点击只负责授权并打开预览，
    // 让用户确认取景画面后再点击一次拍照。
    if (_isCameraInitialized) {
      await _captureAndTranslate();
      return;
    }
    if (_isRequestingCameraPermission) {
      return;
    }
    _isRequestingCameraPermission = true;
    try {
      await _requestPermissionAndOpenCamera();
    } finally {
      _isRequestingCameraPermission = false;
    }
  }

  Future<void> _requestPermissionAndOpenCamera() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_cameraPermissionDeniedKey) ?? false) {
      _showToast('获取相机权限被拒绝');
      return;
    }

    try {
      final granted = await _cameraPermissionChannel.invokeMethod<bool>(
        'requestCameraPermission',
      );
      if (granted != true) {
        await prefs.setBool(_cameraPermissionDeniedKey, true);
        if (mounted) {
          _showToast('获取相机权限被拒绝');
        }
        return;
      }
    } on PlatformException {
      await prefs.setBool(_cameraPermissionDeniedKey, true);
      if (mounted) {
        _showToast('获取相机权限被拒绝');
      }
      return;
    }

    await _initCamera();
  }

  /// 已经完成授权和初始化后拍照并翻译。
  Future<void> _captureAndTranslate() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      _showToast('相机未就绪');
      return;
    }
    try {
      final image = await controller.takePicture().timeout(
            const Duration(seconds: 20000),
            onTimeout: () => throw Exception('拍照超时，请重试'),
          );
      await _translateImage(image);
    } on Exception catch (error) {
      final message = error.toString();
      _showToast(
        message.startsWith('Exception: ')
            ? message.substring('Exception: '.length)
            : '拍照失败',
      );
    }
  }

  /// 相册导入并翻译
  Future<void> _pickImage() async {
    final XFile? file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[
        XTypeGroup(
          label: '图片',
          extensions: ['jpg', 'jpeg', 'png', 'bmp'],
        ),
      ],
    );
    if (file != null) {
      await _translateImage(file);
    }
  }

  /// 翻译图片并处理结果
  ///
  /// 直接在调用后检查 state，不依赖 ref.listen（避免时序问题）。
  Future<void> _translateImage(XFile file) async {
    try {
      await ref
          .read(ocrTranslationNotifierProvider.notifier)
          .translateImageFromFile(file);
    } on Object catch (e) {
      debugPrint('translateImageFromFile threw: $e');
    }
    if (!mounted) {
      debugPrint('Widget not mounted after translation');
      return;
    }
    final uiState = ref.read(ocrTranslationNotifierProvider);
    debugPrint(
      'Post-translation state: '
      'isLoading=${uiState.isLoading}, '
      'hasResult=${uiState.translationResult != null}, '
      'hasError=${uiState.errorMessage != null}, '
      'error=${uiState.errorMessage}',
    );
    if (uiState.translationResult != null) {
      final result = uiState.translationResult!;
      ref.read(ocrTranslationNotifierProvider.notifier).clearResult();
      await context.push('/contrast_translation', extra: <String, dynamic>{
        'sourceText': result.originalText,
        'translatedText': result.translatedText,
        'title': '拍照翻译',
      });
    } else if (uiState.errorMessage != null) {
      final message = uiState.errorMessage!;
      ref.read(ocrTranslationNotifierProvider.notifier).clearError();
      _showToast(message);
    } else {
      // 兜底：state 既没有 result 也没有 error，显示通用提示
      _showToast('翻译未返回结果，请重试');
    }
  }

  Future<void> _navigateToLangSwitch(int selectionType) async {
    await context.push('/lang_switch', extra: <String, dynamic>{
      'selectionType': selectionType,
    });
    if (mounted) {
      await ref.read(ocrTranslationNotifierProvider.notifier).reloadLanguages();
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(ocrTranslationNotifierProvider);

    // 使用 Scaffold 包裹，确保 ScaffoldMessenger.of(context) 能正确显示 SnackBar
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildLanguageSelectorBar(uiState),
                const SizedBox(height: 18),
                Expanded(child: _buildCameraPreview()),
                _buildBottomControlArea(),
              ],
            ),
            if (uiState.isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  /// 顶部语言选择栏
  Widget _buildLanguageSelectorBar(OcrTranslationUiState uiState) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: SizedBox(
        height: 30,
        child: Row(
          children: [
            // 返回按钮
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () => context.pop(),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.only(right: 38),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            // 源语言
            GestureDetector(
              onTap: () => _navigateToLangSwitch(0),
              child: SizedBox(
                width: 80,
                height: 30,
                child: Center(
                  child: Text(
                    uiState.fromLanguage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            // 交换图标
            Image.asset(
              'assets/images/ic_trans_switch.png',
              width: 20,
              height: 20,
              fit: BoxFit.fitWidth,
            ),
            const SizedBox(width: 18),
            // 目标语言
            GestureDetector(
              onTap: () => _navigateToLangSwitch(1),
              child: SizedBox(
                width: 80,
                height: 30,
                child: Center(
                  child: Text(
                    uiState.toLanguage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 相机预览区
  Widget _buildCameraPreview() {
    if (_cameraError != null) {
      return Container(
        width: double.infinity,
        color: const Color(0xFF232323),
        alignment: Alignment.center,
        child: Text(
          _cameraError!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0x99FFFFFF),
          ),
        ),
      );
    }
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        width: double.infinity,
        color: const Color(0xFF232323),
        alignment: Alignment.center,
        child: Text(
          _isInitializingCamera ? '正在开启相机...' : '点击下方拍照按钮以开启相机',
          style: const TextStyle(fontSize: 16, color: Color(0x99FFFFFF)),
        ),
      );
    }
    return CameraPreview(_cameraController!);
  }

  /// 底部控制区（拍照按钮 + 相册导入，无 Tab）
  Widget _buildBottomControlArea() {
    return Container(
      color: AppColors.primaryBlue,
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 拍照按钮（居中）
                GestureDetector(
                  onTap: _onCapturePressed,
                  behavior: HitTestBehavior.opaque,
                  child: Image.asset(
                    'assets/images/ic_tran_photograph.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                // 相册导入按钮（右侧）
                Positioned(
                  right: 50,
                  child: GestureDetector(
                    onTap: _pickImage,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/ic_tran_photo.png',
                          width: 26,
                          height: 26,
                          fit: BoxFit.fitWidth,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '相册导入',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 31),
        ],
      ),
    );
  }

  /// Loading 遮罩
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '正在识别...',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
