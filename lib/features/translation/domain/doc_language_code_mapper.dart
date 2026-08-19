/// 文档翻译语言代码映射
///
/// 对应原 Android `LanguageCodeMapper`，文档翻译支持的语言子集（17 种）。
/// 与文本翻译的 `LanguageList` 不同，文档翻译仅支持有限语言。
class DocLanguageCodeMapper {
  DocLanguageCodeMapper._();

  /// 中文语言名 → 有道 API 代码映射
  static const Map<String, String> _languageMap = {
    '自动': 'auto',
    '中文': 'zh-CHS',
    '英文': 'en',
    '日文': 'ja',
    '韩文': 'ko',
    '法文': 'fr',
    '俄文': 'ru',
    '西班牙文': 'es',
    '葡萄牙文': 'pt',
    '德文': 'de',
    '意大利文': 'it',
    '越南文': 'vi',
    '印尼文': 'id',
    '阿拉伯文': 'ar',
    '荷兰文': 'nl',
    '泰文': 'th',
    '繁体中文': 'zh-CHT',
  };

  /// 将中文语言名称转换为 API 语言代码
  static String toApiCode(String languageName) {
    return _languageMap[languageName] ?? 'auto';
  }

  /// 校验官方文档列出的文档翻译语向。
  ///
  /// 文本翻译的语种范围更大，不能直接复用于文档翻译；否则服务端会返回
  /// 18014（不支持的语言）。源语种为 auto 时由服务端识别，可搭配任一目标语种。
  static bool isSupportedDirection(String from, String to) {
    final fromCode = toApiCode(from);
    final toCode = toApiCode(to);
    if (fromCode == 'auto') {
      return toCode != 'auto';
    }
    return _supportedDirections.contains('$fromCode>$toCode');
  }

  static const Set<String> _supportedDirections = {
    'zh-CHS>en',
    'zh-CHS>ja',
    'zh-CHS>ko',
    'zh-CHS>ru',
    'zh-CHS>fr',
    'zh-CHS>th',
    'en>zh-CHS',
    'en>fr',
    'en>th',
    'ja>zh-CHS',
    'ja>en',
    'ko>zh-CHS',
    'ko>en',
    'ru>zh-CHS',
    'ru>en',
    'fr>zh-CHS',
    'fr>en',
    'th>zh-CHS',
    'th>en',
    'hi>en',
    'vi>zh-CHS',
    'vi>en',
    'id>zh-CHS',
    'ar>zh-CHS',
    'ar>en',
    'de>zh-CHS',
    'it>zh-CHS',
    'nl>zh-CHS',
    'es>zh-CHS',
    'pt>zh-CHS',
  };

  /// 获取支持的语言列表
  static List<String> getSupportedLanguages() {
    return _languageMap.keys.toList();
  }
}
