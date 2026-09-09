import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../image_process/models/image_process_type.dart';
import '../../image_process/pages/image_process_page.dart';
import '../../portable_tools/pages/clear_capture_page.dart';
import '../../recognition/models/recognition_type.dart';
import '../../recognition/pages/recognition_page.dart';
import '../../scan_menu/pages/currency_converter_page.dart';
import '../viewmodels/image_tools_view_model.dart';

/// ImageToolsFragment 的 Flutter 迁移页。
/// 布局与 Android fragment_image_tools.xml 对齐，功能入口复用现有实现。
class ImageToolsPage extends StatelessWidget {
  const ImageToolsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF1A1B23),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(onSettings: () => context.push(RoutePaths.setting)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Column(
                    children: [
                      _StyleTransferCard(
                        onTap: () => _pushImageProcess(
                            context, ImageProcessType.styleTransfer),
                      ),
                      const SizedBox(height: 20),
                      _RecognitionGrid(
                        onTap: (item) => _open(context, item.destination),
                      ),
                      const SizedBox(height: 20),
                      _UtilityCard(
                        onTap: (item) => _open(context, item.destination),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  static void _open(BuildContext context, ImageToolsDestination destination) {
    switch (destination) {
      case ImageToolsDestination.styleTransfer:
        _pushImageProcess(context, ImageProcessType.styleTransfer);
        return;
      case ImageToolsDestination.plant:
        _pushRecognition(context, RecognitionType.plant);
        return;
      case ImageToolsDestination.fruit:
        _pushRecognition(context, RecognitionType.ingredient);
        return;
      case ImageToolsDestination.animal:
        _pushRecognition(context, RecognitionType.animal);
        return;
      case ImageToolsDestination.bankCard:
        _pushRecognition(context, RecognitionType.bankCard);
        return;
      case ImageToolsDestination.magnifier:
        ClearCapturePage.push(context);
        return;
      case ImageToolsDestination.currency:
        CurrencyConverterPage.push(context);
        return;
    }
  }

  static void _pushRecognition(BuildContext context, RecognitionType type) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => RecognitionPage(type: type)),
    );
  }

  static void _pushImageProcess(BuildContext context, ImageProcessType type) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ImageProcessPage(type: type)),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: Stack(
          children: [
            const Center(
              child: Text(
                '工具',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: InkResponse(
                  onTap: onSettings,
                  radius: 22,
                  child: Image.asset(
                    AppAssets.imageToolsSettings,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _StyleTransferCard extends StatelessWidget {
  const _StyleTransferCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        height: 220,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
            image: AssetImage(AppAssets.imageToolsStyleBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              left: 24,
              top: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '图像风格转换',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '换种风格\n解锁图像新模样',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              top: 24 + 24 + 18 + 34 + 45,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 208,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    '点击转换',
                    style: TextStyle(
                      color: Color(0xFFFF6B9D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 24,
              top: 10,
              child: Image.asset(
                AppAssets.imageToolsStyleHero,
                width: 120,
                height: 120,
              ),
            ),
          ],
        ),
      );
}

class _RecognitionGrid extends StatelessWidget {
  const _RecognitionGrid({required this.onTap});

  final ValueChanged<ImageToolsRecognitionItem> onTap;

  @override
  Widget build(BuildContext context) {
    const items = ImageToolsViewModel.recognitionItems;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _RecognitionCard(item: items[0], onTap: onTap)),
            const SizedBox(width: 12),
            Expanded(child: _RecognitionCard(item: items[1], onTap: onTap)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _RecognitionCard(item: items[2], onTap: onTap)),
            const SizedBox(width: 12),
            Expanded(child: _RecognitionCard(item: items[3], onTap: onTap)),
          ],
        ),
      ],
    );
  }
}

class _RecognitionCard extends StatelessWidget {
  const _RecognitionCard({required this.item, required this.onTap});

  final ImageToolsRecognitionItem item;
  final ValueChanged<ImageToolsRecognitionItem> onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => onTap(item),
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Image.asset(item.asset, width: 40, height: 40),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _UtilityCard extends StatelessWidget {
  const _UtilityCard({required this.onTap});

  final ValueChanged<ImageToolsListItem> onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _UtilityRow(
                item: ImageToolsViewModel.utilityItems[0],
                onTap: onTap,
              ),
              const SizedBox(height: 16),
              _UtilityRow(
                item: ImageToolsViewModel.utilityItems[1],
                onTap: onTap,
              ),
            ],
          ),
        ),
      );
}

class _UtilityRow extends StatelessWidget {
  const _UtilityRow({required this.item, required this.onTap});

  final ImageToolsListItem item;
  final ValueChanged<ImageToolsListItem> onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onTap(item),
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              Image.asset(item.asset, width: 48, height: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                AppAssets.imageToolsActionHint,
                width: 100,
                height: 32,
                fit: BoxFit.fill,
              ),
            ],
          ),
        ),
      );
}
