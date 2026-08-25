import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_assets.dart';
import '../models/scanned_document.dart';
import '../viewmodels/scanned_document_view_model.dart';
import 'document_detail_page.dart';

/// 对齐 ImageGalleryFragment：背景、标题栏、两列文档卡片和时间排序。
class DocumentGalleryPage extends ConsumerWidget {
  const DocumentGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scannedDocumentViewModelProvider);
    final vm = ref.read(scannedDocumentViewModelProvider.notifier);
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(AppAssets.scanHomeBg, fit: BoxFit.fill),
        ),
        SafeArea(
          bottom: false,
          child: Column(children: [
            // 与 Android fragment_image_gallery.xml 的 FrameLayout 等价：
            // 标题居中，排序图标始终占据最右侧独立区域，避免标题与图标重叠。
            SizedBox(
              height: 50,
              child: Row(children: [
                const SizedBox(width: 56),
                const Expanded(
                  child: Center(
                    child: Text('所有文档',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 22,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: IconButton(
                    tooltip: state.newestFirst ? '按最早时间排序' : '按最新时间排序',
                    onPressed: vm.toggleSortOrder,
                    icon: Image.asset(
                      color: const Color(0xFF1E1E1E),
                      state.newestFirst
                          ? AppAssets.scanSortNewest
                          : AppAssets.scanSortOldest,
                      width: 25,
                      height: 25,
                    ),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: vm.refresh,
                child: state.isLoading && state.documents.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.documents.isEmpty
                        ? const _EmptyDocumentList()
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
                            itemCount: state.documents.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 196,
                            ),
                            itemBuilder: (_, index) =>
                                _DocumentCard(document: state.documents[index]),
                          ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _EmptyDocumentList extends StatelessWidget {
  const _EmptyDocumentList();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: const Center(child: _EmptyDocuments()),
          ),
        ],
      ),
    );
  }
}

class _EmptyDocuments extends StatelessWidget {
  const _EmptyDocuments();

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Image.asset(AppAssets.scanDocumentEmpty, width: 126, height: 96),
      const SizedBox(height: 2),
      const Text('暂无文档',
          style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 18)),
    ]);
  }
}

class _DocumentCard extends ConsumerWidget {
  const _DocumentCard({required this.document});
  final ScannedDocument document;

  static const _backgrounds = [
    AppAssets.scanDocumentBlue,
    AppAssets.scanDocumentGreen,
    AppAssets.scanDocumentYellow,
    AppAssets.scanDocumentPurple,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background =
        _backgrounds[document.name.hashCode.abs() % _backgrounds.length];
    // 严格对应 Android item_image_pic.xml：160×176 的彩色文档底图，
    // 两侧 10dp、上 14dp、下 6dp 的条目间距，以及图标和文本的固定位置。
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: 160,
          height: 176,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(background),
              fit: BoxFit.fill,
            ),
          ),
          child: InkWell(
            onTap: () async {
              final changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => DocumentDetailPage(document: document)),
              );
              if (changed == true) {
                await ref
                    .read(scannedDocumentViewModelProvider.notifier)
                    .refresh();
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 56, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(AppAssets.scanDocumentIcon,
                      width: 46, height: 46),
                  const SizedBox(height: 10),
                  Text(document.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 5),
                  Text(
                      DateFormat('yyyy-MM-dd HH:mm')
                          .format(document.modifiedAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
