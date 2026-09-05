import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Wi-Fi 优化加速卡片。仅负责展示和触发回调，实际优化流程由页面控制。
class WifiAcceleratorCard extends StatelessWidget {
  final int improvementPercent;
  final bool optimized;
  final VoidCallback? onTap;

  const WifiAcceleratorCard({
    super.key,
    required this.improvementPercent,
    this.optimized = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        optimized ? '网络已提升$improvementPercent%' : '网络可提升$improvementPercent%';
    final buttonText = optimized ? '已优化' : '优化提速';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFB9E8FF), Color(0xFF5BA8F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              size: 25,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202020),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '当前网络状态良好',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.wifiConnectGreen,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: optimized ? null : onTap,
            style: TextButton.styleFrom(
              backgroundColor:
                  optimized ? const Color(0xFFE5E5E5) : const Color(0xFF5597F7),
              foregroundColor:
                  optimized ? const Color(0xFF999999) : Colors.white,
              disabledForegroundColor: const Color(0xFF999999),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(buttonText, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// 3 秒优化进度弹窗，仅展示动画，不执行真实网络优化。
class WifiOptimizationProgressDialog extends StatefulWidget {
  const WifiOptimizationProgressDialog({super.key});

  @override
  State<WifiOptimizationProgressDialog> createState() =>
      _WifiOptimizationProgressDialogState();
}

class _WifiOptimizationProgressDialogState
    extends State<WifiOptimizationProgressDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          Navigator.of(context).pop();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('正在优化网络', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _controller.value,
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFF5597F7),
                backgroundColor: const Color(0xFFE5F0FF),
              ),
              const SizedBox(height: 10),
              Text(
                '${(_controller.value * 100).round()}%',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
