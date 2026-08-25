import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/recipe_theme.dart';
import '../../features/bootstrap/app_view_model.dart';
import 'web_policy_page.dart';

class PrivacyConsentPage extends StatelessWidget {
  const PrivacyConsentPage({super.key, required this.viewModel});

  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              margin: const EdgeInsets.all(28),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.privacy_tip_outlined,
                        color: RecipeColors.primary, size: 48),
                    const SizedBox(height: 12),
                    const Text('食谱',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 26),
                    Text(
                      '我们依据相关法律向您说明本软件的用户协议和隐私政策。'
                      '为提供食谱浏览、收藏与最近浏览记录服务，应用仅在本机保存必要偏好数据。',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => _openPolicy(context, '用户协议'),
                          child: const Text('《用户协议》'),
                        ),
                        TextButton(
                          onPressed: () => _openPolicy(context, '隐私政策'),
                          child: const Text('《隐私政策》'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 160,
                      child: FilledButton(
                        onPressed: viewModel.acceptPrivacy,
                        child: const Text('同意使用'),
                      ),
                    ),
                    TextButton(
                      onPressed: _refuse,
                      child: const Text('拒绝',
                          style: TextStyle(color: RecipeColors.mutedText)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openPolicy(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WebPolicyPage(
          title: title,
          url: title == '用户协议'
              ? 'http://api.jyhytech.top/agreement/bjlxcp/user'
              : 'http://api.jyhytech.top/agreement/bjlxcp/privacy',
        ),
      ),
    );
  }

  void _refuse() {
    // 对应 Android 原版拒绝后的 finish 行为。
    SystemNavigator.pop();
  }
}
