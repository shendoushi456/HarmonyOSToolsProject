import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/core/app_config.dart';
import 'package:harmonyos_flutter_empty/features/recognition/models/recognition_type.dart';

import '../../../scan_menu/pages/document_camera_page.dart';
import '../../../scan_menu/pages/document_capture_preview_page.dart';

/// 拍照存档入口：应用内拍照后进入预览/保存/裁剪链路
/// （对齐原 Android CameraWenDangActivity，自 master_mianfeisaosaowang 复制）。
Future<void> startPhotoArchive(BuildContext context) async {
  final file = await DocumentCameraPage.capture(context);
  if (file != null && context.mounted) {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DocumentCapturePreviewPage(file: file),
      ),
    );
  }
}

/// 页面背景色（保真原 `Color(0xFFF0F2F8)`）
const Color _pageBackground = Color(0xFFF0F2F8);

/// 慧语慧译页（Tab5 工具中心）
///
/// 对应原 Android `HuiYuHuiYiFragment`（toolbox_c Compose 版），保真还原：
/// "慧语慧译"标题 + 拍照存档/文字识别/格式转换三个功能卡片 +
/// 隐私政策/用户条款/关于我们/意见反馈四个设置项。
///
/// 功能卡入口映射（Flutter 端可复用功能有限）：
/// - 拍照存档：应用内拍照 → 预览/裁剪/水印 → 保存（对齐 CameraWenDangActivity）
/// - 文字识别：完整识别链路（/recognition，相机/相册 → 百度 AI OCR）
/// - 格式转换：跳转格式转化页（/format_convert）
class HuiYuHuiYiPage extends StatelessWidget {
  const HuiYuHuiYiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SingleChildScrollView(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 标题
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 24, bottom: 20),
                child: const Text(
                  '工具中心',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              // 三个功能卡片 - 横向排列
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        context,
                        title: '拍照存档',
                        subtitle: '识文精准',
                        icon: 'assets/images/ic_feature_photo_archive.webp',
                        onTap: () {
                          // 原 CameraWenDangActivity（拍照存档链路，
                          // 自 master_mianfeisaosaowang 复制）：
                          // 拍照 → 预览/裁剪/水印 → 保存到相册与文档列表
                          startPhotoArchive(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureCard(
                        context,
                        title: '文字识别',
                        subtitle: '秒识文字',
                        icon: 'assets/images/ic_feature_text_recognize.webp',
                        onTap: () {
                          // 原 NewCameraMagnifygActivity（OCR 取词），
                          // 文字识别完整链路（自 master_mianfeisaosaowang 复制）：
                          // 相机/相册 → 百度 AI OCR → 结果底部弹层
                          context.push(
                            '/recognition',
                            extra: RecognitionType.text,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureCard(
                        context,
                        title: '格式转换',
                        subtitle: '智转文本',
                        icon: 'assets/images/ic_feature_format_convert.webp',
                        onTap: () {
                          // 原 PdfToImgConversionActivity（格式转化页）
                          context.push('/format_convert');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSettingsList(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 功能卡片（背景图 + 左上角文字区域）
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            // 背景图片
            Positioned.fill(
              child: Image.asset(
                icon,
                fit: BoxFit.fill,
              ),
            ),
            // 左上角文字区域
            Positioned(
              left: 12,
              top: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A6CF7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B8AFF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 设置项列表
  Widget _buildSettingsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildSettingItem(
            context,
            icon: 'assets/images/ic_privacy_policy.webp',
            title: '隐私政策',
            onTap: () => context.push(
              '/policy',
              extra: <String, dynamic>{
                'title': '隐私政策',
                'url': AppConfig.privacyUrl,
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            context,
            icon: 'assets/images/ic_user_agreement.webp',
            title: '用户条款',
            onTap: () => context.push(
              '/policy',
              extra: <String, dynamic>{
                'title': '用户协议',
                'url': AppConfig.userAgreementUrl,
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            context,
            icon: 'assets/images/ic_about_us.webp',
            title: '关于我们',
            onTap: () => context.push('/about'),
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            context,
            icon: 'assets/images/ic_feedback.webp',
            title: '意见反馈',
            onTap: () => context.push('/feedback'),
          ),
        ],
      ),
    );
  }

  /// 设置项（白底行 + 图标 + 标题 + 右箭头）
  Widget _buildSettingItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            // 右箭头
            Transform.translate(
              offset: const Offset(0, -2),
              child: const Text(
                '›',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFFCCCCCC),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
