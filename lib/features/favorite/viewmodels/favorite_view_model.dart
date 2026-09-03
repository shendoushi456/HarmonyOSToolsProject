import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../menu_fragment/models/tool_definition.dart';
import '../repositories/favorite_repository.dart';

class FavoriteState {
  const FavoriteState({this.ids = const <ToolId>{}, this.isLoading = true});

  final Set<ToolId> ids;
  final bool isLoading;

  bool contains(ToolDefinition tool) => ids.contains(tool.id);
}

class FavoriteViewModel extends Notifier<FavoriteState> {
  final _repository = FavoriteRepository();

  @override
  FavoriteState build() {
    Future.microtask(_load);
    return const FavoriteState();
  }

  Future<void> _load() async {
    final ids = await _repository.load();
    state = FavoriteState(ids: ids, isLoading: false);
  }

  Future<void> toggle(ToolDefinition tool) async {
    final ids = {...state.ids};
    if (!ids.add(tool.id)) {
      ids.remove(tool.id);
    }
    state = FavoriteState(ids: ids, isLoading: false);
    await _repository.save(ids);
  }
}

final favoriteViewModelProvider =
    NotifierProvider<FavoriteViewModel, FavoriteState>(FavoriteViewModel.new);
