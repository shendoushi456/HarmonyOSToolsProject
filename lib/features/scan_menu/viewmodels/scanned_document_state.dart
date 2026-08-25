import '../models/scanned_document.dart';

class ScannedDocumentState {
  const ScannedDocumentState({
    this.documents = const [],
    this.isLoading = false,
    this.newestFirst = true,
    this.errorMessage,
  });

  final List<ScannedDocument> documents;
  final bool isLoading;
  final bool newestFirst;
  final String? errorMessage;

  ScannedDocumentState copyWith({
    List<ScannedDocument>? documents,
    bool? isLoading,
    bool? newestFirst,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ScannedDocumentState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      newestFirst: newestFirst ?? this.newestFirst,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
