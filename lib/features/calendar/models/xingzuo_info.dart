// 星座运势模型 - 对齐 Android XingzuoInfo/XingzuoBean (XingzuoBean.kt)
/// 天api 星座接口返回: {"code":200,"msg":"success","result":{"title":"...","grade":"...","content":"..."}}
class XingzuoInfo {
  final int code;
  final String msg;
  final XingzuoBean? result;

  const XingzuoInfo({
    required this.code,
    required this.msg,
    this.result,
  });

  factory XingzuoInfo.fromJson(Map<String, dynamic> json) {
    return XingzuoInfo(
      code: json['code'] is int
          ? json['code'] as int
          : int.tryParse(json['code']?.toString() ?? '') ?? 0,
      msg: json['msg']?.toString() ?? '',
      result: json['result'] is Map<String, dynamic>
          ? XingzuoBean.fromJson(json['result'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 星座运势详情 - 对齐 Android XingzuoBean
class XingzuoBean {
  final String title;
  final String grade;
  final String content;

  const XingzuoBean({
    required this.title,
    required this.grade,
    required this.content,
  });

  factory XingzuoBean.fromJson(Map<String, dynamic> json) {
    return XingzuoBean(
      title: json['title']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }
}
