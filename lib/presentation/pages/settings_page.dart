import 'package:flutter/material.dart';

import '../../features/bootstrap/app_view_model.dart';
import 'about_page.dart';
import 'feedback_page.dart';
import 'policy_web_page.dart';

const _assetRoot = 'assets/images/recipes_tools';

/// “我的”页 —— 对应 Android setting 模块 SettingToolFragment3 +
/// fragment_setting_tool3.xml：顶部横幅（aa_bb）+ 居中头像（photo，
/// 上叠 50dp）+ 白色设置卡片（隐私协议/用户条款/联系我们/关于我们/
/// 个性化推荐开关）。隐藏的“检查更新”行原版为 GONE，不迁移。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.viewModel});

  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            children: [
              // 顶部横幅：aa_bb（match_parent 宽，固有高约 143dp）
              Image.asset(
                '$_assetRoot/aa_bb.png',
                width: double.infinity,
                fit: BoxFit.fill,
              ),
              // 头像 photo（86dp，居中，marginTop -50 叠在横幅上）
              Transform.translate(
                offset: const Offset(0, -50),
                child: Center(
                  child: Image.asset(
                    '$_assetRoot/photo.png',
                    width: 86,
                    height: 86,
                  ),
                ),
              ),
              // 设置卡片（CardView：圆角 4dp、elevation 8、marginH 20、marginTop 20）
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _SettingRow(
                      icon: 'yinsi_hei.png',
                      iconSize: const Size(14, 16),
                      label: '隐私协议',
                      marginTop: 10,
                      onTap: () => _openPolicy(context,
                          title: '隐私协议',
                          url:
                              'http://api.jyhytech.top/agreement/bjlxcp/privacy'),
                    ),
                    _SettingRow(
                      icon: 'user_hei.png',
                      iconSize: const Size(16, 12),
                      label: '用户条款',
                      marginTop: 15,
                      onTap: () => _openPolicy(context,
                          title: '用户协议',
                          url: 'http://api.jyhytech.top/agreement/bjlxcp/user'),
                    ),
                    _SettingRow(
                      icon: 'lianxi_hei.png',
                      iconSize: const Size(16, 12),
                      label: '联系我们',
                      marginTop: 10,
                      onTap: () => _openFeedback(context),
                    ),
                    _SettingRow(
                      icon: 'guanyu_hei.png',
                      iconSize: const Size(16, 16),
                      label: '关于我们',
                      marginTop: 10,
                      onTap: () => _openAbout(context),
                    ),
                    _SwitchRow(viewModel: viewModel),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 隐私协议/用户条款 —— 原版分别跳 PolicySettActivity / PolicyToolsSetActivity。
  void _openPolicy(BuildContext context,
      {required String title, required String url}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PolicyWebPage(title: title, url: url),
    ));
  }

  /// 联系我们 —— 原版跳 FeedBackSettingActivity（意见反馈）。
  void _openFeedback(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const FeedbackPage(),
    ));
  }

  /// 关于我们 —— 原版跳 AboutToolSetActivity。
  void _openAbout(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const AboutPage(),
    ));
  }
}

/// 设置行 —— 对应布局中 drawableLeft 图标 + 16sp #121212 文案 +
/// drawableRight back_hei 右箭头，行高 50dp。
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.iconSize,
    required this.label,
    required this.onTap,
    this.marginTop = 10,
  });

  final String icon;
  final Size iconSize;
  final String label;
  final VoidCallback onTap;
  final double marginTop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 50,
        margin: EdgeInsets.only(left: 15, right: 15, top: marginTop),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Image.asset(
              '$_assetRoot/$icon',
              width: iconSize.width,
              height: iconSize.height,
            ),
            const SizedBox(width: 10), // drawablePadding 10dp
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Color(0xFF121212), fontSize: 16),
              ),
            ),
            // 右箭头 back_hei（8x14dp）
            Image.asset(
              '$_assetRoot/back_hei.png',
              width: 8,
              height: 14,
            ),
          ],
        ),
      ),
    );
  }
}

/// 个性化推荐行 —— gexing_hei 图标 + 文案 + Switch。
/// 开关状态持久化（Android myPreferences.isSetting），切换 Toast "修改成功"。
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.viewModel});

  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Image.asset(
            'assets/images/recipes_tools/gexing_hei.png',
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '个性化推荐',
              style: TextStyle(color: Color(0xFF121212), fontSize: 16),
            ),
          ),
          Switch(
            value: viewModel.isSetting,
            onChanged: (value) async {
              await viewModel.setSetting(value);
              if (!context.mounted) return;
              // 对应原版 Toast "修改成功"
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('修改成功'),
                    duration: Duration(milliseconds: 1500)),
              );
            },
          ),
        ],
      ),
    );
  }
}
