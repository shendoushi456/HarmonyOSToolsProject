import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../models/countdown_models.dart';
import '../viewmodels/countdown_view_model.dart';

/// 倒数日首页 UI。
///
/// 对齐 Android CountdownFragment 当前激活的 Nxtx 风格：
/// 顶部标题、置倒数日面板、彩色卡片列表、悬浮添加按钮。
/// 业务逻辑全部在 [CountdownViewModel]，本文件只负责展示与事件收集。
class CountdownPage extends ConsumerWidget {
  const CountdownPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(countdownViewModelProvider);
    final viewModel = ref.read(countdownViewModelProvider.notifier);
    final pinned =
        state.countdowns.where((item) => item.isPinned).toList();
    final normal =
        state.countdowns.where((item) => !item.isPinned).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFD8EFFF),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 92),
                    children: [
                      const _CountdownHeader(),
                      _PinnedCountdownPanel(
                        viewModel: viewModel,
                        pinned: pinned,
                        onAddClick: () =>
                            context.push(RoutePaths.countdownAdd),
                        onOpen: (item) => _showDetails(context, viewModel, item),
                        onDelete: (item) =>
                            _confirmDelete(context, viewModel, item),
                      ),
                      const SizedBox(height: 16),
                      if (normal.isEmpty)
                        _CountdownEmptyCard(
                            onAddClick: () => context.push(RoutePaths.countdownAdd))
                      else
                        ...normal.map((item) => _CountdownListCard(
                              countdown: item,
                              viewModel: viewModel,
                              onOpen: (item) =>
                                  _showDetails(context, viewModel, item),
                              onDelete: (item) =>
                                  _confirmDelete(context, viewModel, item),
                            )),
                    ],
                  ),
                ),
                Positioned(
                  right: 24,
                  bottom: 18,
                  child: GestureDetector(
                    onTap: () => context.push(RoutePaths.countdownAdd),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 51,
                      height: 51,
                      child: Image.asset(AppAssets.countdownAdd),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showDetails(BuildContext context, CountdownViewModel viewModel,
      CountdownItem countdown) {
    final days = viewModel.calculateDaysLeft(countdown);
    final dayText = days >= 0 ? '还有$days天' : '已过${days.abs()}天';
    final repeatText = countdown.isRepeatYearly ? '每年重复' : '不重复';
    final pinnedText = countdown.isPinned ? '已置顶' : '未置顶';
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(countdown.title),
        content: Text(
          '目标日：${_formatFullDate(viewModel.displayTargetDate(countdown))}\n'
          '倒数：$dayText\n状态：$pinnedText · $repeatText',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CountdownViewModel viewModel,
      CountdownItem countdown) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除倒数日'),
        content: Text('确定要删除“${countdown.title}”吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    ).then((accepted) {
      if (accepted == true) {
        viewModel.deleteCountdown(countdown);
      }
    });
  }
}

// ==================== 顶部标题 ====================

class _CountdownHeader extends StatelessWidget {
  const _CountdownHeader();

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: double.infinity,
        height: 67,
        child: Center(
          child: Text(
            '倒数日',
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF222222),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}

// ==================== 置顶面板 ====================

class _PinnedCountdownPanel extends StatelessWidget {
  final List<CountdownItem> pinned;
  final VoidCallback onAddClick;
  final ValueChanged<CountdownItem> onOpen;
  final ValueChanged<CountdownItem> onDelete;

  const _PinnedCountdownPanel({
    required this.viewModel,
    required this.pinned,
    required this.onAddClick,
    required this.onOpen,
    required this.onDelete,
  });

