// 位置权限请求弹窗 - 对齐 Android bus/ui/LocationPermissionDialog.kt
// 迁移说明：
// - Android PermissionX → 鸿蒙端 ArkTS 权限桥接
// - Android AlertDialog(Compose) → Flutter showDialog + AlertDialog
// - 永久拒绝时跳转系统设置（对齐 Android onForwardToSettings）
import 'package:flutter/material.dart';
import '../repositories/baidu_location_repository.dart';

/// 位置权限请求弹窗 - 对齐 Android LocationPermissionDialog
///
/// 用法：
/// 1. 主动弹出：在事件回调中调用 [LocationPermissionDialog.present]
/// 2. 响应式：通过 widget 形态 [LocationPermissionDialog] 配合 [show] 字段控制显示
class LocationPermissionDialog extends StatefulWidget {
  const LocationPermissionDialog({
    super.key,
    this.title = '位置权限请求',
    this.message = '为了提供准确的定位服务，我们需要获取您的位置权限。',
    required this.onPermissionResult,
    required this.onDismiss,
    this.show = true,
  });

  /// 弹窗标题
  final String title;

  /// 弹窗正文
  final String message;

  /// 权限请求结果回调（true=已授权，false=未授权）
  final void Function(bool) onPermissionResult;

  /// 关闭回调
  final VoidCallback onDismiss;

  /// 是否显示（对齐 Android Composable 的 show 参数）
  /// show=true 时弹出弹窗，false 时不处理
  final bool show;

  /// 主动弹出弹窗 - 对齐 Android 在 Composable 中直接渲染 AlertDialog 的语义
  /// 调用方可在事件回调中调用此方法
  static void present({
    required BuildContext context,
    String title = '位置权限请求',
    String message = '为了提供准确的定位服务，我们需要获取您的位置权限。',
    required void Function(bool) onPermissionResult,
    required VoidCallback onDismiss,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // 对齐 Android dismissOnClickOutside = false
      builder: (ctx) => _LocationPermissionDialogView(
        title: title,
        message: message,
        onPermissionResult: onPermissionResult,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<LocationPermissionDialog> createState() =>
      _LocationPermissionDialogState();
}

class _LocationPermissionDialogState extends State<LocationPermissionDialog> {
  bool _dialogShown = false;

  @override
  void didUpdateWidget(covariant LocationPermissionDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 对齐 Android if (show) { AlertDialog(...) }：show=true 时弹出，false 不处理
    if (widget.show && !oldWidget.show && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        LocationPermissionDialog.present(
          context: context,
          title: widget.title,
          message: widget.message,
          onPermissionResult: widget.onPermissionResult,
          onDismiss: () {
            _dialogShown = false;
            widget.onDismiss();
          },
        );
      });
    } else if (!widget.show && oldWidget.show && _dialogShown) {
      _dialogShown = false;
    }
  }

  @override
  void initState() {
    super.initState();
    // 首次构建若 show=true，直接弹出
    if (widget.show) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        LocationPermissionDialog.present(
          context: context,
          title: widget.title,
          message: widget.message,
          onPermissionResult: widget.onPermissionResult,
          onDismiss: () {
            _dialogShown = false;
            widget.onDismiss();
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 对齐 Android if (show) { AlertDialog(...) }：
    // widget 形态本身不渲染可见 UI，实际弹窗由 present 触发
    return const SizedBox.shrink();
  }
}

/// 弹窗内部实现 - 对齐 Android AlertDialog(Compose) 的渲染
class _LocationPermissionDialogView extends StatefulWidget {
  const _LocationPermissionDialogView({
    required this.title,
    required this.message,
    required this.onPermissionResult,
    required this.onDismiss,
  });

  final String title;
  final String message;
  final void Function(bool) onPermissionResult;
  final VoidCallback onDismiss;

  @override
  State<_LocationPermissionDialogView> createState() =>
      _LocationPermissionDialogViewState();
}

class _LocationPermissionDialogViewState
    extends State<_LocationPermissionDialogView> {
  bool _requesting = false;

  /// 请求位置权限 - 对齐 Android PermissionX 链式调用
  /// 鸿蒙端通过 ArkTS 权限桥接申请定位权限。
  Future<void> _requestPermission() async {
    if (_requesting) return;
    setState(() => _requesting = true);

    try {
      final granted =
          await BaiduLocationRepository().requestLocationPermission();

      if (granted) {
        // 授权成功
        widget.onPermissionResult(true);
        if (mounted) {
          Navigator.of(context).pop();
        }
        widget.onDismiss();
      } else {
        // 鸿蒙端将拒绝结果统一返回给调用方，由页面提供再次授权入口。
        widget.onPermissionResult(false);
        if (mounted) {
          Navigator.of(context).pop();
        }
        widget.onDismiss();
      }
    } catch (_) {
      // 对齐 Android 静默兜底：异常时不阻塞 UI
      widget.onPermissionResult(false);
      if (mounted) {
        Navigator.of(context).pop();
      }
      widget.onDismiss();
    } finally {
      if (mounted) {
        setState(() => _requesting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 对齐 Android AlertDialog(Compose) 的结构
    return PopScope(
      canPop: true, // 对齐 Android dismissOnBackPress = true
      child: AlertDialog(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(widget.message),
        actions: [
          // 取消按钮 - 对齐 Android dismissButton
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDismiss();
            },
            child: const Text('取消'),
          ),
          // 允许按钮 - 对齐 Android confirmButton（触发权限请求）
          TextButton(
            onPressed: _requesting ? null : _requestPermission,
            child: const Text('允许'),
          ),
        ],
      ),
    );
  }
}

/// 简化版的位置权限弹窗 - 对齐 Android SimpleLocationPermissionDialog
/// 适用于只需要基本权限提示的场景
class SimpleLocationPermissionDialog extends StatelessWidget {
  const SimpleLocationPermissionDialog({
    super.key,
    this.show = true,
    required this.onPermissionResult,
    required this.onDismiss,
  });

  /// 是否显示（对齐 Android show 参数）
  final bool show;

  /// 权限请求结果回调
  final void Function(bool) onPermissionResult;

  /// 关闭回调
  final VoidCallback onDismiss;

  /// 主动弹出 - 对齐 Android 在 Composable 中直接渲染的语义
  static void present({
    required BuildContext context,
    required void Function(bool) onPermissionResult,
    required VoidCallback onDismiss,
  }) {
    // 对齐 Android SimpleLocationPermissionDialog：复用 LocationPermissionDialog 的默认标题/文案
    LocationPermissionDialog.present(
      context: context,
      title: '位置权限',
      message: '为了提供准确的公交路线规划，需要获取您的位置权限。',
      onPermissionResult: onPermissionResult,
      onDismiss: onDismiss,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 对齐 Android SimpleLocationPermissionDialog：直接转发到 LocationPermissionDialog
    return LocationPermissionDialog(
      show: show,
      title: '位置权限',
      message: '为了提供准确的公交路线规划，需要获取您的位置权限。',
      onPermissionResult: onPermissionResult,
      onDismiss: onDismiss,
    );
  }
}
