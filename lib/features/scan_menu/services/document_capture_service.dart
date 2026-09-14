/// 拍照存档统一入口。相机页面负责应用内预览与拍照，服务仅保留业务异常类型。
class DocumentCaptureService {
  const DocumentCaptureService._();
}

class DocumentCaptureException implements Exception {
  const DocumentCaptureException(this.message);
  final String message;

  @override
  String toString() => message;
}
