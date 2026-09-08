import 'package:flutter/material.dart';

import '../../features/health_tips/health_tips_view_model.dart';
import '../widgets/tool_title_bar.dart';

/// 体脂率计算页 —— 对应 calculatorlibrary TiZhiLvActivity +
/// activity_tizhilv.xml：性别/身高/体重/年龄表单 +
/// 开始计算按钮（#9FDE6E 圆角 20dp）+ 结果区（初始隐藏）。
/// 保真说明：原版 sex 初始 1（男）但默认勾选"女"、age 始终提交空串，
/// 两个行为均为原版 Bug，已在 ViewModel 中保留。
class TiZhiLvPage extends StatefulWidget {
  const TiZhiLvPage({super.key});

  @override
  State<TiZhiLvPage> createState() => _TiZhiLvPageState();
}

class _TiZhiLvPageState extends State<TiZhiLvPage> {
  final _viewModel = TiZhiLvViewModel();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  /// RadioGroup：原版 womanRadiobutton.isChecked=true（默认选中"女"），
  /// 但 sex 变量初始为 1（男），未点击单选钮时按 1 提交 —— 保真保留。
  int? _radioChecked = 0;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top:true,
        child: Column(
        children: [
          const ToolTitleBar(title: '体脂率计算'),
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedBuilder(
                animation: _viewModel,
                builder: (context, _) => Column(
                  children: [
                    const SizedBox(height: 20),
                    // 性别行：左标签，右单选钮组（男/女）
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        children: [
                          const Text('性别'),
                          const Spacer(),
                          _radio('男', 1),
                          _radio('女', 0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _formRow('身高', '输入身高(cm)', _heightController),
                    const SizedBox(height: 20),
                    _formRow('体重', '输入体重(kg)', _weightController),
                    const SizedBox(height: 20),
                    // 年龄输入框存在但原版不读取其值（Bug 保真）
                    _formRow('年龄', '输入年龄', null),
                    const SizedBox(height: 50),
                    // 开始计算（blue_round_bg 实为 #9FDE6E 圆角 20dp，高 50dp）
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: _onCalculate,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9FDE6E),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: const Text('开始计算',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ),
                    // 结果区（原版 visibility=gone，计算成功后展示）
                    if (_viewModel.showResult &&
                        _viewModel.result != null) ...[
                      const Padding(
                        padding: EdgeInsets.only(left: 20, top: 30),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('计算结果如下:',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      _resultLine('体脂率:${_viewModel.result!.bfr}'),
                      _resultLine('正常体脂率范围:${_viewModel.result!.normbfr}'),
                      _resultLine('理想体重:${_viewModel.result!.idealweight}'),
                      _resultLine(
                          '正常体重范围：${_viewModel.result!.normweight}'),
                      _resultLine('健康评估：${_viewModel.result!.healthy}'),
                      _resultLine('健康建议提示：${_viewModel.result!.tip}'),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget _radio(String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<int>(
          value: value,
          groupValue: _radioChecked,
          // 对应原版 OnCheckedChangeListener：男→1，女→0
          onChanged: (v) {
            setState(() => _radioChecked = v);
            _viewModel.setSex(v ?? 1);
          },
        ),
        Text(label),
      ],
    );
  }

  /// 表单行：左标签 + 右对齐无边框输入框（原版 background=@null）。
  Widget _formRow(
      String label, String hint, TextEditingController? controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: hint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultLine(String text) => Padding(
        padding: const EdgeInsets.only(left: 20, top: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(text,
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF333333))),
        ),
      );

  Future<void> _onCalculate() async {
    await _viewModel.calculate(
      height: _heightController.text,
      weight: _weightController.text,
    );
    // 原版 code!=200 时 Toast "提示：msg"
    if (!mounted) return;
    final toast = _viewModel.toastMessage;
    if (toast != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(toast)));
    }
  }
}
