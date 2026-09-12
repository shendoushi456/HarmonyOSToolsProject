// CategoryDrawPage - 分类涂鸦填色页
// 对齐 Android MainActivityTwo.java（776 行）+ activity_main_two.xml
// 完整保真：17 色 + flask 色轮 + 背景音乐 + 点击音 + 缩放 + FloodFill + 撤销到空重启
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../scan_menu/services/document_export_service.dart';
import '../../viewmodels/category_draw_state.dart';
import '../../viewmodels/category_draw_view_model.dart';

class CategoryDrawPage extends ConsumerStatefulWidget {
  const CategoryDrawPage({
    super.key,
    required this.code,
    required this.position,
  });

  final int code;
  final int position;

  static Future<void> push(
    BuildContext context, {
    required int code,
    required int position,
  }) =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDrawPage(code: code, position: position),
        ),
      );

  @override
  ConsumerState<CategoryDrawPage> createState() => _CategoryDrawPageState();
}

class _CategoryDrawPageState extends ConsumerState<CategoryDrawPage> {
  AudioPlayer? _bgPlayer;
  AudioPlayer? _clickPlayer;

  @override
  void initState() {
    super.initState();
    // 初始化线稿（对齐 MainActivityTwo:482-484 加载 gp{code}_{position}）
    Future.microtask(() => ref
        .read(categoryDrawViewModelProvider.notifier)
        .initImage(widget.code, widget.position));
    // 启动背景音乐（对齐 MainActivityTwo.onResume:423-434 循环播放 background_1）
    _initBgMusic();
  }

  Future<void> _initBgMusic() async {
    _bgPlayer = AudioPlayer();
    try {
      await _bgPlayer!.setAsset('assets/sounds/background_1.mp4');
      await _bgPlayer!.setLoopMode(LoopMode.one);
      await _bgPlayer!.play();
    } catch (_) {
      // 音频加载失败忽略，不影响填色功能
    }
  }

  Future<void> _playClick() async {
    _clickPlayer ??= AudioPlayer();
    try {
      await _clickPlayer!.setAsset('assets/sounds/click.wav');
      await _clickPlayer!.play();
    } catch (_) {}
  }

  @override
  void dispose() {
    _bgPlayer?.dispose();
    _clickPlayer?.dispose();
    super.dispose();
  }

  void _fillAt(Offset local, Size viewport) async {
    final state = ref.read(categoryDrawViewModelProvider);
    if (state.currentBytes == null || state.isFilling) return;
    // 坐标换算（对齐 MainActivityTwo:519 缩放 + :586-673 transformCoordToBitmap）
    final scale = (state.imageWidth / viewport.width >
            state.imageHeight / viewport.height)
        ? viewport.width / state.imageWidth
        : viewport.height / state.imageHeight;
    final displayed = Size(state.imageWidth * scale, state.imageHeight * scale);
    final left = (viewport.width - displayed.width) / 2;
    final top = (viewport.height - displayed.height) / 2;
    final x = ((local.dx - left) / scale).floor();
    final y = ((local.dy - top) / scale).floor();
    if (x < 0 || y < 0 || x >= state.imageWidth || y >= state.imageHeight) {
      return;
    }
    await _playClick();
    await ref.read(categoryDrawViewModelProvider.notifier).fillAt(x, y);
  }

