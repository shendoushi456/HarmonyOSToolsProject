// 旅行页 - 对齐 Android ViewpointFragment.ScreenContent。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../router/route_names.dart';
import '../models/viewpoint_attraction.dart';
import '../viewmodels/viewpoint_view_model.dart';

class ViewpointFragmentPage extends ConsumerWidget {
  const ViewpointFragmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(viewpointViewModelProvider);
    final viewModel = ref.read(viewpointViewModelProvider.notifier);
    const attractions = ViewpointViewModel.attractions;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            AppAssets.toolboxViewpointTopBackground,
            width: double.infinity,
            height: 223,
            fit: BoxFit.fill,
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _Header(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 0, bottom: 16),
                    itemCount: attractions.length,
                    itemBuilder: (context, index) {
                      final attraction = attractions[index];
                      return _AttractionListItem(
                        attraction: attraction,
                        isExpanded: state.expandedIndex == index,
                        onToggle: () => viewModel.toggle(index),
                        onImageTap: () => _openAttraction(context, attraction),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAttraction(BuildContext context, ViewpointAttraction attraction) {
    switch (attraction.destination) {
      case ViewpointDestination.disneyShanghai:
        context.push(RoutePaths.disneyScenic);
        return;
      case ViewpointDestination.disneyHongKong:
        context.push(RoutePaths.hongKongDisneyScenic);
        return;
      case ViewpointDestination.imageGuide:
        context.push(
          RoutePaths.editorPicTips,
          extra: {'type': attraction.guideType},
        );
        return;
      case ViewpointDestination.leshan:
        context.push(RoutePaths.leShanScenic);
        return;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 60,
      child: Center(
        child: Text(
          '热门景点',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _AttractionListItem extends StatelessWidget {
  const _AttractionListItem({
    required this.attraction,
    required this.isExpanded,
    required this.onToggle,
    required this.onImageTap,
  });

  final ViewpointAttraction attraction;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          Semantics(
            button: true,
            label: '${isExpanded ? '收起' : '展开'}${attraction.name}',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attraction.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            attraction.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.toolboxViewpointDescription,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 23, right: 12),
                      child: Image.asset(
                        isExpanded
                            ? AppAssets.toolboxViewpointArrowExpanded
                            : AppAssets.toolboxViewpointArrow,
                        width: 14,
                        height: 9,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            Semantics(
              button: true,
              label: '查看${attraction.name}详情',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onImageTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    attraction.imageAsset,
                    width: double.infinity,
                    height: 155,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
