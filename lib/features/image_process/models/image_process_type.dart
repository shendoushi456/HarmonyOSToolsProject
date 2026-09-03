/// Android NewCameraMagnifygActivity 中迁移的三项百度图像处理能力。
enum ImageProcessType {
  colourize('图片黑白上色', 'rest/2.0/image-process/v1/colourize'),
  styleTransfer('图像风格转换', 'rest/2.0/image-process/v1/style_trans'),
  selfieAnime('人像动漫化', 'rest/2.0/image-process/v1/selfie_anime');

  const ImageProcessType(this.title, this.endpoint);

  final String title;
  final String endpoint;

  bool get needsStyleSelection => this == ImageProcessType.styleTransfer;
}

/// 与 Android PicStyleActivity 的 option 参数和四个按钮一一对应。
enum ImageStyleOption {
  cartoon('卡通画风格', 'cartoon'),
  pencil('铅笔风格', 'pencil'),
  colorPencil('彩色铅笔画风格', 'color_pencil'),
  warm('彩色糖块油画风格', 'warm');

  const ImageStyleOption(this.label, this.apiValue);

  final String label;
  final String apiValue;
}
