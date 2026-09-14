enum RecognitionType {
  text('文字识别', 'rest/2.0/ocr/v1/general_basic'),
  plant('植物识别', 'rest/2.0/image-classify/v1/plant'),
  animal('动物识别', 'rest/2.0/image-classify/v1/animal'),
  bankCard('银行卡识别', 'rest/2.0/ocr/v1/bankcard'),
  ingredient('果蔬识别', 'rest/2.0/image-classify/v1/classify/ingredient'),
  dish('菜品识别', 'rest/2.0/image-classify/v2/dish'),
  object('物体识别', 'rest/2.0/image-classify/v2/advanced_general');

  final String title;
  final String endpoint;
  const RecognitionType(this.title, this.endpoint);
}
