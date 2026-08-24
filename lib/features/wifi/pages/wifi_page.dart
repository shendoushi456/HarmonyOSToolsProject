// ColorDreamFragment Flutter 版：复刻“彩色绘梦”入口 UI。
// 图片编辑器 → 跟图绘画；图像动漫化 → 形状绘画。
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../life_tools/pages/color_draw_page.dart';
import '../../life_tools/pages/color_drawing_studio_page.dart';

class WifiPage extends StatelessWidget {
  const WifiPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFEAE5FF),
        body: SafeArea(
          bottom: false,
          child: Stack(children: [
            const Positioned(top: 0, left: 0, right: 0, child: _DreamTopBar()),
            Positioned.fill(
              top: 50,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                child: Column(children: [
                  _HeroCard(onTap: () => ColorDrawPage.push(context)),
                  const SizedBox(height: 20),
                  _FeatureCard(
                    image: AppAssets.colorDreamEditor,
                    title: '跟图绘画',
                    subtitle: '轻松画图，秒出质感！',
                    textOnRight: true,
                    onTap: () => ColorDrawingStudioPage.push(
                        context, ColorDrawingMode.trace),
                  ),
                  const SizedBox(height: 20),
                  _FeatureCard(
                    image: AppAssets.colorDreamAnime,
                    title: '形状绘画',
                    subtitle: '跟随形状绘画',
                    textOnRight: false,
                    onTap: () => ColorDrawingStudioPage.push(
                        context, ColorDrawingMode.shape),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ]),
        ),
      );
}

class _DreamTopBar extends StatelessWidget {
  const _DreamTopBar();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 50,
        child: Center(
            child: Text('灵感画色堡',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF222222)))),
      );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 210,
        child: Stack(children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('灵感画色堡',
                        style: TextStyle(
                            color: Color(0xFF352570),
                            fontSize: 36,
                            fontWeight: FontWeight.w500)),
                    const Text('方寸纸笔，万千世界！',
                        style: TextStyle(
                            color: Color(0xFF352570),
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 30),
                    _DreamButton(label: '开始创作', onTap: onTap, width: 84),
                  ]),
            ),
          ),
          Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                  child: Image.asset(AppAssets.colorDreamHero,
                      width: 162, fit: BoxFit.contain))),
        ]),
      );
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard(
      {required this.image,
      required this.title,
      required this.subtitle,
      required this.textOnRight,
      required this.onTap});
  final String image;
  final String title;
  final String subtitle;
  final bool textOnRight;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            height: 181,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFFDEB7FF), Color(0xFFFFD1A6)])),
            child: Stack(children: [
              if (textOnRight)
                Positioned(
                    left: 10,
                    top: 9,
                    bottom: 8,
                    child: Image.asset(image, width: 150, fit: BoxFit.fill))
              else
                Positioned(
                    right: 0,
                    top: 12,
                    bottom: 11,
                    child: Image.asset(image, width: 174, fit: BoxFit.fill)),
              Positioned(
                left: textOnRight ? 170 : 30,
                right: textOnRight ? 10 : 135,
                top: 0,
                bottom: 0,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text(subtitle,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 20),
                      _DreamButton(label: '开始绘画', onTap: onTap, width: 120),
                    ]),
              ),
            ]),
          ),
        ),
      );
}

class _DreamButton extends StatelessWidget {
  const _DreamButton(
      {required this.label, required this.onTap, required this.width});
  final String label;
  final VoidCallback onTap;
  final double width;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: width,
          height: 36,
          decoration: BoxDecoration(
              color: const Color(0xFFCA93D3),
              borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            if (label == '上传图片') ...[
              const SizedBox(width: 6),
              Image.asset(AppAssets.colorDreamArrow, width: 18, height: 18)
            ],
          ]),
        ),
      );
}
