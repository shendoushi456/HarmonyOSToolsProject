import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/recipe_models.dart';
import '../../data/repositories/recipe_catalog_repository.dart';
import '../../data/services/preferences_store.dart';

final appViewModelProvider = Provider<AppViewModel>((ref) {
  throw UnimplementedError('AppViewModel must be overridden at startup.');
});

/// 应用级 ViewModel：仅编排数据加载与状态变更，页面可整体替换而不影响业务规则。
class AppViewModel extends ChangeNotifier {
  AppViewModel({
    required RecipeCatalogRepository catalogRepository,
    required PreferencesStore preferencesStore,
  })  : _catalogRepository = catalogRepository,
        _preferencesStore = preferencesStore;

  final RecipeCatalogRepository _catalogRepository;
  final PreferencesStore _preferencesStore;

  RecipeCatalog? _catalog;
  bool _isLoading = false;
  Object? _loadError;
  Set<int> _favoriteIds = <int>{};
  List<int> _recentIds = <int>[];
  bool _isPrivacyAccepted = false;
  bool _isOnboardingDone = false;

  RecipeCatalog? get catalog => _catalog;
  bool get isLoading => _isLoading;
  Object? get loadError => _loadError;
  bool get isPrivacyAccepted => _isPrivacyAccepted;
  bool get isOnboardingDone => _isOnboardingDone;
  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);

  Future<void> initialize() async {
    if (_isLoading || _catalog != null) return;
    _isLoading = true;
    _loadError = null;
    notifyListeners();
    try {
      _isPrivacyAccepted = _preferencesStore.isPrivacyAccepted;
      _isOnboardingDone = _preferencesStore.isOnboardingDone;
      _favoriteIds = _preferencesStore.favoriteIds;
      _recentIds = _preferencesStore.recentIds;
      _catalog = await _catalogRepository.loadCatalog();
    } catch (error) {
      _loadError = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Recipe> recipesForCategory(int categoryId) =>
      _catalog?.recipes
          .where((recipe) => recipe.categoryId == categoryId)
          .toList() ??
      const [];

  List<Recipe> get favoriteRecipes => _recipesFromIds(_favoriteIds);
  List<Recipe> get recentRecipes => _recipesFromIds(_recentIds);

  /// 原 Android “食谱”页：展示本地目录中的全部食谱，而不是最近浏览记录。
  List<Recipe> get allRecipes => _catalog?.recipes ?? const [];
  bool isFavorite(int recipeId) => _favoriteIds.contains(recipeId);

  Future<void> acceptPrivacy() async {
    await _preferencesStore.acceptPrivacy();
    _isPrivacyAccepted = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _preferencesStore.completeOnboarding();
    _isOnboardingDone = true;
    notifyListeners();
  }

  Future<void> toggleFavorite(int recipeId) async {
    if (_favoriteIds.contains(recipeId)) {
      _favoriteIds.remove(recipeId);
    } else {
      _favoriteIds.add(recipeId);
    }
    notifyListeners();
    await _preferencesStore.saveFavoriteIds(_favoriteIds);
  }

  Future<void> recordRecipeOpened(int recipeId) async {
    _recentIds = _recentIds.where((id) => id != recipeId).toList()
      ..insert(0, recipeId);
    notifyListeners();
    await _preferencesStore.recordRecent(recipeId);
  }

  List<Recipe> _recipesFromIds(Iterable<int> ids) {
    final catalog = _catalog;
    if (catalog == null) return const [];
    return ids
        .map(catalog.recipeById)
        .whereType<Recipe>()
        .toList(growable: false);
  }
}
