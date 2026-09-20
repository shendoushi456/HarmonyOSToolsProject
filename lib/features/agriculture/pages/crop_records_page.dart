// toolbox_c CropRecordListActivity(Compose 版)的 Flutter 迁移。
// 蓝渐变背景 + 记录卡列表(带预警徽章) + 右下角添加按钮(对齐 Android：返回类别页)。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../weather/models/weather_warning.dart';
import '../models/agriculture_catalog.dart';
import '../models/agriculture_models.dart';
import '../viewmodels/agriculture_view_model.dart';
import 'crop_category_select_page.dart';
import 'crop_record_add_page.dart';

class CropRecordsPage extends ConsumerWidget {
  final List<WeatherWarning> warnings;
  const CropRecordsPage({super.key, required this.warnings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agricultureViewModelProvider);
    return Scaffold(
      backgroundColor: agricultureDarkBlue,
      body: AgricultureGradientBackground(
        child: Column(children: [
          AgricultureHeader(
            title: '农作物记录列表',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Stack(children: [
              if (state.records.isEmpty)
                const Center(
                  child: Text('请添加您的农作物',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w500)),
                )
              else
                ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 105),
                  itemCount: state.records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, index) => _CropRecordCard(
                    record: state.records[index],
                    warnings: warnings,
                    onViewDetails: () => _openEditor(
                        context, ref, state, state.records[index]),
                    onDelete: () => _confirmDelete(
                        context, ref, state, state.records[index]),
                  ),
                ),
              // 对齐 Android onAdd = finish()：返回类别选择页再添加
              Positioned(
                right: 36,
                bottom: 72,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Image.asset(AppAssets.agricultureAddRecord,
                      width: 45, height: 45),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref,
      AgricultureState state, CropRecord record) async {
    final category = agricultureCategoryForId(record.categoryId);
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CropRecordAddPage(
              category: category,
              record: record,
              warnings: warnings,
            )));
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref,
      AgricultureState state, CropRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _DeleteRecordConfirmDialog(
        onConfirm: () => Navigator.pop(context, true),
        onDismiss: () => Navigator.pop(context, false),
      ),
    );
    if (confirmed == true) {
      await ref
          .read(agricultureViewModelProvider.notifier)
          .deleteRecord(record.id);
    }
  }
}

/// 记录卡 - 对齐 CropRecordCard
class _CropRecordCard extends StatelessWidget {
  final CropRecord record;
  final List<WeatherWarning> warnings;
  final VoidCallback onViewDetails;
  final VoidCallback onDelete;
  const _CropRecordCard({
    required this.record,
    required this.warnings,
    required this.onViewDetails,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    final category = agricultureCategoryForId(record.categoryId);
    final badges = _buildWarningBadges(category, warnings);
    return GestureDetector(
      onTap: onViewDetails,
      child: Container(
        padding: const EdgeInsets.only(left: 17, top: 14, right: 13, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: agricultureAccentBlue, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(record.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: agricultureAccentBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 8),
                _WarningBadgeGroup(badges: badges),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 7),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F1FC),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(category.title,
                  style: const TextStyle(
                      color: agricultureAccentBlue, fontSize: 11)),
            ),
            const SizedBox(height: 8),
            Text(record.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0xFF242424), fontSize: 14, height: 21 / 14)),
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text('点击查看详情',
                  style: TextStyle(
                      color: agricultureAccentBlue, fontSize: 11)),
            ),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDelete,
                  child: Image.asset(AppAssets.agricultureDeleteRecord,
                      width: 21, height: 21),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 预警徽章组 - 对齐 WarningBadgeGroup(每行 2 个)
class _WarningBadgeGroup extends StatelessWidget {
  final List<_WarningBadge> badges;
  const _WarningBadgeGroup({required this.badges});
  @override
  Widget build(BuildContext context) {
    final rowCount = (badges.length / 2).ceil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var row = 0; row < rowCount; row++)
          Padding(
            padding: EdgeInsets.only(bottom: row == rowCount - 1 ? 0 : 4),
            child: Row(children: [
              for (var col = 0; col < 2; col++)
                if (row * 2 + col < badges.length)
                  Padding(
                    padding: EdgeInsets.only(left: col == 0 ? 0 : 5),
                    child: badges[row * 2 + col],
                  ),
            ]),
          ),
      ],
    );
  }
}

