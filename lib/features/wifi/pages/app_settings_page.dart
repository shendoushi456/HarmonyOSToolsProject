// WiFi 设置页 - 对齐 Android notificationsettings/AppSettingsActivity + activity_app_settings.xml
// 开关状态全部存 PrefsStorage,key 原名保真(StoredPreferencesValue);
// 总开关启动/停止常驻通知(鸿蒙简化版 NotifySpeedPlugin,文本通知每 5 秒更新)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/network/notify_speed_channel.dart';
import '../../../core/storage/prefs_storage.dart';
import '../../wifi_tools/viewmodels/float_speed_provider.dart';

/// 开关存储 key - 对齐 StoredPreferencesValue 常量名
class _SpKeys {
  static const isIndicatorShow = 'is_indicator_show';
  static const signal = 'signal';
  static const notificationOnLockScreen = 'notification_on_lock_screen';
  static const showDailyDataUsage = 'show_daily_data_usage';
  static const showDailyWifiUsage = 'show_daily_wifi_usage';
  // 'notification_hide_when_disconnected' key 未引用: 对应卡片在原布局 gone,不渲染
  static const totalVis = 'total_vis';
  static const downVis = 'down_vis';
  static const upVis = 'up_vis';
}

class AppSettingsPage extends ConsumerStatefulWidget {
  const AppSettingsPage({super.key});

