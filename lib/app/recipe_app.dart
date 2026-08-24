import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/recipe_theme.dart';
import '../features/bootstrap/app_view_model.dart';
import '../presentation/pages/app_shell_page.dart';

class RecipeApp extends ConsumerWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(appViewModelProvider);
    return MaterialApp(
      title: '食谱',
      debugShowCheckedModeBanner: false,
      theme: buildRecipeTheme(),
      home: AppShellPage(viewModel: viewModel),
    );
  }
}