class _WarningBadge extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;
  const _WarningBadge(this.text, this.background, this.textColor);
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 96),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}

/// 中性徽章 - 对齐 neutralWarningBadge
_WarningBadge _neutralBadge(String text) =>
    _WarningBadge(text, const Color(0xFF5F7890), Colors.white);

/// 对齐 buildWarningBadges(Success 分支)：按类别匹配预警名做徽章，空则"暂无预警"
List<_WarningBadge> _buildWarningBadges(
    CropCategory category, List<WeatherWarning> warnings) {
  final result = <_WarningBadge>[];
  final seenTexts = <String>{};
  for (final warning in warnings) {
    if (!category.guides.any((guide) => guide.matches(warning))) continue;
    final name = warning.eventName.isNotEmpty
        ? warning.eventName
        : (warning.headline.isNotEmpty ? warning.headline : '');
    if (name.isEmpty || !seenTexts.add(name)) continue;
    result.add(_WarningBadge(
        name, _badgeColor(warning), _badgeTextColor(warning)));
  }
  if (result.isEmpty) return [_neutralBadge('暂无预警')];
  return result;
}

/// 对齐列表页 warningColor：rgb 优先，色码映射红 FF3F46/橙 FF8A3D/黄 FFC107/其余 3478C5
Color _badgeColor(WeatherWarning warning) {
  if (warning.red != null && warning.green != null && warning.blue != null) {
    return Color.fromARGB(255, warning.red!, warning.green!, warning.blue!);
  }
  switch (warning.colorCode.toLowerCase()) {
    case 'red':
      return const Color(0xFFFF3F46);
    case 'orange':
      return const Color(0xFFFF8A3D);
    case 'yellow':
      return const Color(0xFFFFC107);
    default:
      return const Color(0xFF3478C5);
  }
}

/// 对齐 warningTextColor：亮度 >= 180 用深色文字
Color _badgeTextColor(WeatherWarning warning) {
  final red = warning.red;
  final green = warning.green;
  final blue = warning.blue;
  if (red == null || green == null || blue == null) return Colors.white;
  final brightness = (red * 299 + green * 587 + blue * 114) / 1000;
  return brightness >= 180 ? const Color(0xFF242424) : Colors.white;
}

/// 删除确认弹窗 - 对齐 DeleteRecordConfirmDialog(89.3% 宽、190dp 高、上移 76dp)
class _DeleteRecordConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;
  const _DeleteRecordConfirmDialog({
    required this.onConfirm,
    required this.onDismiss,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Transform.translate(
            offset: const Offset(0, -76),
            child: GestureDetector(
              onTap: () {},
              child: FractionallySizedBox(
                widthFactor: 0.893,
                child: Container(
                  height: 190,
                  constraints: const BoxConstraints(maxWidth: 360),
                  padding: const EdgeInsets.only(top: 43),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(children: [
                    const Text('是否确认删除此记录',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            height: 24 / 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 29),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _DialogButton(
                            text: '确认',
                            background: agricultureAccentBlue,
                            textColor: Colors.white,
                            onTap: onConfirm,
                          ),
                          _DialogButton(
                            text: '取消',
                            background: Colors.white,
                            textColor: agricultureAccentBlue,
                            border: agricultureAccentBlue,
                            onTap: onDismiss,
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 弹窗按钮 - 对齐 DeleteDialogButton(118x45 圆角 16)
class _DialogButton extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;
  final Color? border;
  final VoidCallback onTap;
  const _DialogButton({
    required this.text,
    required this.background,
    required this.textColor,
    this.border,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 118,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: border == null
              ? null
              : Border.all(color: border!, width: 1),
        ),
        child: Text(text,
            style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}
