import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/doc_language_code_mapper.dart';
import '../domain/supported_file_types.dart';
import 'doc_trans_api_client.dart';
import 'doc_trans_models.dart';

/// 文档翻译数据仓库
///
/// 对应原 Android `DocTranslationRepository`，封装配额管理、文件操作和 API 调用。
/// 配额键名保真：`doc_trans_last_use_date` / `doc_trans_daily_use_count`。
/// 语言设置复用文本翻译的键名（`translation_from_language` / `translation_to_language`），
/// 默认值"中文"/"英文"（与原项目一致）。
class DocTranslationRepository {
  DocTranslationRepository();

  static const int _dailyLimit = 1;
  static const String _keyLastUseDate = 'doc_trans_last_use_date';
  static const String _keyDailyUseCount = 'doc_trans_daily_use_count';
  static const String _keyFromLanguage = 'translation_from_language';
  static const String _keyToLanguage = 'translation_to_language';
  static const String _defaultFromLanguage = '中文';
  static const String _defaultToLanguage = '英文';
  static const MethodChannel _documentDownloadChannel = MethodChannel(
    'hm.ruisi.saosaole/document_download',
  );

  final DocTransApiClient _apiClient = DocTransApiClient();

  /// 获取每日限制次数
  int getDailyLimit() => _dailyLimit;

  /// 检查今日是否还可以使用
  Future<bool> canUseToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final lastUse = prefs.getString(_keyLastUseDate) ?? '';
    if (lastUse != today) {
      return true;
    }
    final count = prefs.getInt(_keyDailyUseCount) ?? 0;
    return count < _dailyLimit;
  }

  /// 获取今日剩余次数
  Future<int> getRemainingCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final lastUse = prefs.getString(_keyLastUseDate) ?? '';
    if (lastUse != today) {
      return _dailyLimit;
    }
    final count = prefs.getInt(_keyDailyUseCount) ?? 0;
    return count < _dailyLimit ? _dailyLimit - count : 0;
  }

  /// 记录一次使用
  Future<void> recordUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final lastUse = prefs.getString(_keyLastUseDate) ?? '';
    if (lastUse == today) {
      final count = prefs.getInt(_keyDailyUseCount) ?? 0;
      await prefs.setInt(_keyDailyUseCount, count + 1);
    } else {
      await prefs.setString(_keyLastUseDate, today);
      await prefs.setInt(_keyDailyUseCount, 1);
    }
  }

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

  /// 获取今日日期字符串（yyyy-MM-dd）
  String _todayString() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  /// 获取文件信息
  Future<FileInfo> getFileInfo(XFile file) async {
    final fileName = file.name;
    final fileSize = await file.length();
    final fileType = SupportedFileTypes.getFileType(fileName) ?? '';
    return FileInfo(
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
    );
  }

  /// 验证文件
  ///
  /// 返回错误消息，null 表示验证通过。
  Future<String?> validateFile(XFile file, String fileName) async {
    if (!SupportedFileTypes.isSupported(fileName)) {
      return '不支持的文件格式';
    }
    final fileSize = await file.length();
    if (fileSize > SupportedFileTypes.maxFileSize) {
      return '文件大小超过10MB限制';
    }
    if (fileSize == 0) {
      return '无法读取文件';
    }
    return null;
  }

  /// 上传文档
  Future<DocUploadResponse> uploadDocument({
    required XFile file,
    required String fileName,
    required String fileType,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    if (!DocLanguageCodeMapper.isSupportedDirection(
      fromLanguage,
      toLanguage,
    )) {
      throw Exception('该文档翻译不支持 $fromLanguage → $toLanguage');
    }
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    if (base64Str.length > 40 * 1024 * 1024) {
      throw Exception('文件 Base64 编码后超过40MB限制');
    }
    final langFrom = DocLanguageCodeMapper.toApiCode(fromLanguage);
    final langTo = DocLanguageCodeMapper.toApiCode(toLanguage);
    return _apiClient.uploadDocument(
      q: base64Str,
      fileName: fileName,
      fileType: fileType,
      langFrom: langFrom,
      langTo: langTo,
    );
  }

  /// 查询翻译状态
  Future<DocQueryResponse> queryStatus(String flownumber) {
    return _apiClient.queryStatus(flownumber);
  }

  /// 下载并保存翻译后的文件
  ///
  /// 返回系统下载目录中的文件 URI。
  Future<String> downloadAndSaveFile(
    String flownumber,
    String fileName, {
    String? downloadFileType,
  }) async {
    final resolvedDownloadType =
        downloadFileType ?? _downloadTypeForFileName(fileName);
    final bytes = await _apiClient.downloadFile(
      flownumber,
      downloadFileType: resolvedDownloadType,
    );
    final translatedName =
        _generateTranslatedFileName(fileName, resolvedDownloadType);
    final savedUri = await _documentDownloadChannel.invokeMethod<String>(
      'saveToDownloads',
      <String, Object>{
        'fileName': translatedName,
        'bytes': Uint8List.fromList(bytes),
      },
    );
    if (savedUri == null || savedUri.isEmpty) {
      throw Exception('保存到下载目录失败：原生层未返回保存路径');
    }
    return savedUri;
  }

  /// 将原文档类型转换为有道下载接口要求的类型。
  String _downloadTypeForFileName(String fileName) {
    final fileType = SupportedFileTypes.getFileType(fileName);
    return switch (fileType) {
      'doc' || 'docx' => 'word',
      'ppt' || 'pptx' => 'ppt',
      'xlsx' => 'xlsx',
      'pdf' => 'pdf',
      _ => 'pdf',
    };
  }

  /// 生成翻译后的文件名
  String _generateTranslatedFileName(
    String originalFileName,
    String downloadFileType,
  ) {
    final dotIndex = originalFileName.lastIndexOf('.');
    final nameWithoutExt = dotIndex > 0
        ? originalFileName.substring(0, dotIndex)
        : originalFileName;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = switch (downloadFileType.toLowerCase()) {
      'pdf' => 'pdf',
      'word' => 'docx',
      'ppt' => 'pptx',
      'xlsx' => 'xlsx',
      _ => 'pdf',
    };
    return '${nameWithoutExt}_translated_$timestamp.$ext';
  }
}

/// 文件信息
class FileInfo {
  const FileInfo({
    required this.fileName,
    required this.fileSize,
    required this.fileType,
  });

  final String fileName;
  final int fileSize;
  final String fileType;
}
