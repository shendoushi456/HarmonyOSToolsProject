// 我的 Tab - 对齐 Android third-module/setting SettingToolFragment.kt + fragment_setting_tool.xml
// 白底;顶栏 50dp #6FBFFF(purple_200) 居中黑 16sp bold「设置」+左返回键(保真显示,Tab 页不绑定退出);
// 4 个入口卡(50dp 白底圆角12,左图标+16sp #FF121212+右箭头): 用户协议/隐私协议/关于我们/意见反馈
// 个性化推荐开关原版 visibility=gone,不迁移;协议 URL 复用 SettingUrls(api.jyhytech.top,可达)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../utils/app_info_util.dart';

/// setting 模块主题色(对齐 colors.xml purple_200)
const Color _kSettingTheme = Color(0xFF6FBFFF);

class SettingToolPage extends StatelessWidget {
  const SettingToolPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ===== 顶栏(状态栏+50dp+10dp #6FBFFF) =====
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: _kSettingTheme,
            child: SizedBox(
              height: 60 - MediaQuery.of(context).padding.top,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text('设置',
                      style: TextStyle(
                          color: Color(0xFF121212),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Positioned(
                    left: 10,
                    child: Image.asset(AppAssets.settingBoxIvBack,
                        width: 24, height: 24),
                    // 保真: 原版返回键点击 finish,作为 Tab 页不绑定行为
                  ),
                ],
              ),
            ),
          ),
          // ===== 入口卡列表(边距15,卡间距10) =====
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _entryCard(
                    icon: AppAssets.settingBoxUserAgrement,
                    label: '用户协议',
                    onTap: () => context.push(RoutePaths.policy,
                        extra: {'title': '用户协议', 'url': SettingUrls.user}),
                  ),
                  _entryCard(
                    icon: AppAssets.settingBoxIcPr,
                    label: '隐私协议',
                    onTap: () => context.push(RoutePaths.policy,
                        extra: {'title': '隐私协议', 'url': SettingUrls.policy}),
                  ),
                  _entryCard(
                    icon: AppAssets.settingBoxIcUs,
                    label: '关于我们',
                    onTap: () => context.push(RoutePaths.about),
                  ),
                  _entryCard(
                    icon: AppAssets.settingBoxIcYj,
                    label: '意见反馈',
                    onTap: () => context.push(RoutePaths.feedback),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 入口卡(高50dp 白底圆角12 click_shap_white,左右15/上10,内 padding 15,
  /// 左图标+16sp #FF121212 文字+右箭头)
  Widget _entryCard({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 24, height: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Color(0xFF121212), fontSize: 16)),
            ),
            Image.asset(AppAssets.settingBoxArrowRight, width: 18, height: 18),
          ],
        ),
      ),
    );
  }
}
