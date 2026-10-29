// 系统提醒保存失败的统一提示 - 移植自提交 04d34a5b（糖压管家宝 添加系统提醒）
// 页面在数据保存成功但原生提醒失败(PlatformException)时调用；
// 授权弹窗失败不能阻止业务数据保存，真正发布时原生层会再次检查通知状态。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'reminder_scheduler.dart';

/// 保存前请求通知授权(失败不阻断保存流程)
Future<void> requestNotificationIfNeeded() async {
  try {
    if (!await ReminderNotificationSettings.isEnabled()) {
      await ReminderNotificationSettings.requestEnable();
    }
  } on PlatformException {
    // 继续保存。随后由发布 ReminderAgent 的错误提示引导用户打开系统设置。
  }
}

/// 弹出"系统提醒设置失败"对话框；返回是否用户选择前往通知设置。
Future<bool?> showReminderSaveFailure(
  BuildContext context,
  String? details, {
  String savedSubject = '待办',
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('系统提醒设置失败'),
      content: Text(
        '$savedSubject已保存，但系统提醒设置失败。${details == null || details.isEmpty ? '请检查系统通知是否开启。' : details}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('知道了'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('前往通知设置'),
        ),
      ],
    ),
  );
}

/// 处理失败弹窗并按需跳转通知设置
Future<void> handleReminderSaveFailure(
  BuildContext context,
  PlatformException error, {
  String savedSubject = '待办',
}) async {
  final openSettings = await showReminderSaveFailure(
    context,
    reminderFailureMessage(error),
    savedSubject: savedSubject,
  );
  if (openSettings == true && context.mounted) {
    try {
      await ReminderNotificationSettings.openSettings();
    } on PlatformException catch (settingsError) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(settingsError.message ?? '无法打开系统通知设置')),
      );
    }
  }
}

/// 解析原生 REMINDER_ERROR 详情为用户可读文案(对齐 _reminderFailureMessage)
String reminderFailureMessage(PlatformException error) {
  final rawDetails = error.details;
  final details = rawDetails is Map ? rawDetails : const <Object?, Object?>{};
  final rawCode = details['code'];
  final code = rawCode is int ? rawCode : int.tryParse('$rawCode');
  final stage = '${details['stage'] ?? ''}';

  switch (code) {
    case 1700001:
      return '系统通知未开启，请开启通知后重试。';
    case 1700002:
      return '系统可用提醒数量已达上限，请删除不再需要的系统提醒后重试。';
    case 201:
      return '系统拒绝访问已设置的提醒，请重新安装应用或检查提醒权限。';
    case 401:
      return '系统未接受提醒参数（${_reminderStageLabel(stage)}），请修改提醒时间后重试。';
  }

  if (stage == 'cancelExisting') {
    return '无法清理旧的系统提醒，请稍后重试。';
  }
  if (stage == 'checkNotification' || stage == 'requestNotification') {
    return '无法确认系统通知状态，请检查通知设置后重试。';
  }
  return error.message?.isNotEmpty == true
      ? error.message!
      : '请检查系统通知是否开启后重试。';
}

String _reminderStageLabel(String stage) {
  switch (stage) {
    case 'publishReminder':
      return '发布提醒';
    case 'cancelExisting':
      return '清理旧提醒';
    case 'checkNotification':
      return '检查通知状态';
    default:
      return '设置提醒';
  }
}
