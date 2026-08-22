import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import reminderAgentManager from '@ohos.reminderAgentManager';

const CHANNEL = 'com.p.a_b/toolbox_reminder';

/**
 * 将 Flutter 的领域提醒转换为鸿蒙 ReminderAgent。
 * ReminderAgent 由系统持有，应用不在前台时也能按计划展示提醒。
 */
export default class TodoReminderPlugin implements FlutterPlugin {
  private methodChannel: MethodChannel | null = null;

  getUniqueClassName(): string {
    return 'TodoReminderPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
    this.methodChannel.setMethodCallHandler(this.methodCall);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
  }

  private methodCall: MethodCallHandler = {
    onMethodCall: (call: MethodCall, result: MethodResult): void => {
      switch (call.method) {
        case 'scheduleTodo':
          this.scheduleTodo(call)
            .then(() => result.success(null))
            .catch((error: Error) => result.error('REMINDER_ERROR', error.message, null));
          return;
        case 'cancelTodo':
          this.cancelByGroup(this.todoGroup(this.idFrom(call)))
            .then(() => result.success(null))
            .catch((error: Error) => result.error('REMINDER_ERROR', error.message, null));
          return;
        case 'scheduleHabit':
          this.scheduleHabit(call)
            .then(() => result.success(null))
            .catch((error: Error) => result.error('REMINDER_ERROR', error.message, null));
          return;
        case 'cancelHabit':
          this.cancelByGroup(this.habitGroup(this.idFrom(call)))
            .then(() => result.success(null))
            .catch((error: Error) => result.error('REMINDER_ERROR', error.message, null));
          return;
        case 'scheduleMedication':
          this.scheduleMedication(call)
            .then(() => result.success(null))
            .catch((error: Error) => result.error('REMINDER_ERROR', error.message, null));
          return;
        case 'cancelMedication':
          this.cancelByGroup(this.medicationGroup(this.idFrom(call)))
            .then(() => result.success(null))
            .catch((error: Error) => result.error('REMINDER_ERROR', error.message, null));
          return;
        case 'scheduleExpiry':
          this.scheduleExpiry(call)
            .then(() => result.success(null))
            .catch((error: Error) => result.error('REMINDER_ERROR', error.message, null));
          return;
        case 'cancelExpiry':
          this.cancelByGroup(this.expiryGroup(this.idFrom(call)))
            .then(() => result.success(null))
            .catch((error: Error) => result.error('REMINDER_ERROR', error.message, null));
          return;
        default:
          result.notImplemented();
      }
    },
  };

  private async scheduleTodo(call: MethodCall): Promise<void> {
    const id = this.idFrom(call);
    const groupId = this.todoGroup(id);
    await this.cancelByGroup(groupId);

    const reminderAt = Number(call.argument('reminderAt'));
    if (!Number.isFinite(reminderAt)) return;
    const date = new Date(reminderAt);
    const repeatType = String(call.argument('repeatType'));
    const content = String(call.argument('content'));

    if (repeatType === 'none') {
      if (reminderAt <= Date.now()) return;
      const request: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        groupId: groupId,
        title: '待办提醒',
        content: content,
        tapDismissed: true,
        ringDuration: 30,
        snoozeTimes: 1,
        timeInterval: 5,
        dateTime: this.localDateTime(date),
      };
      await reminderAgentManager.publishReminder(request);
      return;
    }

