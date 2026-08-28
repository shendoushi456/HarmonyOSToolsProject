import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../viewmodels/countdown_view_model.dart';

/// 新增倒数日页 - 对齐 Android AddCountdownActivity。
class AddCountdownPage extends ConsumerStatefulWidget {
  const AddCountdownPage({super.key});

  @override
  ConsumerState<AddCountdownPage> createState() => _AddCountdownPageState();
}

class _AddCountdownPageState extends ConsumerState<AddCountdownPage> {
  static const _countdownColors = [
    Color(0xFF89C8F3),
    Color(0xFFB9E4C9),
    Color(0xFFFFD19A),
  ];

  final _titleController = TextEditingController();
  DateTime _targetDate = DateTime.now();
  bool _pinned = false;
  bool _repeatYearly = false;
  int _colorIndex = 1;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8EFFF),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTitleInput(),
                      const SizedBox(height: 20),
                      _buildTargetDateRow(),
                      const SizedBox(height: 32),
                      _buildPinRow(),
                      const SizedBox(height: 20),
                      _buildRepeatRow(),
                      const SizedBox(height: 20),
                      _buildColorRow(),
                      const SizedBox(height: 36),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 顶栏：返回键 + 居中标题。
  Widget _buildTopBar() => SafeArea(
        bottom: false,
        child: SizedBox(
          height: 82,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: Text(
                          '<',
                          style: TextStyle(
                            fontSize: 28,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  '倒数日',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF1E1E1E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  /// 名称输入框：浅蓝底圆角卡 + 居中输入。
  Widget _buildTitleInput() => Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F4FF),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D999999),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: TextField(
          controller: _titleController,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF191919),
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isCollapsed: true,
            hintText: '输入倒数日名称',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Color(0xFF191919),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

  /// 目标日行：带边框 + 悬浮标签 + 日历图标。
  Widget _buildTargetDateRow() => GestureDetector(
        onTap: _pickTargetDate,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF2575DB)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 24,
                top: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: const Text(
                    '目标日',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF191919),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 5,
                bottom: 0,
                child: Center(
                  child: Text(
                    _formatPickerDate(_targetDate),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Image.asset(AppAssets.countdownDatePicker,
                      width: 18, height: 18),
                ),
              ),
            ],
          ),
        ),
      );

  /// 设置行容器：图标 + 标题 + 尾部控件。
  Widget _buildSettingRow({
    required String icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
    bool enabled = true,
  }) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D999999),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Image.asset(icon, width: 20, height: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF191919),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      );

  Widget _buildPinRow() => _buildSettingRow(
        icon: AppAssets.countdownPin,
        title: '置顶',
        trailing: _DesignSwitch(
          checked: _pinned,
          onChanged: (value) => setState(() {
            _pinned = value;
            // 对齐 Android：开启置顶时颜色强制归零。
            if (value) _colorIndex = 0;
          }),
        ),
      );

  Widget _buildRepeatRow() => _buildSettingRow(
        icon: AppAssets.countdownRepeat,
        title: '重复',
        onTap: _showRepeatDialog,
        trailing: SizedBox(
          width: 74,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _repeatYearly ? '重复' : '不重复',
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1E1E1E)),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  '›',
                  style: TextStyle(
                      fontSize: 22, color: Color(0xFF1E1E1E)),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildColorRow() => _buildSettingRow(
        icon: AppAssets.countdownColor,
        title: '颜色',
        onTap: _showColorDialog,
        enabled: !_pinned,
        trailing: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _countdownColors[
                _colorIndex < 0 ? 0 : (_colorIndex > 2 ? 2 : _colorIndex)],
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );

  Widget _buildSaveButton() => GestureDetector(
        onTap: _save,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 196,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF2575DB),
            borderRadius: BorderRadius.circular(30),
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
            '保存',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _targetDate = picked);
    }
  }

  void _showRepeatDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('重复'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogOption(
              text: '不重复',
              selected: !_repeatYearly,
              onClick: () {
                setState(() => _repeatYearly = false);
                Navigator.pop(dialogContext);
              },
            ),
            _DialogOption(
              text: '重复',
              selected: _repeatYearly,
              onClick: () {
                setState(() => _repeatYearly = true);
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('关闭', style: TextStyle(color: Color(0xFF2575DB))),
          ),
        ],
      ),
    );
  }

  void _showColorDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('颜色'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_countdownColors.length, (index) {
            final selected = _colorIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() => _colorIndex = index);
                Navigator.pop(dialogContext);
              },
              child: Container(
                width: selected ? 44 : 36,
                height: selected ? 44 : 36,
                decoration: BoxDecoration(
                  color: _countdownColors[index],
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('关闭', style: TextStyle(color: Color(0xFF2575DB))),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入倒数日名称')));
      return;
    }
    final success = await ref.read(countdownViewModelProvider.notifier)
        .saveCountdown(
      title: _titleController.text,
      targetDate: _targetDate,
      isPinned: _pinned,
      isRepeatYearly: _repeatYearly,
      colorIndex: _colorIndex,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('倒数日添加成功')));
      context.pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('保存失败')));
    }
  }

  /// 对齐 Android "yyyy-M-d EEEE"（Locale.CHINA 星期）格式。
  String _formatPickerDate(DateTime value) {
    const weekLabels = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    return '${value.year}-${value.month}-${value.day} ${weekLabels[value.weekday - 1]}';
  }
}

/// 自绘开关 - 对齐 Android DesignSwitch（24x10 轨道 + 12 圆点）。
class _DesignSwitch extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _DesignSwitch({required this.checked, required this.onChanged});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onChanged(!checked),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 24,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFFE7E7E7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Align(
            alignment: checked ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked
                    ? const Color(0xFF6DA0E2)
                    : const Color(0xFFB8B8B8),
              ),
            ),
          ),
        ),
      );
}

/// 弹窗选项行 - 对齐 Android DialogOption。
class _DialogOption extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onClick;

  const _DialogOption({
    required this.text,
    required this.selected,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onClick,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                      fontSize: 16, color: Color(0xFF1E1E1E)),
                ),
              ),
              if (selected)
                const Text(
                  '✓',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF2575DB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      );
}
