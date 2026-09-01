// toolbox_c ToolsFragment 迁移：三个识别入口复用已有 RecognitionPage 数据链路。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../router/route_names.dart';
import '../../recognition/models/recognition_type.dart';
import '../viewmodels/toolbox_menu_view_model.dart';

class ToolsFragmentPage extends StatelessWidget {
  const ToolsFragmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = ToolboxMenuViewModel.instance.recognitionItems;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2F2F4),
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          const SizedBox(
            height: 50,
            child: Center(
              child: Text('工具',
                  style: TextStyle(fontSize: 22, color: Colors.black)),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 30),
              itemBuilder: (context, index) => _RecognitionCard(
                item: items[index],
                onTap: () => context.push(
                  RoutePaths.recognition,
                  extra: _recognitionType(items[index].type),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  RecognitionType _recognitionType(String type) {
    if (type == 'plant') return RecognitionType.plant;
    if (type == 'ingredient') return RecognitionType.ingredient;
    return RecognitionType.animal;
  }
}

class _RecognitionCard extends StatelessWidget {
  const _RecognitionCard({required this.item, required this.onTap});
  final ToolboxRecognitionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Image.asset(item.asset, width: 66, height: 66),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 19),
                child: Text(item.prompt,
                    style: const TextStyle(fontSize: 15, color: Colors.black)),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.gradient.map((value) => Color(value)).toList(),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(item.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ]),
          ),
        ),
      );
}
