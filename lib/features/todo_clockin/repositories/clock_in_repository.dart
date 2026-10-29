// 打卡(习惯)仓储 - 对齐 Android com.p.a_b.data.repository.ClockInRepository
// Room → SharedPreferences JSON；习惯提醒通知(HabitReminderService)不在迁移范围
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_clockin_entities.dart';
import '../services/reminder_scheduler.dart';
import '../utils/clockin_date_utils.dart';

class ClockInRepository {
  ClockInRepository();

  /// 系统提醒调度(保存后同步 ReminderAgent，失败向上抛 PlatformException)
  static const OhosReminderScheduler _scheduler = OhosReminderScheduler();

  static const String _keyHabits = 'todo_clockin_habits';
  static const String _keyRecords = 'todo_clockin_records';
  static const String _keyNextHabitId = 'todo_clockin_next_habit_id';
  static const String _keyNextRecordId = 'todo_clockin_next_record_id';

  /// 保存习惯 - 对齐 saveHabit
  /// endDateText == "无" 时换算为开始日期 + 100 年
  Future<int> saveHabit({
    required String name,
    required String scheduleType,
    String? clockInTimes,
    required String startDate,
    required String endDateText,
    String selectedWeekDays = '',
  }) async {
    String endDate;
    if (endDateText == '无') {
      final start = parseYMD(startDate);
      final calendar =
          (start ?? DateTime.now()).add(const Duration(days: 365 * 100));
      endDate = formatYMD(calendar);
    } else {
      endDate = endDateText;
    }

    final formattedClockInTimes = formatTimeForReminder(clockInTimes);

    final prefs = await SharedPreferences.getInstance();
    final habits = _loadHabits(prefs);
    final nextId = prefs.getInt(_keyNextHabitId) ?? 1;
    final habit = HabitEntity(
      id: nextId,
      name: name,
      scheduleType: scheduleType,
      clockInTimes: formattedClockInTimes,
      startDate: startDate,
      endDate: endDate,
      selectedWeekDays: selectedWeekDays,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    habits.add(habit);
    await prefs.setInt(_keyNextHabitId, nextId + 1);
    await prefs.setString(_keyHabits, HabitEntity.encodeList(habits));
    // 原生侧会先检查通知状态、清理同组旧提醒，再按时间点逐一发布。
    await _scheduler.scheduleHabit(habit);
    return nextId;
  }

  /// 获取所有习惯，按 id 降序(对齐 ClockInDao.getAllHabits)
  Future<List<HabitEntity>> getAllHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habits = _loadHabits(prefs)
      ..sort((a, b) => b.id.compareTo(a.id));
    return habits;
  }

  /// 打卡 - 对齐 clockIn
  Future<bool> clockIn(int habitId, String date, String? timePoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habit = await getHabitById(habitId);
      if (habit == null) return false;
      final records = _loadRecords(prefs);
      final nextId = prefs.getInt(_keyNextRecordId) ?? 1;
      if (timePoint != null && timePoint.isNotEmpty) {
        final alreadyClocked =
            await isTimePointClocked(habitId, date, timePoint);
        if (!alreadyClocked) {
          records.add(ClockInRecordEntity(
            id: nextId,
            habitId: habitId,
            date: date,
            timePoint: timePoint,
            clockInTime: currentTimeHHmm(),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ));
        }
      } else {
        records.add(ClockInRecordEntity(
          id: nextId,
          habitId: habitId,
          date: date,
          timePoint: null,
          clockInTime: currentTimeHHmm(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ));
      }
      await prefs.setInt(_keyNextRecordId, nextId + 1);
      await prefs.setString(_keyRecords, ClockInRecordEntity.encodeList(records));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<HabitEntity?> getHabitById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    for (final habit in _loadHabits(prefs)) {
      if (habit.id == id) return habit;
    }
    return null;
  }

  /// 指定日期该时间点是否已打卡 - 对齐 isTimePointClocked
  Future<bool> isTimePointClocked(
      int habitId, String date, String timePoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final record in _loadRecords(prefs)) {
        if (record.habitId == habitId &&
            record.date == date &&
            record.timePoint == timePoint) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 获取某日已打卡的时间点列表 - 对齐 getClockedTimePoints
  Future<List<String>> getClockedTimePoints(int habitId, String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final points = <String>[];
      for (final record in _loadRecords(prefs)) {
        if (record.habitId == habitId &&
            record.date == date &&
            record.timePoint != null) {
          points.add(record.timePoint!);
        }
      }
      return points;
    } catch (_) {
      return [];
    }
  }

  /// 规范化打卡时间 "HH:mm"(对齐 formatTimeForReminder)
  String? formatTimeForReminder(String? clockInTimes) {
    if (clockInTimes == null || clockInTimes.isEmpty) return null;
    return clockInTimes
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((time) {
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        return '${hour.toString().padLeft(2, '0')}:'
            '${minute.toString().padLeft(2, '0')}';
      }
      return time;
    }).join(',');
  }

  List<HabitEntity> _loadHabits(SharedPreferences prefs) {
    if (!prefs.containsKey(_keyHabits)) return [];
    return HabitEntity.decodeList(prefs.getString(_keyHabits)!);
  }

  List<ClockInRecordEntity> _loadRecords(SharedPreferences prefs) {
    if (!prefs.containsKey(_keyRecords)) return [];
    return ClockInRecordEntity.decodeList(prefs.getString(_keyRecords)!);
  }
}
