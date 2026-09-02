// 对齐 Android UnifiedCropRecordListScreen；添加按钮直接打开添加页，修复 Android 的 finish() 跳回问题。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/standard_page_header.dart';
import '../../weather/models/weather_warning.dart';
import '../models/agriculture_catalog.dart';
import '../models/agriculture_models.dart';
import '../viewmodels/agriculture_view_model.dart';
import 'crop_record_editor_page.dart';

class CropRecordListPage extends ConsumerWidget {
  final List<WeatherWarning> warnings;
  const CropRecordListPage({super.key, required this.warnings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agricultureViewModelProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D0E),
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          StandardPageHeader(
            title: '农作物记录列表',
            leading: IconButton(
                tooltip: '返回',
                onPressed: () => Navigator.of(context).pop(),
                icon: Image.asset(AppAssets.agricultureBack,
                    width: 28, height: 28)),
          ),
          Expanded(
            child: Stack(children: [
              if (state.records.isEmpty)
                const Center(
                    child: Text('请添加您的农作物',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500)))
              else
                ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
                  itemCount: state.records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, index) => _RecordCard(
                    record: state.records[index],
                    warnings: warnings,
                    onTap: () => _openEditor(context, state.records[index]),
                    onDelete: () =>
                        _confirmDelete(context, ref, state.records[index]),
                  ),
                ),
              Positioned(
                right: 30,
                bottom: 50,
                child: GestureDetector(
                  // 修复 Android CropRecordListActivity 的 onAdd = finish()：
                  // 此处直接进入添加页面，不返回类别页。
                  onTap: () => _openCategoryPicker(context),
                  child: Image.asset(AppAssets.agricultureAddRecord,
                      width: 48, height: 48),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, CropRecord record) async {
    final category = agricultureCategoryForId(record.categoryId);
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CropRecordEditorPage(
            category: category, record: record, warnings: warnings)));
  }

  Future<void> _openCategoryPicker(BuildContext context) async {
    final category = await showModalBottomSheet<CropCategory>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FBFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('选择农作物类别',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...agricultureCategories.map((item) => ListTile(
                leading: Image.asset(item.iconAsset, width: 38, height: 38),
                title: Text(item.title),
                subtitle: Text(item.selectionText,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.of(context).pop(item),
              )),
        ]),
      ),
    );
    if (category == null || !context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            CropRecordEditorPage(category: category, warnings: warnings)));
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, CropRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('是否确认删除此记录'),
        actions: [
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF234F78)),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确认')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(agricultureViewModelProvider.notifier)
          .deleteRecord(record.id);
    }
  }
}

class _RecordCard extends StatelessWidget {
  final CropRecord record;
  final List<WeatherWarning> warnings;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _RecordCard(
      {required this.record,
      required this.warnings,
      required this.onTap,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final category = agricultureCategoryForId(record.categoryId);
    final dangerNames = category.guides
        .where((guide) => warnings.any(guide.matches))
        .map((guide) => guide.title)
        .toList();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.asset(category.iconAsset, width: 54, height: 54),
          const SizedBox(width: 11),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(record.title,
                    style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(category.title,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
                if (record.content.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(record.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFF475569), fontSize: 12, height: 1.4)),
                ],
                const SizedBox(height: 8),
                Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: (dangerNames.isEmpty ? ['暂无预警'] : dangerNames)
                        .map((name) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: name == '暂无预警'
                                      ? const Color(0xFFE8EEF4)
                                      : const Color(0xFFFFE4DE),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(name,
                                  style: TextStyle(
                                      color: name == '暂无预警'
                                          ? const Color(0xFF60758A)
                                          : const Color(0xFFD43B20),
                                      fontSize: 10)),
                            ))
                        .toList()),
              ])),
          IconButton(
              tooltip: '删除',
              onPressed: onDelete,
              icon: Image.asset(AppAssets.agricultureDeleteRecord,
                  width: 21, height: 21)),
        ]),
      ),
    );
  }
}
