import 'package:flutter/material.dart';

/// 意见反馈页 —— 对应 Android setting 模块 FeedBackSettingActivity +
/// activity_feed_back_setting.xml：渐变背景 + #A7C6FA 标题栏 +
/// 输入框（200dp、限 100 字、#CCC 边框圆角）+ 胶囊提交按钮；
/// 提交后切换为"提交成功"提示（原版无网络请求，仅本地切换）。
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _inputController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _submit() {
    // 原版 toFeedBack()：隐藏输入布局、显示成功文案，无网络请求。
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // shape_jianbian_shezhi：上 #A7C6FA → 下 #E6EBEE 渐变
      body: SafeArea(
        top:true,
        child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFA7C6FA), Color(0xFFE6EBEE)],
          ),
        ),
        child: Column(
          children: [
            // 标题栏：#A7C6FA 50dp + iv_back + "意见反馈" 18sp 白字
            Container(
              height: 50,
              color: const Color(0xFFA7C6FA),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Positioned(
                  //   left: 16,
                  //   child: GestureDetector(
                  //     behavior: HitTestBehavior.opaque,
                  //     onTap: () => Navigator.of(context).maybePop(),
                  //     child: Image.asset(
                  //       'assets/images/recipes_tools/iv_back.png',
                  //       width: 24,
                  //       height: 24,
                  //     ),
                  //   ),
                  // ),
                  const Text('意见反馈',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            Expanded(
              child: _submitted ? _buildSuccess() : _buildForm(),
            ),
          ],
        ),
      )),
    );
  }

  /// 输入表单（feed_back_layout_1，margin 15dp）。
  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 原版两个 invisible 占位 TextView（保留占位高度）
          const SizedBox(height: 10),
          const Opacity(
            opacity: 0,
            child: Text('意见反馈',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
          ),
          const Opacity(opacity: 0, child: Text('请输入：')),
          const SizedBox(height: 10),
          // 输入框：200dp 高、限 100 字、左上对齐、白底 #CCC 边框圆角 10
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCCCCCC)),
            ),
            child: TextField(
              controller: _inputController,
              maxLines: null,
              maxLength: 100,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '  最多支持100字',
                counterText: '',
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),
          const SizedBox(height: 100), // 提交按钮 marginTop 100dp
          // 提交按钮：#A7C6FA 胶囊（圆角 100dp）、高 50dp、白字 20sp bold
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: _submit,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFA7C6FA),
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: const Text('提交',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 提交成功（feed_back_layout_2）："提交成功,感谢您的反馈" 25sp 白字 bold。
  Widget _buildSuccess() {
    return const Column(
      children: [
        SizedBox(height: 100),
        Center(
          child: Text('提交成功,感谢您的反馈',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
