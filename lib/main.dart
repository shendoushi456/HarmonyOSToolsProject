import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/recipe_app.dart';
import 'data/repositories/recipe_catalog_repository.dart';
import 'data/services/preferences_store.dart';
import 'features/bootstrap/app_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final preferencesStore = PreferencesStore(preferences);
  final viewModel = AppViewModel(
    catalogRepository: const AssetRecipeCatalogRepository(),
    preferencesStore: preferencesStore,
  );

  runApp(
    ProviderScope(
      overrides: [appViewModelProvider.overrideWithValue(viewModel)],
      child: const RecipeApp(),
    ),
  );
}
