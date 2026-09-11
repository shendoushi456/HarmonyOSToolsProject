// PDFFragment 工具页 - 对齐 toolbox_c PDFFragment.kt (Compose 版)。
// 顶栏 0xFFC6EBFF 横滑 Tab 栏 + 灰色内容卡(图标126+描述) + 胶囊执行按钮。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../menu_fragment/models/tool_definition.dart';
import '../../menu_fragment/services/tool_navigation_service.dart';
import '../viewmodels/pdf_tools_view_model.dart';

class PdfToolsPage extends ConsumerWidget {
  const PdfToolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(pdfToolsViewModelProvider);
    final vm = ref.read(pdfToolsViewModelProvider.notifier);
    final items = ref.watch(pdfToolItemsProvider);
    final selected = items[selectedIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶栏 - 对齐 AppTopAppBar:0xFFC6EBFF + 状态栏 padding + 50 高居中
          _TopBar(
            items: items,
            selectedIndex: selectedIndex,
            onSelect: vm.select,
          ),
          Expanded(
            // 内容区 - 对齐 verticalScroll + Spacer(23) ... Spacer(26)
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 23, bottom: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PdfContentArea(
                      title: selected.title,
                      description: selected.description,
                      iconAsset: selected.iconAsset,
                      destination: selected.destination,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶栏 - 对齐 AppTopAppBar + PdfToolTabRow:
/// 0xFFC6EBFF 背景,高 50,横滑 Tab 列表(间距 20,水平 padding 20)。
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<PdfToolItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFC6EBFF),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Center(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (_, index) => _TabItem(
                title: items[index].title,
                isSelected: index == selectedIndex,
                onClick: () => onSelect(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab 项 - 对齐 TabItem:
/// 圆角 16,选中 0xFF4DA7D7 白字 Medium,未选中 0xFFC6EBFF 深灰字,
/// padding(13, 5),无水波纹(indication = null)。
class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.title,
    required this.isSelected,
    required this.onClick,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4DA7D7) : const Color(0xFFC6EBFF),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        child: Center(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: isSelected ? Colors.white : const Color(0xFF5A5A5A),
            ),
          ),
        ),
      ),
    );
  }
}

/// 内容区 - 对齐 PdfContentArea:
/// 外层水平 20 padding;灰色卡(0xFFF6F6F6 圆角 10,padding 垂直 130)
/// 内含 126dp 图标 + 20 + 14sp 描述;下方 24 + 胶囊按钮(两侧再缩 20)。
class _PdfContentArea extends StatelessWidget {
  const _PdfContentArea({
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.destination,
  });

  final String title;
  final String description;
  final String iconAsset;
  final ToolDestination destination;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 灰色内容卡
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 130),
            child: Column(
              children: [
                Image.asset(
                  iconAsset,
                  width: 126,
                  height: 126,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 执行按钮 - 对齐 Button:高 40 胶囊(圆角 100),
          // 0xFF97D8FA 白字 16sp Medium,两侧再缩 20,无 elevation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: const Color(0xFF97D8FA),
              borderRadius: BorderRadius.circular(100),
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () =>
                    ToolNavigationService.openDestination(context, destination),
                child: SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