    const request: reminderAgentManager.ReminderRequestAlarm = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
      groupId: groupId,
      title: '待办提醒',
      content: content,
      tapDismissed: true,
      hour: date.getHours(),
      minute: date.getMinutes(),
      daysOfWeek: this.todoDays(repeatType),
      ringDuration: 30,
      snoozeTimes: 1,
      timeInterval: 5,
    };
    await reminderAgentManager.publishReminder(request);
  }

  private async scheduleHabit(call: MethodCall): Promise<void> {
    const id = this.idFrom(call);
    const groupId = this.habitGroup(id);
    await this.cancelByGroup(groupId);

    const startDate = Number(call.argument('startDate'));
    const endDateValue: ESObject = call.argument('endDate');
    const endDate = endDateValue == null ? null : Number(endDateValue);
    const selectedWeekdays: ESObject = call.argument('selectedWeekdays');
    const daysOfWeek = this.habitDays(
      String(call.argument('scheduleType')),
      selectedWeekdays,
    );
    const times: Array<ESObject> = call.argument('clockInTimes') as Array<ESObject>;
    const name = String(call.argument('name'));
    for (let index: number = 0; index < times.length; index++) {
      const rawTime: ESObject = times[index];
      const time = String(rawTime);
      const parts = time.split(':');
      const hour = Number(parts[0]);
      const minute = Number(parts[1]);
      if (!Number.isInteger(hour) || !Number.isInteger(minute)) continue;
      const date = this.nextReminderDate(startDate, hour, minute, daysOfWeek);
      if (endDate != null && date.getTime() > this.endOfDay(endDate)) continue;
      const request: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        groupId: groupId,
        title: '打卡提醒',
        content: `${name}，${time} 打卡`,
        tapDismissed: true,
        ringDuration: 30,
        snoozeTimes: 1,
        timeInterval: 5,
        dateTime: this.localDateTime(date),
        daysOfWeek: daysOfWeek,
      };
      if (endDate != null) {
        request.endDateTime = this.localDateTime(new Date(this.endOfDay(endDate)));
      }
      await reminderAgentManager.publishReminder(request);
    }
  }

  /**
   * 每天和每周计划使用系统重复日历提醒；间隔/循环计划则按真实日期发布
   * 接下来 30 天的单次提醒，应用启动时会重新同步，以避免在非服药日错误提醒。
   */
  private async scheduleMedication(call: MethodCall): Promise<void> {
    const id = this.idFrom(call);
    const groupId = this.medicationGroup(id);
    await this.cancelByGroup(groupId);
    if (Boolean(call.argument('isActive')) === false) return;

    const scheduleType = String(call.argument('scheduleType'));
    if (scheduleType === '按需') return;
    const startDate = Number(call.argument('startDate'));
    if (!Number.isFinite(startDate)) return;
    const endValue: ESObject = call.argument('endDate');
    const endDate: number | null = endValue == null ? null : Number(endValue);
    const rawTimes: ESObject = call.argument('times');
    const times: Array<ESObject> = rawTimes as Array<ESObject>;
    const name = String(call.argument('name'));
    const type = String(call.argument('type'));
    const rawDays: ESObject = call.argument('selectedWeekdays');
    const weekdays = this.medicationDays(rawDays);
    const intervalDays = Number(call.argument('intervalDays'));
    const useDays = Number(call.argument('useDays'));
    const pauseDays = Number(call.argument('pauseDays'));

    for (let index: number = 0; index < times.length; index++) {
      const time = String(times[index]);
      const parts = time.split(':');
      const hour = Number(parts[0]);
      const minute = Number(parts[1]);
      if (!Number.isInteger(hour) || !Number.isInteger(minute)) continue;
      if (scheduleType === '每天' || scheduleType === '每周特定日期') {
        const daysOfWeek = scheduleType === '每天' ? [1, 2, 3, 4, 5, 6, 7] : weekdays;
        if (daysOfWeek.length === 0) continue;
        const first = this.nextMedicationDate(startDate, hour, minute, scheduleType, daysOfWeek, intervalDays, useDays, pauseDays);
        if (endDate != null && first.getTime() > this.endOfDay(endDate)) continue;
        const request: reminderAgentManager.ReminderRequestCalendar = {
          reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
          groupId: groupId,
          title: '用药提醒',
          content: `${name}-${type}，${time} 用药`,
          tapDismissed: true,
          dateTime: this.localDateTime(first),
          daysOfWeek: daysOfWeek,
        };
        if (endDate != null) request.endDateTime = this.localDateTime(new Date(this.endOfDay(endDate)));
        await reminderAgentManager.publishReminder(request);
      } else {
        await this.publishMedicationDates(groupId, name, type, time, startDate, endDate, scheduleType, weekdays, intervalDays, useDays, pauseDays, hour, minute);
      }
    }
  }

  private async publishMedicationDates(
    groupId: string,
    name: string,
    type: string,
    time: string,
    startTimestamp: number,
    endTimestamp: number | null,
    scheduleType: string,
    weekdays: Array<number>,
    intervalDays: number,
    useDays: number,
    pauseDays: number,
    hour: number,
    minute: number,
  ): Promise<void> {
    const today = new Date();
    const begin = new Date(Math.max(this.startOfDay(startTimestamp), this.startOfDay(today.getTime())));
    for (let offset: number = 0; offset < 30; offset++) {
      const candidate = new Date(begin.getFullYear(), begin.getMonth(), begin.getDate() + offset, hour, minute);
      if (candidate.getTime() <= Date.now()) continue;
      if (endTimestamp != null && candidate.getTime() > this.endOfDay(endTimestamp)) break;
      if (!this.isMedicationScheduledOn(candidate, startTimestamp, scheduleType, weekdays, intervalDays, useDays, pauseDays)) continue;
      const request: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        groupId: groupId,
        title: '用药提醒',
        content: `${name}-${type}，${time} 用药`,
        tapDismissed: true,
        dateTime: this.localDateTime(candidate),
      };
      await reminderAgentManager.publishReminder(request);
    }
  }

  private async scheduleExpiry(call: MethodCall): Promise<void> {
    const id = this.idFrom(call);
    const groupId = this.expiryGroup(id);
    await this.cancelByGroup(groupId);
    const daysBefore = Number(call.argument('reminderDaysBefore'));
    const expiryTimestamp = Number(call.argument('expiryDate'));
    if (!Number.isFinite(daysBefore) || !Number.isFinite(expiryTimestamp) || daysBefore <= 0) return;
    const expiry = new Date(expiryTimestamp);
    const reminderDate = new Date(expiry.getFullYear(), expiry.getMonth(), expiry.getDate() - daysBefore, 9, 0, 0);
    if (reminderDate.getTime() <= Date.now()) return;
    const name = String(call.argument('name'));
    const option = String(call.argument('reminderOption'));
    const request: reminderAgentManager.ReminderRequestCalendar = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
      groupId: groupId,
      title: '临期提醒',
      content: `${name}${option}到期，请及时处理`,
      tapDismissed: true,
      dateTime: this.localDateTime(reminderDate),
    };
    await reminderAgentManager.publishReminder(request);
  }

  private async cancelByGroup(groupId: string): Promise<void> {
    const reminders = await reminderAgentManager.getAllValidReminders();
    for (const reminder of reminders) {
      if (reminder.reminderReq.groupId === groupId) {
        await reminderAgentManager.cancelReminder(reminder.reminderId);
      }
    }
  }

  private idFrom(call: MethodCall): number {
    const id = Number(call.argument('id'));
    if (!Number.isSafeInteger(id)) throw new Error('Invalid reminder id');
    return id;
  }

  private todoGroup(id: number): string {
    return `todo:${id}`;
  }

  private habitGroup(id: number): string {
    return `habit:${id}`;
  }

  private medicationGroup(id: number): string {
    return `medication:${id}`;
  }

  private expiryGroup(id: number): string {
    return `expiry:${id}`;
  }

  private todoDays(repeatType: string): Array<number> | undefined {
    if (repeatType === 'everyDay') return [1, 2, 3, 4, 5, 6, 7];
    if (repeatType === 'weekday') return [1, 2, 3, 4, 5];
    if (repeatType === 'weekend') return [6, 7];
    return undefined;
  }

  private habitDays(scheduleType: string, rawDays: ESObject): Array<number> | undefined {
    if (scheduleType === '每天') return [1, 2, 3, 4, 5, 6, 7];
    if (scheduleType === '周一至周五') return [1, 2, 3, 4, 5];
    if (scheduleType === '周六至周日') return [6, 7];
    if (scheduleType !== '指定星期') return undefined;
    return (rawDays as Array<ESObject>)
      .map((value: ESObject) => Number(value))
      .filter((value: number) => Number.isInteger(value) && value >= 1 && value <= 7);
  }

  private medicationDays(rawDays: ESObject): Array<number> {
    return (rawDays as Array<ESObject>)
      .map((value: ESObject) => Number(value))
      .filter((value: number) => Number.isInteger(value) && value >= 1 && value <= 7);
  }

  private nextMedicationDate(
    startTimestamp: number,
    hour: number,
    minute: number,
    scheduleType: string,
    weekdays: Array<number>,
    intervalDays: number,
    useDays: number,
    pauseDays: number,
  ): Date {
    const start = new Date(startTimestamp);
    const initial = new Date(start.getFullYear(), start.getMonth(), start.getDate(), hour, minute);
    const now = new Date();
    const candidate = initial.getTime() > now.getTime() ? initial : new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, minute);
    for (let offset: number = 0; offset < 370; offset++) {
      const date = new Date(candidate.getFullYear(), candidate.getMonth(), candidate.getDate() + offset, hour, minute);
      if (date.getTime() > now.getTime() && this.isMedicationScheduledOn(date, startTimestamp, scheduleType, weekdays, intervalDays, useDays, pauseDays)) return date;
    }
    return candidate;
  }

  private isMedicationScheduledOn(
    date: Date,
    startTimestamp: number,
    scheduleType: string,
    weekdays: Array<number>,
    intervalDays: number,
    useDays: number,
    pauseDays: number,
  ): boolean {
    const start = new Date(startTimestamp);
    const daysBetween = Math.floor((this.startOfDay(date.getTime()) - this.startOfDay(start.getTime())) / 86400000);
    if (daysBetween < 0) return false;
    if (scheduleType === '每天') return true;
    if (scheduleType === '每周特定日期') {
      const weekday = date.getDay() === 0 ? 7 : date.getDay();
      return weekdays.includes(weekday);
    }
    if (scheduleType === '每隔几天') return daysBetween === 0 || (intervalDays > 0 && daysBetween % (intervalDays + 1) === 0);
    if (scheduleType === '循环定时') {
      const cycle = useDays + pauseDays;
      const position = (daysBetween + 1) % cycle;
      return useDays > 0 && cycle > 0 && position > 0 && position <= useDays;
    }
    return false;
  }

  private nextReminderDate(
    startTimestamp: number,
    hour: number,
    minute: number,
    daysOfWeek: Array<number> | undefined,
  ): Date {
    const start = new Date(startTimestamp);
    let candidate = new Date(start.getFullYear(), start.getMonth(), start.getDate(), hour, minute);
    const now = new Date();
    if (candidate.getTime() < now.getTime()) {
      candidate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, minute);
      if (candidate.getTime() < now.getTime()) candidate.setDate(candidate.getDate() + 1);
    }
    for (let offset = 0; offset < 8; offset++) {
      const day = candidate.getDay() === 0 ? 7 : candidate.getDay();
      if (daysOfWeek == null || daysOfWeek.includes(day)) return candidate;
      candidate.setDate(candidate.getDate() + 1);
    }
    return candidate;
  }

  private localDateTime(date: Date): reminderAgentManager.LocalDateTime {
    return {
      year: date.getFullYear(),
      month: date.getMonth() + 1,
      day: date.getDate(),
      hour: date.getHours(),
      minute: date.getMinutes(),
      second: 0,
    };
  }

  private endOfDay(timestamp: number): number {
    const date = new Date(timestamp);
    date.setHours(23, 59, 59, 999);
    return date.getTime();
  }

  private startOfDay(timestamp: number): number {
    const date = new Date(timestamp);
    date.setHours(0, 0, 0, 0);
    return date.getTime();
  }
}
