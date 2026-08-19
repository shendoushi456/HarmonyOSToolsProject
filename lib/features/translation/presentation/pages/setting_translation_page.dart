import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/core/app_config.dart';

import 'package:harmonyos_flutter_empty/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 工具中心页（Tab5）
///
/// 对应原 Android `SettingTranslationFragment`，保真还原 Compose UI：
/// 顶部背景图 + 圆角区 + logo + 功能卡片 + 设置项列表。
///
/// 移除项（按用户要求）：
/// - 文字识别（原 onTextRecognizeClick）
/// - 花果蔬菜识别（原 onPlantRecognizeClick）
///
/// 工具项：二维码扫描、生成二维码。
class SettingTranslationPage extends StatefulWidget {
  const SettingTranslationPage({super.key});

  @override
  State<SettingTranslationPage> createState() => _SettingTranslationPageState();
}

class _SettingTranslationPageState extends State<SettingTranslationPage> {
  static const MethodChannel _cameraPermissionChannel = MethodChannel(
    'com.hnrs.saolaisao/camera_permission',
  );
  static const String _qrCameraPermissionDeniedKey =
      'qr_scanner_camera_permission_denied';

  bool _isRequestingCameraPermission = false;

  void _navigateToPlaceholder(BuildContext context, String title) {
    context.push('/placeholder', extra: <String, dynamic>{'title': title});
  }

  /// 首次点击扫码时申请相机权限；拒绝状态存储在应用数据内。
  /// 清除应用数据或重新安装后，该标记会被清除，从而允许再次申请。
  Future<void> _openQrScanner() async {
    if (_isRequestingCameraPermission) return;
    _isRequestingCameraPermission = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_qrCameraPermissionDeniedKey) ?? false) {
        _showToast('获取相机权限被拒绝');
        return;
      }

      final granted = await _cameraPermissionChannel.invokeMethod<bool>(
        'requestCameraPermission',
      );
      if (granted != true) {
        await prefs.setBool(_qrCameraPermissionDeniedKey, true);
        if (mounted) _showToast('获取相机权限被拒绝');
        return;
      }

      if (mounted) await context.push<void>('/qr_scanner');
    } on PlatformException {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_qrCameraPermissionDeniedKey, true);
      if (mounted) _showToast('获取相机权限被拒绝');
    } finally {
      _isRequestingCameraPermission = false;
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEDF6FF),
      child: Container(
        color: AppColors.pageBackground,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildFunctionCardsSection(context),
                const SizedBox(height: 30),
                _buildSettingsSection(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 功能卡片区域（背景图 + 圆角区 + logo + 卡片网格）
  Widget _buildFunctionCardsSection(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Stack(
        children: [
          // 顶部背景图（高 205）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/ic_trans_setting_title.png',
              height: 205,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
          // 浅蓝圆角区（top 140，高 320）
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: Container(
              height: 320,
              decoration: const BoxDecoration(
                color: AppColors.pageBackground,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
            ),
          ),
          // 上层内容 Column（top 100）
          Padding(
            padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
            child: Column(
              children: [
                // logo（圆形）
                ClipOval(
                  child: Image.asset(
                    'assets/images/ic_logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                // 副标题
                const Text(
                  '欢迎使用扫莱扫',
                  style: TextStyle(
                    fontSize: 22,
                    color: AppColors.langSwitchText,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 30),
                // 第一行卡片：二维码扫描 + 生成二维码
                Row(
                  children: [
                    Expanded(
                      child: _FunctionCard(
                        title: '二维码扫描',
                        subtitle: '快速识别二维码内容',
                        gradientColors: const [
                          Color(0xFFFFE3A8),
                          Color(0xFFFFCE7F),
                        ],
                        icon: 'assets/images/ic_trans_setting_1_1.png',
                        onClick: _openQrScanner,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: _FunctionCard(
                        title: '生成二维码',
                        subtitle: '将文字或链接生成二维码',
                        gradientColors: const [
                          Color(0xFFB8F2FE),
                          Color(0xFF86DFFF),
                        ],
                        icon: 'assets/images/ic_trans_setting_1_3.png',
                        onClick: () => context.push('/qr_generator'),
                      ),
                    ),
                  ],
                ),
                // 第二行（文字识别 + 花果蔬菜识别）已按用户要求移除
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 设置项区域
  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      color: AppColors.pageBackground,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _SettingItem(
            icon: 'assets/images/ic_trans_setting_2_1.png',
            title: '隐私政策',
            onClick: () => context.push('/policy', extra: <String, dynamic>{
              'title': '隐私政策',
              'url': AppConfig.privacyUrl,
            }),
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: 'assets/images/ic_trans_setting_2_2.png',
            title: '用户协议',
            onClick: () => context.push('/policy', extra: <String, dynamic>{
              'title': '用户协议',
              'url': AppConfig.userAgreementUrl,
            }),
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: 'assets/images/ic_trans_setting_2_4.png',
            title: '关于我们',
            onClick: () => context.push('/about'),
          ),
          const SizedBox(height: 12),
          _SettingItem(
            icon: 'assets/images/ic_trans_setting_2_3.png',
            title: '意见反馈',
            onClick: () => context.push('/feedback'),
          ),
        ],
      ),
    );
  }
}

/// 功能卡片
///
/// 对应原 `FunctionCard`，保真布局：高 94，圆角 10，阴影，渐变背景，
/// 左侧标题+副标题，右侧图标 36dp。
class _FunctionCard extends StatelessWidget {
  const _FunctionCard({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.icon,
    required this.onClick,
  });

  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final String icon;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        height: 94,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            colors: gradientColors,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 左侧文字
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              // 右侧图标
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.asset(
                    icon,
                    width: 36,
                    height: 36,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 设置项
///
/// 对应原 `SettingItem`，保真布局：圆角 10，阴影，白色背景，
/// 左侧图标 20dp + 标题 16sp，右侧右箭头 24dp。
class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.title,
    required this.onClick,
  });

  final String icon;
  final String title;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset(
                  icon,
                  width: 20,
                  height: 20,
                  fit: BoxFit.fitWidth,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3C3C3C),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_right,
              color: AppColors.counterGray,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
