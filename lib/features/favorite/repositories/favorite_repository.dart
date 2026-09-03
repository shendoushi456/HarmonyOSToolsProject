import 'package:shared_preferences/shared_preferences.dart';

import '../../menu_fragment/models/tool_definition.dart';

/// Persistence counterpart of Android's feature_prefs/selected_ids.
///
/// Tool ids, rather than titles or route names, are stored so a future skin
/// can change its presentation without invalidating existing favourites.
class FavoriteRepository {
  static const _key = 'favorite_tool_ids';

  Future<Set<ToolId>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_key) ?? const <String>[];
    return values
        .map((value) => ToolId.values.where((id) => id.name == value))
        .where((matches) => matches.isNotEmpty)
        .map((matches) => matches.first)
        .toSet();
  }

  Future<void> save(Set<ToolId> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.map((id) => id.name).toList());
  }
}