  @override
  ConsumerState<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends ConsumerState<AppSettingsPage> {
  final NotifySpeedChannel _notifyChannel = NotifySpeedChannel.instance;

  bool _indicatorShow = false;
  bool _signal = false;
  bool _lockScreenNotify = false;
  bool _dailyDataUsage = false;
  bool _dailyWifiUsage = false;
  bool _totalVis = false;
  bool _downVis = false;
  bool _upVis = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _indicatorShow = PrefsStorage.getBool(_SpKeys.isIndicatorShow);
      _signal = PrefsStorage.getBool(_SpKeys.signal);
      _lockScreenNotify =
          PrefsStorage.getBool(_SpKeys.notificationOnLockScreen);
      _dailyDataUsage =
          PrefsStorage.getBool(_SpKeys.showDailyDataUsage);
      _dailyWifiUsage =
          PrefsStorage.getBool(_SpKeys.showDailyWifiUsage);
      _totalVis = PrefsStorage.getBool(_SpKeys.totalVis);
      _downVis = PrefsStorage.getBool(_SpKeys.downVis);
      _upVis = PrefsStorage.getBool(_SpKeys.upVis);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF263443), // 对齐 theme_color_1 深蓝底
      body: Column(
        children: [
          // ===== 标题栏: back + "设置" =====
          SizedBox(
            width: double.infinity,
            height: 50 + MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text('设置',
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                      Positioned(
                        left: 0,
                        child: IconButton(
                          icon: Image.asset(AppAssets.wifiBoxBack,
                              width: 22, height: 22),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  // ===== 启用通知指示器卡(总开关) =====
                  _buildCard(
                    icon: AppAssets.wifiBoxNotifySettings,
                    title: '启用通知指示器',
                    subtitle: '在状态栏中显示速度指示器。',
                    value: _indicatorShow,
                    onChanged: _onIndicatorToggle,
                  ),
                  // ===== 通知设置卡 =====
                  _sectionTitle('通知设置'),
                  _buildCard(
                    icon: AppAssets.wifiBoxIcNotifySpeedCurrent,
                    title: '显示信号',
                    subtitle: '强度',
                    value: _signal,
                    onChanged: (v) =>
                        _saveAndRefresh(_SpKeys.signal, v, () => _signal = v),
                  ),
                  _buildCard(
                    icon: AppAssets.wifiBoxIcSettingsLockScreen,
                    title: '锁屏',
                    subtitle: '通知',
                    value: _lockScreenNotify,
                    onChanged: _onLockScreenToggle,
                  ),
                  _buildCard(
                    icon: AppAssets.wifiBoxIcSettingsMobileData,
                    title: '每日移动数据',
                    subtitle: 'Usage',
                    value: _dailyDataUsage,
                    onChanged: _onDailyMobileToggle,
                  ),
                  _buildCard(
                    icon: AppAssets.wifiBoxIcSettingsWifiData,
                    title: '每日 WiFi 数据',
                    subtitle: 'Usage',
                    value: _dailyWifiUsage,
                    onChanged: _onDailyWifiToggle,
                  ),
                  // ===== 浮窗设置卡(标题保真,原工程通知内容即"浮窗设置") =====
                  // 三开关联动悬浮窗浮层(经 floatWindowConfigProvider 实时生效)
                  _sectionTitle('浮窗设置'),
                  _buildCard(
                    icon: AppAssets.wifiToolsTopSpeed,
                    title: '显示总速度',
                    subtitle: '浮窗中的活动总速度',
                    value: _totalVis,
                    onChanged: _onTotalToggle,
                  ),
                  _buildCard(
                    icon: AppAssets.wifiToolsIcDownload,
                    title: '每日WiFi数据',
                    subtitle: 'Usage',
                    value: _downVis,
                    onChanged: _onDownToggle,
                  ),
                  _buildCard(
                    icon: AppAssets.wifiToolsIcUpload,
                    title: '每日移动数据',
                    subtitle: 'Usage',
                    value: _upVis,
                    onChanged: _onUpToggle,
                  ),
                  // 保真: 原布局中"断开连接时隐藏"卡位于 visibility=gone 容器内,
                  // 不可见(对应原版隐藏开关),故不渲染但保留存储逻辑
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6, left: 4),
        child: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }

  /// 单个开关行(对齐 strength_item_box 深色圆角卡: 左图标+标题/副标题,右 RMSwitch)
  Widget _buildCard({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF12171E),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 34, height: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xAAFFFFFF), fontSize: 11)),
              ],
            ),
          ),
          _buildSwitch(value, onChanged),
        ],
      ),
    );
  }

  /// RMSwitch 复刻(药丸形滑块)
  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 40,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF22C2CD) : const Color(0xFF8599A7),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }

  // ====== 总开关(对齐 ChangeServiceStatus: 启停通知服务) ======
  Future<void> _onIndicatorToggle(bool v) async {
    await _save(_SpKeys.isIndicatorShow, v);
    if (v) {
      // 开启: 先请求通知授权(对齐 Android 13+ POST_NOTIFICATIONS 流程)
      final granted = await _notifyChannel.requestNotificationPermission();
      if (granted) {
        // 每日用量/锁屏开关随启动一并下发(对齐安卓 Service 创建时读取开关)
        await _notifyChannel.startSpeedNotify(
          intervalMs: 5000,
          showDailyWifi: _dailyWifiUsage,
          showDailyMobile: _dailyDataUsage,
          showOnLockScreen: _lockScreenNotify,
        );
      } else {
        // 未授权则回落为关(对齐安卓授权失败不启动服务)
        await _save(_SpKeys.isIndicatorShow, false);
        if (mounted) setState(() => _indicatorShow = false);
        return;
      }
    } else {
      await _notifyChannel.stopSpeedNotify();
    }
    if (mounted) setState(() => _indicatorShow = v);
  }

  // ====== 锁屏通知开关(对齐安卓: 存 notification_on_lock_screen 后重建通知;
  // 开=灭屏后通知继续显示在锁屏,关=灭屏即隐藏) ======
  Future<void> _onLockScreenToggle(bool v) async {
    await _save(_SpKeys.notificationOnLockScreen, v);
    if (mounted) setState(() => _lockScreenNotify = v);
    if (_indicatorShow) {
      await _notifyChannel.updateLockScreenConfig(showOnLockScreen: v);
    }
  }

  // ====== 每日用量开关(对齐安卓: 改开关即 StartNotifyIndicatorService 刷新通知) ======
  Future<void> _onDailyWifiToggle(bool v) async {
    await _save(_SpKeys.showDailyWifiUsage, v);
    if (mounted) setState(() => _dailyWifiUsage = v);
    if (_indicatorShow) {
      await _notifyChannel.updateDailyConfig(
        showDailyWifi: _dailyWifiUsage,
        showDailyMobile: _dailyDataUsage,
      );
    }
  }

  Future<void> _onDailyMobileToggle(bool v) async {
    await _save(_SpKeys.showDailyDataUsage, v);
    if (mounted) setState(() => _dailyDataUsage = v);
    if (_indicatorShow) {
      await _notifyChannel.updateDailyConfig(
        showDailyWifi: _dailyWifiUsage,
        showDailyMobile: _dailyDataUsage,
      );
    }
  }

  // ====== 浮窗设置三开关(应用户要求允许全部关闭,不再回弹;
  // 最终值同步 floatWindowConfigProvider,悬浮窗浮层实时生效) ======
  Future<void> _onTotalToggle(bool v) async {
    await _save(_SpKeys.totalVis, v);
    if (mounted) setState(() => _totalVis = v);
    await ref
        .read(floatWindowConfigProvider.notifier)
        .setShowTotal(v);
  }

  Future<void> _onDownToggle(bool v) async {
    await _save(_SpKeys.downVis, v);
    if (mounted) setState(() => _downVis = v);
    await ref
        .read(floatWindowConfigProvider.notifier)
        .setDailyWifi(v);
  }

  Future<void> _onUpToggle(bool v) async {
    await _save(_SpKeys.upVis, v);
    if (mounted) setState(() => _upVis = v);
    await ref
        .read(floatWindowConfigProvider.notifier)
        .setDailyMobile(v);
  }

  Future<void> _save(String key, bool value) async {
    await PrefsStorage.setBool(key, value);
  }

  /// 存储并刷新 UI(修复: 之前仅存 SP 未 setState,开关视觉无变化)
  Future<void> _saveAndRefresh(
      String key, bool value, VoidCallback update) async {
    await _save(key, value);
    if (mounted) setState(update);
  }
}
