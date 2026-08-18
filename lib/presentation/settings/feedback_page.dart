import 'package:flutter/material.dart';

/// 意见反馈页
///
/// 对应 Android: FeedBackSettingActivity
/// 蓝色顶栏 + 标题"联系我们"（原 Bug：标题与入口"意见反馈"不一致，保留）
/// + EditText（最多100字）+ 提交按钮。
/// 提交后仅切换 UI 到"提交成功"页，无真实上报（原 Bug，保留）。
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _controller = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 蓝色顶栏（标题"联系我们"，原 Bug 保留）
          _SettingAppBar(title: '联系我们', onBack: () => Navigator.pop(context)),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6FBFFF), Color(0xFF4A90E2)],
                ),
              ),
              child: _submitted ? _buildSuccessPage() : _buildInputPage(),
            ),
          ),
        ],
      ),
    );
  }

  /// 输入页（对应 feed_back_layout_1）
  Widget _buildInputPage() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // "请输入："标签
          const Text(
            '请输入：',
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          const SizedBox(height: 8),
          // 输入框（最多100字，200dp 高）
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _controller,
                maxLength: 100,
                maxLines: null,
                style: const TextStyle(color: Colors.black, fontSize: 15),
                decoration: InputDecoration(
                  hintText: '  最多支持100字',
                  hintStyle: const TextStyle(color: Color(0xFF1B2630), fontSize: 15),
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
          // 提交按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                // 原项目 Bug：仅切换 UI，无真实上报（保留）
                setState(() => _submitted = true);
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF6FBFFF),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '提交',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 提交成功页（对应 feed_back_layout_2）
  Widget _buildSuccessPage() {
    return const Padding(
      padding: EdgeInsets.only(top: 100),
      child: Center(
        child: Text(
          '提交成功,感谢您的反馈',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 设置子页面通用蓝色顶栏
class _SettingAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _SettingAppBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 50,
        color: const Color(0xFF6FBFFF),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onBack,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.asset('assets/images/setting/icon_white_back.webp'),
                  ),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
