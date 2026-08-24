import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../life_tools/pages/checklist/checklist_page.dart';
import '../../life_tools/pages/notebook/notebook_list_page.dart';
import '../../life_tools/pages/color_more/offline_category_page.dart';
import '../../life_tools/pages/color_more/nutrition_page.dart';
import '../../life_tools/pages/color_more/calculator_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE5FF),
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          SizedBox(
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 64),
                    child: Center(
                      child: Text(
                        '更多',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    icon: const Icon(
                      Icons.settings_outlined,
                      size: 28,
                      color: Color(0xFF222222),
                    ),
                    onPressed: () => context.push(RoutePaths.setting),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  child: Column(children: [
                    _OfflineCard(
                        onTap: () => OfflineCategoryPage.push(context)),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: _MoreCard(
                              image: AppAssets.colorMoreNutrition,
                              title: '营养指南',
                              subtitle: '均衡膳食，滋养身心',
                              onTap: () => NutritionPage.push(context))),
                      const SizedBox(width: 15),
                      Expanded(
                          child: _MoreCard(
                              image: AppAssets.colorMoreCalculator,
                              title: '大字计算器',
                              subtitle: '精准计算加减乘除',
                              onTap: () => CalculatorPage.push(context))),
                    ]),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: _MoreCard(
                              image: AppAssets.colorMoreNotebook,
                              title: '记事本',
                              subtitle: '随心记录文字',
                              onTap: () => NotebookListPage.push(context))),
                      const SizedBox(width: 15),
                      Expanded(
                          child: _MoreCard(
                              image: AppAssets.colorMoreTravel,
                              title: '旅行清单',
                              subtitle: '查看清单，避免遗漏',
                              onTap: () => ChecklistPage.push(context))),
                    ]),
                  ]))),
        ]),
      ),
    );
  }
}

class _OfflineCard extends StatelessWidget {
  const _OfflineCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 149,
          child: Row(children: [
            Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Image.asset(AppAssets.colorMoreOffline,
                    width: 125, height: 110, fit: BoxFit.contain)),
            const SizedBox(width: 25),
            const Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('离线涂鸦',
                      style: TextStyle(
                          color: Color(0xFF352570),
                          fontSize: 18,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text('无需网络离线创作，随心绘制涂鸦保存本地查看',
                      style: TextStyle(
                          color: Color(0xFF352570),
                          fontSize: 10,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 5),
                  _ActionPill(label: '点击涂鸦'),
                ])),
          ]),
        ),
      ),
    );
  }
}

class _MoreCard extends StatelessWidget {
  const _MoreCard(
      {required this.image,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final String image;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 138,
          child: Padding(
            padding: const EdgeInsets.only(left: 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image.asset(image,
                              height: 62, fit: BoxFit.contain)))),
              Text(title,
                  style: const TextStyle(
                      color: Color(0xFF9F6EC7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500)),
              Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF666666), fontSize: 14))),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
      height: 33,
      width: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: const Color(0xFF352570),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)));
}
