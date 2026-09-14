import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/scanned_document_repository.dart';
import '../models/scanned_document.dart';
import 'scanned_document_state.dart';

final scannedDocumentRepositoryProvider =
    Provider<ScannedDocumentRepository>((ref) => ScannedDocumentRepository());

final scannedDocumentViewModelProvider =
    NotifierProvider<ScannedDocumentViewModel, ScannedDocumentState>(
  ScannedDocumentViewModel.new,
);

class ScannedDocumentViewModel extends Notifier<ScannedDocumentState> {
  @override
  ScannedDocumentState build() {
    Future<void>.microtask(refresh);
    return const ScannedDocumentState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final documents = await ref
          .read(scannedDocumentRepositoryProvider)
          .loadDocuments(newestFirst: state.newestFirst);
      state = state.copyWith(documents: documents, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: '文档加载失败，请稍后重试');
    }
  }

  Future<void> toggleSortOrder() async {
    state = state.copyWith(newestFirst: !state.newestFirst);
    await refresh();
  }

  Future<void> delete(ScannedDocument document) async {
    await ref.read(scannedDocumentRepositoryProvider).delete(document);
    await refresh();
  }
}
