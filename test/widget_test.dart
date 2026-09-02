// 基础 widget 测试 - 验证 App 能正常构建
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qingman_weather/app.dart';
import 'package:qingman_weather/core/storage/prefs_storage.dart';

void main() {
  testWidgets('App 构建测试', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await PrefsStorage.init();
    await tester.pumpWidget(const ProviderScope(child: App()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