  final CountdownViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.only(top: 14, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D999999),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '置顶倒数日',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF222222),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '在新增页开启置顶',
                  style: TextStyle(fontSize: 11, color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (pinned.isEmpty)
            _AddPinnedCircle(onTap: onAddClick)
          else
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: pinned.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _PinnedCountdownCircle(
                  countdown: pinned[index],
                  viewModel: viewModel,
                  onOpen: onOpen,
                  onDelete: onDelete,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 空置顶态：浅蓝圆形"添加置顶"入口。
class _AddPinnedCircle extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPinnedCircle({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 112,
          height: 112,
          decoration: const BoxDecoration(
            color: Color(0xFFB8DEF7),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+',
                  style: TextStyle(
                    fontSize: 34,
                    height: 1.0,
                    color: Color(0xFF2879DE),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  '添加置顶',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2879DE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// 置顶圆形项：背景图 + 标题/天数/日期。
class _PinnedCountdownCircle extends StatelessWidget {
  final CountdownItem countdown;
  final CountdownViewModel viewModel;
  final ValueChanged<CountdownItem> onOpen;
  final ValueChanged<CountdownItem> onDelete;

  const _PinnedCountdownCircle({
    required this.countdown,
    required this.viewModel,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final days = viewModel.calculateDaysLeft(countdown);
    return GestureDetector(
      onTap: () => onOpen(countdown),
      onLongPress: () => onDelete(countdown),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 112,
        height: 112,
        child: Stack(
          children: [
            Positioned.fill(
              child:
                  Image.asset(AppAssets.countdownPinCircle, fit: BoxFit.fill),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      countdown.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF222222),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        _pinnedDayText(days),
                        style: const TextStyle(
                          fontSize: 23,
                          height: 27 / 23,
                          color: Color(0xFF2879DE),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _formatMonthDay(
                            viewModel.displayTargetDate(countdown)),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF505050),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _pinnedDayText(int days) =>
      days >= 0 ? '$days天' : '已过${days.abs()}天';
}

// ==================== 普通列表卡片 ====================

class _CountdownListCard extends StatelessWidget {
  final CountdownItem countdown;
  final CountdownViewModel viewModel;
  final ValueChanged<CountdownItem> onOpen;
  final ValueChanged<CountdownItem> onDelete;

  const _CountdownListCard({
    required this.countdown,
    required this.viewModel,
    required this.onOpen,
    required this.onDelete,
  });

  /// 颜色索引映射卡片背景：1=绿 2=橙 其他=蓝 - 对齐 Android colorIndex 规则。
  String _cardAsset(int colorIndex) {
    final index = colorIndex < 0 ? 0 : (colorIndex > 2 ? 2 : colorIndex);
    if (index == 1) return AppAssets.countdownCardGreen;
    if (index == 2) return AppAssets.countdownCardOrange;
    return AppAssets.countdownCardBlue;
  }

  @override
  Widget build(BuildContext context) {
    final days = viewModel.calculateDaysLeft(countdown);
    final asset = _cardAsset(countdown.colorIndex);
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      child: GestureDetector(
        onTap: () => onOpen(countdown),
        onLongPress: () => onDelete(countdown),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 54,
          child: Stack(
            children: [
              Positioned.fill(child: Image.asset(asset, fit: BoxFit.fill)),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '距离${countdown.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 20 / 16,
                          color: Color(0xFF191919),
                        ),
                      ),
                      Text(
                        _formatFullDate(
                            viewModel.displayTargetDate(countdown)),
                        style: const TextStyle(
                          fontSize: 10,
                          height: 14 / 10,
                          color: Color(0xFF505050),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        days >= 0 ? '还有' : '已经',
                        style: const TextStyle(
                          fontSize: 10,
                          height: 13 / 10,
                          color: Color(0xFF505050),
                        ),
                      ),
                      Text(
                        '${days.abs()}天',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 20 / 16,
                          color: Color(0xFF222222),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 空态卡 ====================

class _CountdownEmptyCard extends StatelessWidget {
  final VoidCallback onAddClick;

  const _CountdownEmptyCard({required this.onAddClick});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onAddClick,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D999999),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            '还没有非置顶倒数日，点击添加',
            style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
          ),
        ),
      );
}

// ==================== 日期格式化（对齐 Locale.CHINA，不补零） ====================

String _formatFullDate(DateTime value) =>
    '${value.year}年${value.month}月${value.day}日';

String _formatMonthDay(DateTime value) => '${value.month}月${value.day}日';
