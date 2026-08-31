// 应用入口 - 立即交给 Flutter 渲染，存储初始化由启动页在首帧后完成。
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}
