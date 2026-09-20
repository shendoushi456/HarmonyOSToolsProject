// toolbox_c CropCategoryActivity(Compose 版)的 Flutter 迁移。
// 蓝渐变背景 + 横向类别卡(左侧大图标 + 白色文字条)。
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../weather/models/weather_warning.dart';
import '../models/agriculture_catalog.dart';
import '../models/agriculture_models.dart';
import 'crop_record_add_page.dart';
import 'crop_records_page.dart';

/// 对齐 Android AgricultureComposeUi 的公共配色
const agricultureDarkBlue = Color(0xFF208FEA);
const agricultureLightBlue = Color(0xFF69C4F3);
const agricultureAccentBlue = Color(0xFF238BF2);

/// 蓝渐变页面背景 - 对齐 AgricultureGradientBackground
class AgricultureGradientBackground extends StatelessWidget {
  final Widget child;
  const AgricultureGradientBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [agricultureDarkBlue, agricultureLightBlue],
        ),
      ),
      child: child,
    );
  }
}

/// 农业页通用标题栏 - 对齐 AgricultureHeader(返回 48 + 居中标题 + 尾随按钮)
class AgricultureHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;
  const AgricultureHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      width: double.infinity,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 48,
                height: 48,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onBack,
                  child: Center(
                    child: Image.asset(AppAssets.agricultureBack,
                        width: 27, height: 27),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500)),
            ),
            if (trailing != null)
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(width: 48, height: 48, child: trailing),
              ),
          ]),
        ),
      ),
    );
  }
}

/// 无水波纹图片按钮 - 对齐 HighContrastImageButton
class HighContrastImageButton extends StatelessWidget {
  final String image;
  final VoidCallback onTap;
  final double size;
  const HighContrastImageButton({
    super.key,
    required this.image,
    required this.onTap,
    this.size = 27,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
          child: Image.asset(image, width: size, height: size)),
    );
  }
}

class CropCategorySelectPage extends StatelessWidget {
  final List<WeatherWarning> warnings;
  const CropCategorySelectPage({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: agricultureDarkBlue,
      body: AgricultureGradientBackground(
        child: Column(children: [
          AgricultureHeader(
            title: '农作物类别选择',
            onBack: () => Navigator.of(context).maybePop(),
            trailing: HighContrastImageButton(
              image: AppAssets.agricultureCategoryList,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CropRecordsPage(warnings: warnings))),
            ),
          ),
          const SizedBox(height: 37),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  for (var index = 0;
                      index < agricultureCategories.length;
                      index++) ...[
                    _CropCategoryCard(
                      category: agricultureCategories[index],
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CropRecordAddPage(
                          category: agricultureCategories[index],
                          warnings: warnings,
                        ),
                      )),
                    ),
                    if (index != agricultureCategories.length - 1)
                      const SizedBox(height: 16),
                  ],
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// 类别卡 - 对齐 CropCategoryCard：76dp 高，白色文字条(54dp 全宽)压底部 + 左侧 89x71 图标
class _CropCategoryCard extends StatelessWidget {
  final CropCategory category;
  final VoidCallback onTap;
  const _CropCategoryCard({required this.category, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 76,
        width: double.infinity,
        child: Stack(children: [
          // 白色文字条：全宽 54dp 高，文字距左 102 / 距右 8
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 54,
            child: Container(
              padding: const EdgeInsets.only(left: 102, right: 8),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                category.selectionText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0xFF111111), fontSize: 12),
              ),
            ),
          ),
          // 图标：CenterStart 垂直居中后 offset(x=11, y=2)
          Positioned(
            left: 11,
            top: 4.5,
            child: Image.asset(category.iconAsset, width: 89, height: 71),
          ),
        ]),
      ),
    );
  }
}
