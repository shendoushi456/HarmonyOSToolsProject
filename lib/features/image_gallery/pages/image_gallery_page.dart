import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_assets.dart';
import '../../home/viewmodels/home_tab_view_model.dart';
import '../models/image_item.dart';
import '../viewmodels/image_gallery_view_model.dart';
import 'image_detail_page.dart';

/// 所有文档页在底部导航中的索引(与 HomeShellPage 的 pages[1] 对应)。
const int kImageGalleryTabIndex = 1;

/// 对齐 Android `ImageGalleryFragment`：
///   标题栏(右侧排序按钮) + 单列 RecyclerView + 空态占位。
///
/// GridLayoutManager 实际为 1 列(与 Android 一致)，列表卡片 68dp 高。
class ImageGalleryPage extends ConsumerWidget {
  const ImageGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // HomeShellPage 使用 IndexedStack 常驻三个 Tab，本页只在 provider 创建时
    // 加载一次；对齐 Android onResume/onActivityResult 的 loadImages()：
    // 每次切到本 Tab 自动刷新列表。
    ref.listen<int>(homeTabIndexProvider, (previous, next) {
      if (next == kImageGalleryTabIndex) {
        ref.read(imageGalleryViewModelProvider.notifier).refresh();
      }
    });
    final state = ref.watch(imageGalleryViewModelProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      body: Stack(
        children: [
          // 全屏背景纹理 - 对应 layout 中 android:background="@drawable/shap_topbar_bg"
          Positioned.fill(
            child: Image.asset(
              AppAssets.tbcShapTopbarBg,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _GalleryTopBar(
                  iconIsSortOne: state.sortIconIsSortOne,
                  onSortTap: () => ref
                      .read(imageGalleryViewModelProvider.notifier)
                      .toggleSort(),
                ),
                Expanded(
                  child: _GalleryBody(state: state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶部 FrameLayout：标题居中 + 排序图标靠右。
class _GalleryTopBar extends StatelessWidget {
  const _GalleryTopBar({
    required this.iconIsSortOne,
    required this.onSortTap,
  });

  final bool iconIsSortOne;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    // padding: top 50 (status bar), left/right 20, bottom 20
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Center(
              child: Text(
                '所有文档',
                style: TextStyle(
                  color: Color(0xFF444444),
                  fontSize: 22,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSortTap,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    iconIsSortOne ? AppAssets.igSortOne : AppAssets.igIcSort,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单列 RecyclerView + 空态占位。
class _GalleryBody extends ConsumerWidget {
  const _GalleryBody({required this.state});
  final ImageGalleryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.loading && state.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF168EC6)),
      );
    }
    if (state.items.isEmpty) {
      return _EmptyView();
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 24),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final image = state.items[index];
        return _ImageListItem(
          image: image,
          onTap: () async {
            final deleted = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: '/image_gallery/detail'),
                builder: (_) => ImageDetailPage(item: image),
              ),
            );
            // 删除返回 true 时刷新列表
            if (deleted == true) {
              await ref
                  .read(imageGalleryViewModelProvider.notifier)
                  .refresh();
            } else {
              // 详情页修改(导出)后也刷新一次，确保文件元数据同步
              await ref
                  .read(imageGalleryViewModelProvider.notifier)
                  .refresh();
            }
          },
        );
      },
    );
  }
}

/// 列表项 - 对齐 item_image_pic.xml：
///   68dp 白色卡片，40dp 圆形缩略图，名称文本 weight=1，右侧 ic_black_enter。
class _ImageListItem extends StatelessWidget {
  const _ImageListItem({required this.image, required this.onTap});
  final ImageItem image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: _Thumbnail(path: image.path),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      image.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Image.asset(
                    AppAssets.igIcBlackEnter,
                    width: 18,
                    height: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 40dp 圆形缩略图 - 对齐 item_image_pic.xml 中
/// `android:background="@drawable/shape_circle" + android:clipToOutline="true"`。
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 40,
        height: 40,
        color: const Color(0xFFF3F3F3),
        alignment: Alignment.center,
        child: Image.file(
          File(path),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.image_outlined,
            color: Color(0xFFB0B0B0),
            size: 22,
          ),
        ),
      ),
    );
  }
}

/// 空态 - 对齐 fragment_image_gallery.xml 的 LinearLayout(empty_ll)
class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.igEmptyIc,
            width: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 4),
          const Text(
            '暂无文档',
            style: TextStyle(
              color: Color(0xFFA6A6A6),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 对外暴露的格式化函数(预览/详情页可以复用)
String formatImageDate(DateTime date) =>
    DateFormat('yyyy-MM-dd HH:mm:ss').format(date);