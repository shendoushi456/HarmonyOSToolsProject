import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 壳页导航状态独立于页面，扫描流程可以切换到文档页而不产生页面循环引用。
final homeTabIndexProvider = StateProvider<int>((ref) => 0);
