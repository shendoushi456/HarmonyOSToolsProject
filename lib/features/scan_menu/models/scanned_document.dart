/// 文档库领域模型。与具体页面和存储位置解耦，便于后续马甲包复用。
class ScannedDocument {
  const ScannedDocument({
    required this.path,
    required this.name,
    required this.modifiedAt,
  });

  final String path;
  final String name;
  final DateTime modifiedAt;
}
