/// TTS 支持的语言列表
///
/// 对应原 Android `TtsSupportLanguages`，保真还原支持 TTS 的语言集合（中文名）。
/// 用于语言选择页显示麦克风图标。
class TtsSupportLanguages {
  TtsSupportLanguages._();

  /// 支持 TTS 的语言集合（中文名）
  static const Set<String> supportedLanguages = {
    '中文',
    '英文',
    '日文',
    '韩文',
    '法文',
    '西班牙文',
    '葡萄牙文',
    '俄文',
    '德文',
    '阿拉伯文',
    '印尼文',
    '加泰隆文',
    '捷克文',
    '丹麦文',
    '希腊文',
    '芬兰文',
    '希伯来文',
    '印地文',
    '匈牙利文',
    '意大利文',
    '荷兰文',
    '挪威文',
    '波兰文',
    '罗马尼亚文',
    '斯洛伐克文',
    '瑞典文',
    '泰文',
    '土耳其文',
    '粤语',
    '繁体中文',
  };

  /// 判断语言是否支持 TTS
  static bool isTtsSupported(String language) {
    return supportedLanguages.contains(language);
  }
}
