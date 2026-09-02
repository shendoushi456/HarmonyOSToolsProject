// 对齐 Android AddCropRecordActivity：独立添加/编辑页 + 该类别的高危预警指南。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/standard_page_header.dart';
import '../../weather/models/weather_warning.dart';
import '../models/agriculture_models.dart';
import '../viewmodels/agriculture_view_model.dart';

class CropRecordEditorPage extends ConsumerStatefulWidget {
  final CropCategory category;
  final CropRecord? record;
  final List<WeatherWarning> warnings;

  const CropRecordEditorPage({
    super.key,
    required this.category,
    required this.warnings,
    this.record,
  });

  @override
  ConsumerState<CropRecordEditorPage> createState() =>
      _CropRecordEditorPageState();
}

class _CropRecordEditorPageState extends ConsumerState<CropRecordEditorPage> {
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

  @override
  Widget build(BuildContext context) {
    final guides = [...widget.category.guides]..sort((left, right) =>
        (_hasWarning(right) ? 1 : 0).compareTo(_hasWarning(left) ? 1 : 0));
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D0E),
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          StandardPageHeader(
            title: widget.category.title,
            leading: IconButton(
                tooltip: '返回',
                onPressed: () => Navigator.of(context).pop(),
                icon: Image.asset(AppAssets.agricultureBack,
                    width: 28, height: 28)),
            trailing: IconButton(
              tooltip: '保存',
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Image.asset(AppAssets.agricultureSaveRecord,
                      width: 28, height: 28),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 7, 20, 32),
              children: [
                TextField(
                  controller: _title,
                  maxLines: 1,
                  style: const TextStyle(
                      color: Color(0xFF185AAB),
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: widget.category.inputHint,
                    hintStyle: const TextStyle(color: Color(0xFF185AAB)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(21),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 13),
                TextField(
                  controller: _content,
                  minLines: 7,
                  maxLines: 9,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                      color: Color(0xFF242424), fontSize: 14, height: 1.5),
                  decoration: InputDecoration(
                    hintText: '请记录你的农作物注意事项',
                    hintStyle:
                        const TextStyle(color: Color(0xFF185AAB), fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide:
                          const BorderSide(color: Color(0xFF175DB2), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide:
                          const BorderSide(color: Color(0xFF175DB2), width: 2),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10, top: 19, bottom: 8),
                  child: Text('重点高危预警',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                ),
                ...guides.map((guide) => Padding(
                      padding: const EdgeInsets.only(bottom: 13),
                      child: _GuideCard(
                          guide: guide, hasWarning: _hasWarning(guide)),
                    )),
              ],
            ),
          )
        ]),
      ),
    );
  }

  bool _hasWarning(DisasterGuide guide) => widget.warnings.any(guide.matches);

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入农作物名称和注意事项')));
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
    Navigator.of(context).pop(true);
  }
}

class _GuideCard extends StatelessWidget {
  final DisasterGuide guide;
  final bool hasWarning;
  const _GuideCard({required this.guide, required this.hasWarning});

  @override
  Widget build(BuildContext context) {
    final color = Color(guide.color);
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 11, 14, 14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(guide.title,
                  style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600))),
          Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: hasWarning
                      ? const Color(0xFFFFE4DE)
                      : const Color(0xFFE8EEF4),
                  borderRadius: BorderRadius.circular(11)),
              child: Text(hasWarning ? '预警中' : '暂无预警',
                  style: TextStyle(
                      color: hasWarning
                          ? const Color(0xFFD43B20)
                          : const Color(0xFF60758A),
                      fontSize: 10))),
        ]),
        const SizedBox(height: 10),
        Text('危害：${guide.danger}',
            style: const TextStyle(
                color: Color(0xFF464646), fontSize: 12, height: 1.4)),
        const SizedBox(height: 4),
        Text('预防措施：${guide.prevention}',
            style: TextStyle(color: color, fontSize: 12, height: 1.4)),
      ]),
    );
  }
}
