import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../recognition/models/recognition_type.dart';

const _background = Color(0xFFD8EFFF);
const _blue = Color(0xFF2879DE);

/// Android MoreComposeFragment 的 Flutter 迁移版。识别卡只迁移 UI。
class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
          _Header(onSettings: () => context.push(RoutePaths.setting)),
          _NotebookCard(onTap: () => context.push(RoutePaths.notebook)),
          const SizedBox(height: 16),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(
                    child: _RecognitionCard(
                        title: '银行卡识别',
                        description: '快速识别银行卡信息',
                        action: '点击扫描',
                        background: AppAssets.toolboxBankCard,
                        icon: AppAssets.toolboxBank,
                        onTap: () => _openRecognition(
                            context, RecognitionType.bankCard))),
                const SizedBox(width: 10),
                Expanded(
                    child: _RecognitionCard(
                        title: '文字识别',
                        description: '快速识别文字内容',
                        action: '点击识别',
                        background: AppAssets.toolboxTextCard,
                        icon: AppAssets.toolboxText,
                        onTap: () =>
                            _openRecognition(context, RecognitionType.text))),
              ])),
          const SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(
                    child: _RecognitionCard(
                        title: '植物识别',
                        description: '对准植物直观了解',
                        action: '点击识别',
                        background: AppAssets.toolboxPlantCard,
                        icon: AppAssets.toolboxPlant,
                        onTap: () =>
                            _openRecognition(context, RecognitionType.plant))),
                const SizedBox(width: 10),
                Expanded(
                    child: _RecognitionCard(
                        title: '动物识别',
                        description: '一键快速查看动物种类',
                        action: '点击识别',
                        background: AppAssets.toolboxAnimalCard,
                        icon: AppAssets.toolboxAnimal,
                        onTap: () =>
                            _openRecognition(context, RecognitionType.animal))),
              ])),
        ]),
      ),
    );
  }

  void _openRecognition(BuildContext context, RecognitionType type) =>
      context.push(RoutePaths.recognition, extra: type);
}

class _Header extends StatelessWidget {
  final VoidCallback onSettings;
  const _Header({required this.onSettings});
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 67,
      child: Stack(children: [
        const Center(
            child: Text('百宝箱',
                style: TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 22,
                    fontWeight: FontWeight.w600))),
        Positioned(
            right: 20,
            top: 14,
            child: GestureDetector(
                onTap: onSettings,
                child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                        color: _blue, shape: BoxShape.circle),
                    child: const Icon(Icons.settings,
                        color: Colors.white, size: 21)))),
      ]));
}

class _NotebookCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NotebookCard({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: SizedBox(
          height: 185,
          child: Stack(children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(AppAssets.toolboxNotebookCard,
                        width: double.infinity,
                        height: 185,
                        fit: BoxFit.fill))),
            const Positioned(
                left: 43,
                top: 27,
                child: SizedBox(
                    width: 171,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('记事本',
                              style: TextStyle(
                                  color: Color(0xFF14549B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 17),
                          Text('记事本可快速记录文字、随手备忘、整理灵感笔记，简洁高效满足日常轻量书写需求。',
                              style: TextStyle(
                                  color: Color(0xFF75B5FC),
                                  fontSize: 12,
                                  height: 1.42,
                                  fontWeight: FontWeight.w500))
                        ]))),
            Positioned(
                right: 41,
                top: 25,
                child: Image.asset(AppAssets.toolboxNotebook,
                    width: 90, height: 108, fit: BoxFit.contain)),
            Positioned(
                left: 44,
                right: 44,
                bottom: 20,
                child: Container(
                    height: 31,
                    decoration: BoxDecoration(
                        color: const Color(0xFFC3E6FF),
                        borderRadius: BorderRadius.circular(44)),
                    alignment: Alignment.center,
                    child: const Text('点击使用',
                        style: TextStyle(
                            color: Color(0xFF14549B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)))),
          ])));
}

class _RecognitionCard extends StatelessWidget {
  final String title, description, action, background, icon;
  final VoidCallback onTap;
  const _RecognitionCard(
      {required this.title,
      required this.description,
      required this.action,
      required this.background,
      required this.icon,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: SizedBox(
          height: 92,
          child: Stack(children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(background,
                    width: double.infinity, height: 92, fit: BoxFit.fill)),
            Positioned(
                left: 10,
                top: 14,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.28,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 3),
                      SizedBox(
                          width: 100,
                          child: Text(description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  height: 1.35))),
                      const SizedBox(height: 10),
                      Container(
                          width: 62,
                          height: 20,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(23)),
                          alignment: Alignment.center,
                          child: Text(action,
                              style: const TextStyle(
                                  color: Color(0xFF14549B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500)))
                    ])),
            Positioned(
                right: 10,
                bottom: 8,
                child: Image.asset(icon,
                    width: 46, height: 46, fit: BoxFit.contain)),
          ])));
}
