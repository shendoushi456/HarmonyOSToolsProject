// 基础 widget 测试 - 验证 App 能正常构建
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qingman_weather/app/recipe_app.dart';
import 'package:qingman_weather/data/repositories/recipe_catalog_repository.dart';
import 'package:qingman_weather/data/services/preferences_store.dart';
import 'package:qingman_weather/features/bootstrap/app_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App 构建测试', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'privacy_accepted_v1': true,
      'recipe_onboarding_done_v1': true,
    });
    final preferences = await SharedPreferences.getInstance();
    final viewModel = AppViewModel(
      catalogRepository: const AssetRecipeCatalogRepository(),
      preferencesStore: PreferencesStore(preferences),
    );
    await viewModel.initialize();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appViewModelProvider.overrideWithValue(viewModel)],
        child: const RecipeApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
  });
}
