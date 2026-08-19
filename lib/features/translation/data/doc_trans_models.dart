/// 文档翻译 API 响应模型
///
/// 对应原 Android `DocUploadResponse` / `DocQueryResponse`。

/// 上传响应
class DocUploadResponse {
  DocUploadResponse({
    required this.errorCode,
    this.flownumber,
    this.msg,
  });

  factory DocUploadResponse.fromJson(Map<String, dynamic> json) {
    return DocUploadResponse(
      errorCode: json['errorCode']?.toString() ?? '',
      flownumber: json['flownumber']?.toString(),
      msg: json['msg']?.toString(),
    );
  }

  final String errorCode;
  final String? flownumber;
  final String? msg;

  bool get isSuccess =>
      errorCode == '0' && flownumber != null && flownumber!.isNotEmpty;
}

/// 查询响应
class DocQueryResponse {
  DocQueryResponse({
    required this.errorCode,
    required this.status,
    this.msg,
  });

  factory DocQueryResponse.fromJson(Map<String, dynamic> json) {
    return DocQueryResponse(
      errorCode: json['errorCode']?.toString() ?? '',
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
      msg: json['msg']?.toString(),
    );
  }

  final String errorCode;
  final int status;
  final String? msg;

  bool get isSuccess => errorCode == '0';
}
