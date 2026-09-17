// 反馈页 - 对齐 Android third-module/setting FeedBackSettingActivity + activity_feed_back_setting.xml
// 整页渐变 #f1f1f1→#E6EBEE 垂直(shape_jianbian_shezhi);顶栏 50dp #6FBFFF「联系我们」白 20sp;
// 「请输入：」+ 输入框(200dp 白底描边 #CCCCCC 圆角10,.maxLength=100,hint色 #1B2630);
// 提交按钮 50dp #6FBFFF 白字 20sp bold;提交后 layout_1 隐藏/layout_2 显示
// 「提交成功,感谢您的反馈」(纯本地假实现,对齐原版)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import 'policy_page.dart' show kSettingBoxTheme;

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    // 对齐安卓 toFeedBack(): 仅切换 layout_1→layout_2,无网络请求
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    // 对齐 shape_jianbian_shezhi: #f1f1f1→#E6EBEE 垂直渐变
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F1F1), Color(0xFFE6EBEE)],
          ),
        ),
        child: Column(
          children: [
            _buildTopBar(context),
            if (_submitted) _buildSubmittedView() else _buildInputView(),
          ],
        ),
      ),
    );
  }

  /// 顶栏 50dp #6FBFFF + 白返回键(icon_white_back) + 白 20sp「联系我们」
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: kSettingBoxTheme,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text('联系我们',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500)),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(AppAssets.settingBoxIconWhiteBack,
                        width: 20, height: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 输入界面(layout_1)
  Widget _buildInputView() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('请输入：',
                  style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
            // 输入框(200dp 高,白底 1dp #CCCCCC 描边圆角10,MaxLength=100)
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFCCCCCC)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _controller,
                maxLength: 100,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 15, color: Colors.black),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  counterText: '',
                  hintText: '最多支持100字',
                  hintStyle: TextStyle(color: Color(0xFF1B2630), fontSize: 15),
                ),
              ),
            ),
            // 提交按钮(50dp 高 margin20/上100, #6FBFFF 白字 20sp bold)
            Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 100, 20, 0),
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSettingBoxTheme,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('提交',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 已提交界面(layout_2):「提交成功,感谢您的反馈」25sp bold 白色居中 marginTop=100
  Widget _buildSubmittedView() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Align(
          alignment: Alignment.topCenter,
          child: const Text(
            '提交成功,感谢您的反馈',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
