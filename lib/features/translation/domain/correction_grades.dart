/// 作文批改等级
///
/// 对应原 Android `CorrectionGrades`，保真等级列表与 API 代码映射。
class CorrectionGrades {
  CorrectionGrades._();

  /// 等级显示名称列表
  static const List<String> grades = [
    '默认',
    '小学',
    '高中',
    '四级',
    '六级',
    '考研',
    '托福',
    'GRE',
    '雅思',
  ];

  /// 显示名称 → API 代码映射
  static const Map<String, String> _gradeMap = {
    '默认': 'default',
    '小学': 'elementary',
    '高中': 'high',
    '四级': 'cet4',
    '六级': 'cet6',
    '考研': 'graduate',
    '托福': 'toefl',
    'GRE': 'gre',
    '雅思': 'ielts',
  };

  /// 获取 API 等级代码
  static String getGradeCode(String displayName) {
    return _gradeMap[displayName] ?? 'default';
  }
}