  void _undo() async {
    // 保真 Bug 4：撤销到空时重启 Activity（对齐 MainActivityTwo:559-563）
    final needRestart =
        await ref.read(categoryDrawViewModelProvider.notifier).undo();
    if (needRestart && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CategoryDrawPage(code: widget.code, position: widget.position),
        ),
      );
    }
  }

  Future<void> _save() async {
    final bytes = ref.read(categoryDrawViewModelProvider).currentBytes;
    if (bytes == null) return;
    try {
      await DocumentExportService().exportBytesToGallery(
        bytes,
        name: '分类涂鸦-${DateTime.now().millisecondsSinceEpoch}',
      );
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
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$error')),
        );
      }
    }
  }

  void _toggleMusic() {
    final state = ref.read(categoryDrawViewModelProvider);
    ref.read(categoryDrawViewModelProvider.notifier).toggleBgMusic();
    if (state.bgMusicOn) {
      _bgPlayer?.pause();
    } else {
      _bgPlayer?.play();
    }
  }

  Future<void> _pickCustomColor() async {
    // flask ColorPickerDialogBuilder 等价物 - 对齐 MainActivityTwo.select_color
    // （对齐 master_lexiongtuhua：StatefulBuilder 维持色盘实时刷新，
    //   确定按钮才回传颜色；当前分支旧写法 onColorChanged 直接 pop 导致
    //   滑动选色立即关窗、上色颜色与所见不一致）
    final state = ref.read(categoryDrawViewModelProvider);
    var selectedColor = state.currentColor;
    final selected = await showDialog<Color>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('选择颜色'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                setDialogState(() => selectedColor = color);
              },
              pickerAreaHeightPercent: 0.7,
              displayThumbColor: true,
              enableAlpha: false,
              paletteType: PaletteType.hsv,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, selectedColor),
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      ref.read(categoryDrawViewModelProvider.notifier).setColor(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryDrawViewModelProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(state),
            Expanded(child: _buildCanvas(state)),
            _buildColorRow(state, _row1Colors),
            _buildColorRow(state, _row2Colors, showCustomPicker: true),
          ],
        ),
      ),
    );
  }

  /// 顶栏 - 对齐 activity_main_two.xml:28-67
  /// 返回 + 撤销 + 音乐 + 保存
  Widget _buildTopBar(CategoryDrawState state) {
    return Container(
      height: 50,
      color: const Color(0xFF352570),
      child: Row(
        children: [
          IconButton(
            icon:
                Image.asset(AppAssets.categoryDrawBack, width: 24, height: 24),
            onPressed: () => Navigator.maybePop(context),
          ),
          const Spacer(),
          IconButton(
            icon:
                Image.asset(AppAssets.categoryDrawUndo, width: 24, height: 24),
            onPressed: state.drawnPoints.isEmpty ? null : _undo,
          ),
          // IconButton(
          //   icon: Image.asset(
          //     state.bgMusicOn
          //         ? AppAssets.categoryDrawSoundOn
          //         : AppAssets.categoryDrawSoundOff,
          //     width: 24,
          //     height: 24,
          //   ),
          //   onPressed: _toggleMusic,
          // ),
          IconButton(
            icon:
                Image.asset(AppAssets.categoryDrawSave, width: 24, height: 24),
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  /// 画布 - 对齐 activity_main_two.xml:233-253 relative_layout + coringImage
  Widget _buildCanvas(CategoryDrawState state) {
    if (state.currentBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: Image.memory(
                  state.currentBytes!,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => _fillAt(details.localPosition, viewport),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            if (state.isFilling)
              const Positioned(
                top: 12,
                right: 12,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        );
      },
    );
  }

  /// 17 色按钮行 - 对齐 activity_main_two.xml:68-226
  Widget _buildColorRow(
    CategoryDrawState state,
    List<Color> colors, {
    bool showCustomPicker = false,
  }) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          for (final c in colors)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(categoryDrawViewModelProvider.notifier).setColor(c);
                  _playClick();
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: c == state.currentColor
                        ? Border.all(width: 3, color: Colors.black54)
                        : null,
                  ),
                ),
              ),
            ),
          if (showCustomPicker)
            Expanded(
              child: GestureDetector(
                onTap: _pickCustomColor,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.red,
                        Colors.yellow,
                        Colors.green,
                        Colors.blue,
                        Colors.purple,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 第一行 8 色 - 对齐 activity_main_two.xml:68-147
  /// 保真 Bug 3：deep_purple 实际值 #ebab7f（命名紫色实际橙色）
  static const _row1Colors = [
    AppColors.categoryDeepOrange, // #FF9800
    AppColors.categoryLightPink, // #FF80AB
    AppColors.categoryLightGreen, // #8BC34A
    AppColors.categoryYellow, // #FFEB3B
    AppColors.categoryLightBlue, // #03A9F4
    AppColors.categoryDeepPurple, // #EBAB7F 保真 Bug：命名紫实际橙
    AppColors.categoryLightOrange, // #FFE39F
    AppColors.categoryWhite, // #FFFFFF
  ];

  /// 第二行 8 色 - 对齐 activity_main_two.xml:148-226
  static const _row2Colors = [
    AppColors.categoryRed, // #E53935
    AppColors.categoryDeepPink, // #D81B60
    AppColors.categoryDeepGreen, // #2E7D32
    AppColors.categoryLightPurple, // #9C27B0
    AppColors.categoryDeepBlue, // #303F9F
    AppColors.categoryBrown, // #795548
    AppColors.categoryGray, // #757575
    AppColors.categoryBlack, // #000000
  ];
}
