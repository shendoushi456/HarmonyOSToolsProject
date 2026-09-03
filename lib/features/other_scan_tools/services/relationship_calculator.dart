/// Relationship transition data ported from Android RelationShipData's common
/// paths.  Every keypad action is supported; unsupported deep paths retain
/// Android's friendly fallback copy instead of producing an invalid title.
class RelationshipCalculator {
  const RelationshipCalculator();

  static const unknown = '关系有点远，年长就叫老祖宗~\n同龄人就叫帅哥美女吧';
  static const _headers = [
    '爸爸',
    '妈妈',
    '哥哥',
    '弟弟',
    '姐姐',
    '妹妹',
    '儿子',
    '女儿',
    '妻子',
    '丈夫'
  ];

  static const _man = <String, List<String>>{
    '我': _headers,
    '爸爸': ['爷爷', '奶奶', '伯父', '叔叔', '姑妈', '姑妈', '我', '妹妹', '妈妈', ''],
    '妈妈': ['外公', '外婆', '大舅', '小舅', '大姨', '小姨', '我', '妹妹', '', '爸爸'],
    '哥哥': ['爸爸', '妈妈', '哥哥', '我', '姐姐', '妹妹', '侄子', '侄女', '嫂子', ''],
    '弟弟': ['爸爸', '妈妈', '我', '弟弟', '姐姐', '妹妹', '侄子', '侄女', '弟妹', ''],
    '姐姐': ['爸爸', '妈妈', '哥哥', '我', '姐姐', '妹妹', '外甥', '外甥女', '', '姐夫'],
    '妹妹': ['爸爸', '妈妈', '我', '弟弟', '姐姐', '妹妹', '外甥', '外甥女', '', '妹夫'],
    '儿子': ['我', '妻子', '儿子', '儿子', '女儿', '女儿', '孙子', '孙女', '儿媳', ''],
    '女儿': ['我', '妻子', '儿子', '儿子', '女儿', '女儿', '外孙', '外孙女', '', '女婿'],
    '妻子': ['岳父', '岳母', '大舅子', '小舅子', '大姨子', '小姨子', '儿子', '女儿', '', '我'],
    '爷爷': ['曾祖父', '曾祖母', '伯祖父', '叔祖父', '祖姑母', '祖姑母', '爸爸', '姑妈', '奶奶', ''],
    '奶奶': ['曾外祖父', '曾外祖母', '舅公', '舅公', '祖姨母', '祖姨母', '爸爸', '姑妈', '', '爷爷'],
    '伯父': ['爷爷', '奶奶', '伯父', '叔叔', '姑妈', '姑妈', '堂哥', '堂姐', '伯母', ''],
    '叔叔': ['爷爷', '奶奶', '伯父', '叔叔', '姑妈', '姑妈', '堂弟', '堂妹', '婶婶', ''],
    '姑妈': ['爷爷', '奶奶', '伯父', '叔叔', '姑妈', '姑妈', '姑表哥', '姑表姐', '', '姑丈'],
    '外公': [
      '外曾祖父',
      '外曾祖母',
      '伯外祖父',
      '叔外祖父',
      '姑外祖母',
      '姑外祖母',
      '舅舅',
      '妈妈',
      '外婆',
      ''
    ],
    '外婆': [
      '外曾外祖父',
      '外曾外祖母',
      '外舅公',
      '外舅公',
      '姨外祖母',
      '姨外祖母',
      '舅舅',
      '妈妈',
      '',
      '外公'
    ],
    '大舅': ['外公', '外婆', '大舅', '舅舅', '大姨', '妈妈', '舅表哥', '舅表姐', '大舅妈', ''],
    '小舅': ['外公', '外婆', '舅舅', '小舅', '妈妈', '小姨', '舅表弟', '舅表妹', '小舅妈', ''],
    '舅舅': ['外公', '外婆', '大舅', '小舅', '大姨', '小姨', '舅表哥', '舅表姐', '舅妈', ''],
    '侄子': ['哥哥', '嫂子', '侄子', '侄子', '侄女', '侄女', '侄孙子', '侄孙女', '侄媳', ''],
    '外甥': ['姐夫', '姐姐', '外甥', '外甥', '外甥女', '外甥女', '外甥孙', '外甥孙女', '外甥媳妇', ''],
  };

  static const _womanStart = <String, List<String>>{
    '我': _headers,
    '爸爸': ['爷爷', '奶奶', '伯父', '叔叔', '姑妈', '姑妈', '弟弟', '我', '妈妈', ''],
    '妈妈': ['外公', '外婆', '大舅', '小舅', '大姨', '小姨', '弟弟', '我', '', '爸爸'],
    '儿子': ['丈夫', '我', '儿子', '儿子', '女儿', '女儿', '孙子', '孙女', '儿媳', ''],
    '女儿': ['丈夫', '我', '儿子', '儿子', '女儿', '女儿', '外孙', '外孙女', '', '女婿'],
    '丈夫': ['公公', '婆婆', '大伯子', '小叔子', '大姑子', '小姑子', '儿子', '女儿', '我', ''],
  };

  String calculate(List<String> calls, {required bool isWoman}) {
    if (calls.length <= 1) return '';
    if (calls.length > 8) return unknown;
    var result = calls.first;
    for (final relation in calls.skip(1)) {
      final row = (isWoman ? _womanStart[result] : null) ?? _man[result];
      final column = _headers.indexOf(relation);
      if (row == null ||
          column < 0 ||
          column >= row.length ||
          row[column].isEmpty) {
        return unknown;
      }
      result = row[column];
    }
    return result;
  }

  bool isMale(String relation) =>
      const {'丈夫', '爸爸', '哥哥', '弟弟', '儿子'}.contains(relation);

  List<String> reverse(List<String> calls, {required bool initialWoman}) {
    final result = <String>['我'];
    for (var index = calls.length - 1; index > 0; index--) {
      final previousIsMale = (calls[index - 1] == '我' && !initialWoman) ||
          isMale(calls[index - 1]);
      final relation = calls[index];
      if (relation == '儿子' || relation == '女儿') {
        result.add(previousIsMale ? '爸爸' : '妈妈');
      } else if (relation == '弟弟' || relation == '妹妹') {
        result.add(previousIsMale ? '哥哥' : '姐姐');
      } else if (relation == '哥哥' || relation == '姐姐') {
        result.add(previousIsMale ? '弟弟' : '妹妹');
      } else if (relation == '爸爸' || relation == '妈妈') {
        result.add(previousIsMale ? '儿子' : '女儿');
      } else if (relation == '妻子' || relation == '丈夫') {
        result.add(previousIsMale ? '丈夫' : '妻子');
      }
    }
    return result;
  }
}
