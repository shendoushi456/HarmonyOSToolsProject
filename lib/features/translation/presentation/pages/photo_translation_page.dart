import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/core/theme/app_colors.dart';

/// 拍照翻译权限请求页（Tab2 入口）
///
/// 对应原 Android `PhotoTranslationFragment`，保真还原 Compose UI：
/// 装饰插画（ic_trans_photo_bg）+ 白色圆角卡片（标题+描述+开启按钮）。
///
/// 保真说明：原项目点击"开启相机权限"会请求相机权限，通过后跳转
/// [PhotoTranslationActivityPage]。鸿蒙侧相机预览改用相册导入方案
/// （无需相机权限），故此处点击直接跳转 Activity 页。
class PhotoTranslationPage extends StatelessWidget {
  const PhotoTranslationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 282),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 白色圆角卡片
              Padding(
                padding: const EdgeInsets.only(top: 45),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 45, bottom: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '拍照翻译',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 17),
                          child: Text(
                            '使用该功能需要您授予相机权限，通过拍照，您可以使用：拍照翻译/拍照点菜/文档扫描/文字提取/识别功能',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                              height: 24 / 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 61),
                        _buildOpenCameraButton(context),
                      ],
                    ),
                  ),
                ),
              ),
              // 装饰插画（绝对定位在卡片上方）
              Positioned(
                top: -40,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/ic_trans_photo_bg.png',
                    width: 153,
                    height: 153,
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

  /// "开启相机权限"按钮（保真渐变 0xFFF9BD03→0xFFFF890A）
  Widget _buildOpenCameraButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/photo_translation_activity'),
      child: Container(
        width: 196,
        height: 42,
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
            '开启相机权限',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
