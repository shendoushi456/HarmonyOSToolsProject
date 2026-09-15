import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../home/viewmodels/home_tab_view_model.dart';
import '../models/image_gallery_item.dart';
import '../viewmodels/image_gallery_view_model.dart';
import 'image_detail_page.dart';

/// 对齐 toolbox_c ImageGalleryFragment.kt + fragment_image_gallery.xml：
/// ic_sao_main_bg 全屏背景 + "所有文档"顶栏(右侧排序) + 单列 68dp 白卡列表 + 空态
class ImageGalleryPage extends ConsumerWidget {
  const ImageGalleryPage({super.key});

  /// 本页在底部导航中的索引(原 PdfToolsPage 位置)
  static const tabIndex = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageGalleryViewModelProvider);

    // IndexedStack 常驻 Tab 不会自动刷新：切到本 Tab 时重新加载，
    // 对齐 Android onResume -> loadImages()
    ref.listen<int>(homeTabIndexProvider, (previous, next) {
      if (next == tabIndex) {
        ref.read(imageGalleryViewModelProvider.notifier).refresh();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 对齐 FrameLayout 背景 ImageView: image_gallery_background(fitXY)
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
                _buildTopBar(ref, state),
                Expanded(
                  child: Stack(
                    children: [
                      // 对齐 RecyclerView: marginTop 4dp + padding 4dp
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(4),
                          itemCount: state.items.length,
                          itemBuilder: (_, index) => _ImageCard(
                            item: state.items[index],
                            onTap: () => _openDetail(
                              context,
                              ref,
                              state.items[index],
                            ),
                          ),
                        ),
                      ),
                      // 对齐 empty_ll: 居中空态
                      if (state.items.isEmpty && !state.isLoading)
                        const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image(
                                image: AssetImage(AppAssets.igEmpty),
                                width: 164,
                                height: 148,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '暂无文档',
                                style: TextStyle(
                                  color: Color(0xFF444444),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 对齐顶栏: 50dp 标题栏(paddingH20)，"所有文档" 22sp 黑色居中，
  /// 右侧排序图标垂直居中(初始 ic_black_sort 22x20)
  Widget _buildTopBar(WidgetRef ref, ImageGalleryState state) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              '所有文档',
              style: TextStyle(
                color: Colors.black, // color_title_text
                fontSize: 22,
              ),
            ),
            Positioned(
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ref
                    .read(imageGalleryViewModelProvider.notifier)
                    .toggleSort(),
                child: Image.asset(
                  state.sortIconAsset,
                  width: 22,
                  height: state.sortIconAsset == AppAssets.igSortOne ? 22 : 20,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 对齐 openImageDetail(): 进入详情，返回 true(点了返回按钮)后刷新列表，
  /// 对齐 startActivityForResult + onActivityResult -> loadImages()
  Future<void> _openDetail(
    BuildContext context,
    WidgetRef ref,
    ImageGalleryItem item,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ImageDetailPage(item: item)),
    );
    if (result == true) {
      ref.read(imageGalleryViewModelProvider.notifier).refresh();
    }
  }
}

/// 列表项 - 对齐 item_image_pic.xml：68dp 高，shape_card_white 背景拉伸，
/// paddingStart/End 10dp；缩略图 40x40(centerCrop) marginLeft14 +
/// 名称 14sp #444444 marginLeft12(weight1) + ic_black_enter marginEnd12
class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.item, required this.onTap});

  final ImageGalleryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 68,
        // 内容行相对 68dp 卡片垂直居中
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                AppAssets.igShapeCardWhite,
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  // 缩略图(安卓 BitmapFactory inSampleSize=4 + centerCrop)
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: ClipRect(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.file(
                          File(item.path),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox(width: 40, height: 40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    // ic_black_enter 26x42px @xxhdpi -> 8.7x14dp
                    child: Image.asset(
                      AppAssets.igBlackEnter,
                      width: 8.7,
                      height: 14,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
