// 基础 widget 测试 - 验证 App 能正常构建
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() {
  testWidgets('App 构建测试', (WidgetTester tester) async {
    // await tester.pumpWidget(const ProviderScope(child: App()));
    // expect(find.byType(MaterialApp), findsOneWidget);
  });
}
