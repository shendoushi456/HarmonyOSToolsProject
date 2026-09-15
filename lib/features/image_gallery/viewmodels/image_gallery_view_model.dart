import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../scan_menu/viewmodels/scanned_document_view_model.dart';
import '../models/image_gallery_item.dart';

/// 图片库列表状态 - 对齐 ImageGalleryFragment.kt 的 imageList/sortOrder/sortIv
class ImageGalleryState {
  const ImageGalleryState({
    this.items = const [],
    this.isLoading = false,
    this.newestFirst = true,
    // 对齐 XML 初始 src=@drawable/icon_sort -> @mipmap/ic_black_sort
    this.sortIconAsset = AppAssets.igBlackSort,
  });

  final List<ImageGalleryItem> items;
  final bool isLoading;
  final bool newestFirst;
  final String sortIconAsset;

  ImageGalleryState copyWith({
    List<ImageGalleryItem>? items,
    bool? isLoading,
    bool? newestFirst,
    String? sortIconAsset,
  }) {
    return ImageGalleryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      newestFirst: newestFirst ?? this.newestFirst,
      sortIconAsset: sortIconAsset ?? this.sortIconAsset,
    );
  }
}

final imageGalleryViewModelProvider =
    NotifierProvider<ImageGalleryViewModel, ImageGalleryState>(
  ImageGalleryViewModel.new,
);

/// 对齐 ImageGalleryFragment.kt：loadImages/sortImages/排序按钮随机图标
/// 数据源复用 ScannedDocumentRepository(scan_menu/documents 目录)
class ImageGalleryViewModel extends Notifier<ImageGalleryState> {
  @override
  ImageGalleryState build() {
    Future<void>.microtask(refresh);
    return const ImageGalleryState(isLoading: true);
  }

  /// 对齐 loadImages()：列目录图片并按当前顺序排序
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      final documents = await ref
          .read(scannedDocumentRepositoryProvider)
          .loadDocuments(newestFirst: state.newestFirst);
      final items = documents
          .map((doc) => ImageGalleryItem(
                path: doc.path,
                name: doc.name,
                modifiedAt: doc.modifiedAt,
              ))
          .toList();
      state = state.copyWith(items: items, isLoading: false);
    } catch (_) {
      state = state.copyWith(items: const [], isLoading: false);
    }
  }

  /// 对齐 sortIv 点击：Random().nextInt(2) 决定图标(与顺序独立，保真原版行为)，
  /// 随后翻转排序并重排
  void toggleSort() {
    final random = Random().nextInt(2);
    final icon = random == 0 ? AppAssets.igSortOne : AppAssets.igSort;
    state = state.copyWith(
      sortIconAsset: icon,
      newestFirst: !state.newestFirst,
    );
    refresh();
  }

  /// 对齐 PicLookDetailActivity 删除：直接删文件，不改列表
  /// (安卓端返回列表后经 onActivityResult -> loadImages() 才刷新)
  Future<void> delete(ImageGalleryItem item) async {
    final file = File(item.path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
