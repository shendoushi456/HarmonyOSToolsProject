// 反馈页 - 对齐 Android FeedBackSettingActivity
// 输入框 + 提交按钮,提交后切换到"已提交"界面(无实际网络请求,对齐原版)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

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
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopBar(context),
          if (_submitted) _buildSubmittedView() else _buildInputView(),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 88,
      color: AppColors.settingTheme,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 8,
              bottom: 0,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: const Center(
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 48,
                child: Center(
                  child: Text(
                    '意见反馈',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 输入界面
  Widget _buildInputView() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '请输入您的反馈意见',
              style: TextStyle(
                color: AppColors.settingItemText,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCCCCCC)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '请输入反馈内容...',
                  hintStyle: TextStyle(color: AppColors.settingSubText),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.settingTheme,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('提交', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  /// 已提交界面 - 对齐 Android feed_back_layout_2
  Widget _buildSubmittedView() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: AppColors.settingTheme),
            const SizedBox(height: 16),
            const Text(
              '感谢您的反馈',
              style: TextStyle(
                color: AppColors.settingItemText,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.settingTheme,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
