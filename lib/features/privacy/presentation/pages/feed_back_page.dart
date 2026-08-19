import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/core/theme/app_colors.dart';

/// 意见反馈页面
///
/// 对应原 Android `FeedBackSettingActivity`：
/// 蓝色标题栏 + 输入框（最多 100 字）+ 提交按钮 → 成功提示页。
///
/// 保真说明：原项目未接入后端，提交后仅切换到"提交成功"界面。
class FeedBackPage extends StatefulWidget {
  const FeedBackPage({super.key});

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  final TextEditingController _inputController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _submitted ? _buildSuccessView() : _buildInputView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Stack(
            children: [
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  '意见反馈',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text(
        '请输入您的反馈意见',
        style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.langSwitchText,
        ),
        ),
        const SizedBox(height: 16),
        Container(
        height: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: TextField(
        controller: _inputController,
        maxLines: null,
        maxLength: 100,
        decoration: const InputDecoration(
        counterText: '',
        border: InputBorder.none,
        hintText: '最多支持100字',
        hintStyle: TextStyle(color: AppColors.hintText),
        ),
        ),
        ),
        const Spacer(),
        SizedBox(
        width: double.infinity,
        height: 42,
        child: GestureDetector(
        onTap: _submit,
        child: Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
        BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 4,
        offset: const Offset(0, 2),
        ),
        ],
        gradient: const LinearGradient(
        colors: [
        AppColors.buttonGradientStart,
        AppColors.buttonGradientEnd,
        ],
        ),
        ),
        child: const Center(
        child: Text(
        '提交',
        style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        ),
        ),
        ),
        ),
        ),
        ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.loadingIndicator,
            size: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            '提交成功,感谢您的反馈',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.langSwitchText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '非常感谢您的反馈，我们将尽快处理！',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.hintText,
            ),
          ),
        ],
      ),
    );
  }
}
