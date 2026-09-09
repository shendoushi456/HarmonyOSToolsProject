// toolbox_c AddCropRecordActivity(Compose 版)的 Flutter 迁移。
// 蓝渐变背景 + 名称胶囊输入 + 注意事项多行输入 + 按当前预警排序的灾害指南列表。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../weather/models/weather_warning.dart';
import '../models/agriculture_models.dart';
import '../viewmodels/agriculture_view_model.dart';
import 'crop_category_select_page.dart';

class CropRecordAddPage extends ConsumerStatefulWidget {
  final CropCategory category;
  final List<WeatherWarning> warnings;
  final CropRecord? record;

  const CropRecordAddPage({
    super.key,
    required this.category,
    required this.warnings,
    this.record,
  });

  @override
  ConsumerState<CropRecordAddPage> createState() => _CropRecordAddPageState();
}

class _CropRecordAddPageState extends ConsumerState<CropRecordAddPage> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.record?.title ?? '');
    _content = TextEditingController(text: widget.record?.content ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  bool _hasWarning(DisasterGuide guide) =>
      widget.warnings.any(guide.matches);

  /// 对齐 buildDisasterGuideItems：有预警的指南排前面，其余保持原顺序
  List<DisasterGuide> get _sortedGuides {
    final indexed = widget.category.guides
        .asMap()
        .entries
        .map((entry) => MapEntry(entry.key, entry.value))
        .toList();
    indexed.sort((left, right) {
      final leftWarn = _hasWarning(left.value) ? 1 : 0;
      final rightWarn = _hasWarning(right.value) ? 1 : 0;
      if (leftWarn != rightWarn) return rightWarn - leftWarn;
      return left.key - right.key;
    });
    return indexed.map((entry) => entry.value).toList();
  }

  Future<void> _save() async {
    // 对齐 Android saveRecord 的两条 Toast 校验
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入农作物名称')));
      return;
    }
    if (_content.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入农作物注意事项')));
      return;
    }
    setState(() => _saving = true);
    await ref.read(agricultureViewModelProvider.notifier).saveRecord(
          original: widget.record,
          category: widget.category,
          title: _title.text,
          content: _content.text,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('保存成功')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: agricultureDarkBlue,
      body: AgricultureGradientBackground(
        child: Column(children: [
          AgricultureHeader(
            title: widget.category.title,
            onBack: () => Navigator.of(context).maybePop(),
            trailing: _saving
                ? const Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white)),
                  )
                : HighContrastImageButton(
                    image: AppAssets.agricultureSaveRecord,
                    size: 28,
                    onTap: _save,
                  ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 7, 20, 32),
              children: [
                _CropTitleInput(
                  controller: _title,
                  hint: widget.category.inputHint,
                ),
                const SizedBox(height: 13),
                _CropContentInput(controller: _content),
                const Padding(
                  padding: EdgeInsets.only(left: 10, top: 6, bottom: 1),
                  child: Text('重点高危预警',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                ),
                for (final guide in _sortedGuides)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: _DisasterGuideCard(
                      guide: guide,
                      hasWarning: _hasWarning(guide),
                    ),
                  ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

/// 名称输入 - 对齐 CropTitleInput：白色胶囊 36dp 高
class _CropTitleInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _CropTitleInput({required this.controller, required this.hint});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        maxLines: 1,
        cursorColor: agricultureAccentBlue,
        style: const TextStyle(
            color: agricultureAccentBlue,
            fontSize: 13,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: agricultureAccentBlue,
              fontSize: 13,
              fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(21),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

/// 注意事项输入 - 对齐 CropContentInput：白色 185dp 高 + 2dp 蓝边框，提示语居中
class _CropContentInput extends StatelessWidget {
  final TextEditingController controller;
  const _CropContentInput({required this.controller});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 185,
      child: Stack(children: [
        TextField(
          controller: controller,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          cursorColor: agricultureAccentBlue,
          style: const TextStyle(
              color: Color(0xFF242424), fontSize: 14, height: 21 / 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                  color: agricultureAccentBlue, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                  color: agricultureAccentBlue, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                  color: agricultureAccentBlue, width: 2),
            ),
          ),
        ),
        // 对齐 Android：提示语固定在输入框中央
        IgnorePointer(
          child: AnimatedBuilder(
            animation: controller,
            builder: (_, __) => controller.text.isEmpty
                ? const Center(
                    child: Text('请记录你的农作物注意事项',
                        style: TextStyle(
                            color: agricultureAccentBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ]),
    );
  }
}

/// 灾害指南卡 - 对齐 DisasterGuideCard
class _DisasterGuideCard extends StatelessWidget {
  final DisasterGuide guide;
  final bool hasWarning;
  const _DisasterGuideCard({required this.guide, required this.hasWarning});
  @override
  Widget build(BuildContext context) {
    final guideColor = Color(guide.color);
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.only(left: 21, top: 11, right: 14, bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(guide.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Container(
                width: 20,
                height: 20,
                decoration:
                    BoxDecoration(color: guideColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasWarning
                    ? const Color(0xFFFFE4DE)
                    : const Color(0xFFE8EEF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(hasWarning ? '有此预警' : '暂无预警',
                  style: TextStyle(
                      color: hasWarning
                          ? const Color(0xFFD43B20)
                          : const Color(0xFF60758A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 10),
          Text('危害：${guide.danger}',
              style: const TextStyle(
                  color: Color(0xFF464646), fontSize: 12, height: 17 / 12)),
          const SizedBox(height: 4),
          Text('${guide.preventionLabel}${guide.prevention}',
              style:
                  TextStyle(color: guideColor, fontSize: 12, height: 17 / 12)),
        ],
      ),
    );
  }
}
