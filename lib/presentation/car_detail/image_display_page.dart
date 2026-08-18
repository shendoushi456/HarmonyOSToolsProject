import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/providers/car_detail_provider.dart';
import '../theme/app_colors.dart';

/// 图片展示页
///
/// 对应 Android: toolCarLib/CarDetailJumpTo.kt + tools_extra_lib/ImageDisplayActivity.kt
/// 顶栏绿色（CarDetailJumpTo 始终传 0xFF0FC093）+ 可滚动展示对应类型的详情图。
class ImageDisplayPage extends ConsumerWidget {
  final String type;

  const ImageDisplayPage({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailType = ref.watch(carDetailByLabelProvider(type));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(type),
      ),
      body: detailType == null
          ? const Center(
              child: Text(
                '图片资源未找到',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Image.asset(
                detailType.assetPath,
                fit: BoxFit.fitWidth,
              ),
            ),
    );
  }
}
