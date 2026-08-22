// 时间工具 - 对齐 Android third-module/tallynotes/src/main/java/com/example/tallynotes/Utils/TimeUtil.java
// TimeUtil.getNowTime 格式 "yyyy年MM月dd日 HH:mm:ss"
import 'package:intl/intl.dart';

class TimeUtil {
  TimeUtil._();

  /// 当前时间字符串 - 对齐 TimeUtil.java:9 getNowTime
  static String getNowTime() {
    return DateFormat('y年MM月dd日 HH:mm:ss').format(DateTime.now());
  }
}
