// Android ToolsBoxFragment 的 Flutter 版，仅迁移尺子、水平仪、量角器。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/storage/prefs_storage.dart';
import '../../../router/route_names.dart';
import '../../setting/utils/app_info_util.dart';
import 'level_tool_page.dart';
import 'protractor_tool_page.dart';
import 'ruler_tool_page.dart';

class ToolsBoxPage extends StatefulWidget {
  const ToolsBoxPage({super.key});

  @override
  State<ToolsBoxPage> createState() => _ToolsBoxPageState();
}

class _ToolsBoxPageState extends State<ToolsBoxPage> {
  bool _revokeInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.toolsBoxBackground, fit: BoxFit.fill),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      '工具箱',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      children: [
                        _ToolHeroCard(
                          onTap: () => _open(context, const RulerToolPage()),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _ToolGridCard(
                                title: '水平仪',
                                description: '校准平面水平垂直度',
                                icon: AppAssets.toolsBoxLevel,
                                onTap: () =>
                                    _open(context, const LevelToolPage()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ToolGridCard(
                                title: '量角器',
                                description: '测量绘制各类角度数值',
                                icon: AppAssets.toolsBoxProtractor,
                                onTap: () =>
                                    _open(context, const ProtractorToolPage()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _ToolSettingsCard(
                          onPolicy: () =>
                              _openPolicy(context, '用户协议', SettingUrls.user),
                          onPrivacy: () =>
                              _openPolicy(context, '隐私协议', SettingUrls.policy),
                          onAbout: () => context.push(RoutePaths.about),
                          onFeedback: () => context.push(RoutePaths.feedback),
                          onRevoke: () => _showRevokeDialog(context),
                          onCancelAccount: () =>
                              _showCancelAccountDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _openPolicy(BuildContext context, String title, String url) {
    context.push(RoutePaths.policy, extra: {'title': title, 'url': url});
  }

  Future<void> _showRevokeDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('温馨提示'),
        content: Text(
          '撤销同意隐私政策及用户协议后，将清空当前所有信息并退出应用。'
          '如果您撤回对"${AppInfoUtil.appName}"隐私政策的同意，我们将会停止收集您的个人信息，'
          '并按照法律规定删除应用所收集的个人信息，但其他法律法规对于个人信息保存期限有明确规定的除外。'
          '因为"${AppInfoUtil.appName}"服务的提供依赖于必要的个人信息收集，如您撤销同意，'
          '则视为您不同意我们继续向您提供"${AppInfoUtil.appName}"的服务。确定撤销?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认撤销'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _revokeInProgress) return;
    setState(() => _revokeInProgress = true);
    await PrefsStorage.clearUserData();
    if (!mounted) return;
    setState(() => _revokeInProgress = false);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('操作成功，3秒后返回协议页面')),
    );
    await Future<void>.delayed(const Duration(seconds: 3));
    if (mounted) GoRouter.of(context).go(RoutePaths.splash);
  }

  Future<void> _showCancelAccountDialog(BuildContext context) async {
    final first = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('注销提示'),
        content: const Text('注销账号是不可恢复的操作，操作之前请确认与账号相关的服务均可进行妥善处理'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('继续注销'),
          ),
        ],
      ),
    );
    if (first != true || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认注销账号'),
        content: const Text('我们将彻底删除你的相关信息，一旦删除将不可恢复，请确认是否注销'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认注销'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await PrefsStorage.clearUserData();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('操作成功，3秒后返回协议页面')),
    );
    await Future<void>.delayed(const Duration(seconds: 3));
    if (mounted) GoRouter.of(context).go(RoutePaths.splash);
  }
}

class _ToolSettingsCard extends StatelessWidget {
  final VoidCallback onPolicy;
  final VoidCallback onPrivacy;
  final VoidCallback onAbout;
  final VoidCallback onFeedback;
  final VoidCallback onRevoke;
  final VoidCallback onCancelAccount;

  const _ToolSettingsCard({
    required this.onPolicy,
    required this.onPrivacy,
    required this.onAbout,
    required this.onFeedback,
    required this.onRevoke,
    required this.onCancelAccount,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(21, 24, 21, 20),
          child: Column(
            children: [
              // Image.asset(AppAssets.appLogo, width: 72, height: 72),
              // const SizedBox(height: 12),
              // Text(
              //   '欢迎使用${AppInfoUtil.appName}',
              //   style: const TextStyle(
              //     color: Color(0xFF3C3C3C),
              //     fontSize: 16,
              //   ),
              // ),
              // const SizedBox(height: 20),
              _item('用户协议', AppAssets.toolsBoxSettingUser, onPolicy),
              _item('隐私协议', AppAssets.toolsBoxSettingPrivacy, onPrivacy),
              _item('关于我们', AppAssets.toolsBoxSettingAbout, onAbout),
              _item('意见反馈', AppAssets.toolsBoxSettingFeedback, onFeedback),
              _item('撤销同意用户协议', AppAssets.toolsBoxSettingRevoke, onRevoke),
              _item('账号注销', AppAssets.toolsBoxSettingCancel, onCancelAccount),
            ],
          ),
        ),
      );

  Widget _item(String title, String icon, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 63,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image.asset(icon, width: 28, height: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: Color(0xFF3C3C3C), fontSize: 16)),
                ),
                Image.asset(AppAssets.toolsBoxSettingArrow,
                    width: 10, height: 18),
              ],
            ),
          ),
        ),
      );
}

class _ToolHeroCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ToolHeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('尺子',
                          style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 30,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: 6),
                      Text(
                        '直尺可精准丈量长度、绘制直线，三角尺用来画垂线与标准角度，搭配量角器完成角度测算，满足绘图、施工、日常各类测量需求。',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 13,
                            height: 1.54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(AppAssets.toolsBoxRuler,
                    width: 150, height: 116, fit: BoxFit.contain),
              ],
            ),
          ),
        ),
      );
}

class _ToolGridCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final VoidCallback onTap;

  const _ToolGridCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Image.asset(icon, width: 70, height: 63, fit: BoxFit.contain),
                const SizedBox(height: 7),
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                Text(description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF797979), fontSize: 12)),
              ],
            ),
          ),
        ),
      );
}
