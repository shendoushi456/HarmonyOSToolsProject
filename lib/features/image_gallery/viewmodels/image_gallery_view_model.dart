import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scan_menu/viewmodels/scanned_document_view_model.dart';
import '../models/image_item.dart';
import '../services/image_gallery_service.dart';

/// 复用鸿蒙项目既有的扫描件仓库，避免新写文件 I/O。
final imageGalleryServiceProvider = Provider<ImageGalleryService>((ref) {
  return ImageGalleryService(ref.watch(scannedDocumentRepositoryProvider));
});

/// 排序顺序 - 对齐 Android `SortOrder` 枚举。
enum GallerySortOrder { newestFirst, oldestFirst }

/// 图片库列表 view model。
///
/// 沿用 Android 的加载/排序语义：
/// - 默认按最新在前加载；
/// - 排序按钮随机切换 ic_sort / sort_one 图标(原 Kotlin 代码中两个图标独立随机，
///   与顺序无关，迁移时保留这一行为)。
class ImageGalleryViewModel extends StateNotifier<ImageGalleryState> {
  ImageGalleryViewModel(this._service) : super(const ImageGalleryState()) {
    refresh();
  }

  final ImageGalleryService _service;

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    try {
      final items = await _service.loadImages(
        newestFirst: state.sortOrder == GallerySortOrder.newestFirst,
      );
      state = state.copyWith(items: items, loading: false);
    } catch (_) {
      state = state.copyWith(items: const [], loading: false);
    }
  }

  /// Android 端：每次点击图标随机挑选 ic_sort/sort_one，且 sortOrder 翻转。
  /// 这里保留这一行为，让迁移 UI 还原原始交互(包含原 Bug 的可观察表现)。
  Future<void> toggleSort() async {
    final nextOrder =
        state.sortOrder == GallerySortOrder.newestFirst
            ? GallerySortOrder.oldestFirst
            : GallerySortOrder.newestFirst;
    final nextIcon = _randomIcon();
    state = state.copyWith(
      sortOrder: nextOrder,
      sortIconIsSortOne: nextIcon,
      loading: true,
    );
    try {
      final items = await _service.loadImages(newestFirst: nextOrder == GallerySortOrder.newestFirst);
      state = state.copyWith(items: items, loading: false);
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> deleteItem(String path) async {
    await _service.delete(path);
    await refresh();
  }

  /// 与 Android `Random().nextInt(2)` 一致：0 → sort_one，1 → ic_sort。
  bool _randomIcon() {
    return DateTime.now().microsecondsSinceEpoch % 2 == 0;
  }
}

class ImageGalleryState {
  const ImageGalleryState({
    this.items = const <ImageItem>[],
    this.sortOrder = GallerySortOrder.newestFirst,
    this.sortIconIsSortOne = false,
    this.loading = false,
  });

  final List<ImageItem> items;
  final GallerySortOrder sortOrder;

  /// 当前排序图标是 sort_one（true）还是 ic_sort（false）。
  /// 与顺序独立，每次点击随机切换，对齐 Android 原实现。
  final bool sortIconIsSortOne;
  final bool loading;

  ImageGalleryState copyWith({
    List<ImageItem>? items,
    GallerySortOrder? sortOrder,
    bool? sortIconIsSortOne,
    bool? loading,
  }) {
    return ImageGalleryState(
      items: items ?? this.items,
      sortOrder: sortOrder ?? this.sortOrder,
      sortIconIsSortOne: sortIconIsSortOne ?? this.sortIconIsSortOne,
      loading: loading ?? this.loading,
    );
  }
}

final imageGalleryViewModelProvider =
    StateNotifierProvider<ImageGalleryViewModel, ImageGalleryState>((ref) {
  return ImageGalleryViewModel(ref.watch(imageGalleryServiceProvider));
});