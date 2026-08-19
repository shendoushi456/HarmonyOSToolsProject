import 'package:shared_preferences/shared_preferences.dart';

/// 翻译语言持久化存储
///
/// 对应原 Android `TranslationRepository`，使用 shared_preferences 持久化源/目标语言。
/// 键名保真：`translation_from_language` / `translation_to_language`。
///
/// 注意：原 Android 接口为同步（SharedPreferences 同步 API），
/// Flutter shared_preferences 为异步，故接口改为 Future。
class TranslationRepository {
  TranslationRepository();

  static const String _keyFromLanguage = 'translation_from_language';
  static const String _keyToLanguage = 'translation_to_language';
  static const String _defaultFromLanguage = '自动';
  static const String _defaultToLanguage = '中文';

  /// 获取源语言
  Future<String> getFromLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFromLanguage) ?? _defaultFromLanguage;
  }

  /// 获取目标语言
  Future<String> getToLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToLanguage) ?? _defaultToLanguage;
  }

  /// 保存源语言
  Future<void> saveFromLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFromLanguage, language);
  }

  /// 保存目标语言
  Future<void> saveToLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToLanguage, language);
  }
}
