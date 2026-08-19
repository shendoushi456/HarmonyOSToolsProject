import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ScanMenu 底部导航当前 Tab 索引（0=首页/1=汽车指示灯/2=应急电话）
/// 对应 Android: ScanMenuActivity 的 TAB_INDEX extra + onNavigationItemSelected
final selectedTabProvider = StateProvider<int>((ref) => 0);
