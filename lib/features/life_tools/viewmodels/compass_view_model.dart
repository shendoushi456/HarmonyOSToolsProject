// 指南针 ViewModel - 对齐 Android CompassActivity.java:60-95
// 原版用已废弃的 Sensor.TYPE_ORIENTATION(event.values[0] 直接是方位角)
// Flutter sensors_plus 无 TYPE_ORIENTATION,改用 magnetometer + accelerometer 自算:
//   低通滤波 → getRotationMatrix → getOrientation → azimuth
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'compass_state.dart';

class CompassViewModel extends Notifier<CompassState> {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<MagnetometerEvent>? _magSub;

  // 低通滤波状态(对齐 Android SensorManager 默认 α=0.8)
  static const double _alpha = 0.8;
  List<double> _gravity = [0, 0, 0];
  List<double> _geomagnetic = [0, 0, 0];

  @override
  CompassState build() {
    _subscribeSensors();
    ref.onDispose(() {
      _accelSub?.cancel();
      _magSub?.cancel();
      _accelSub = null;
      _magSub = null;
    });
    return const CompassState(isLoading: true);
  }

  void _subscribeSensors() {
    // 加速度计 - 对齐 CompassActivity.java:95 registerListener(TYPE_ACCELEROMETER)
    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((event) {
      _gravity = [
        _alpha * _gravity[0] + (1 - _alpha) * event.x,
        _alpha * _gravity[1] + (1 - _alpha) * event.y,
        _alpha * _gravity[2] + (1 - _alpha) * event.z,
      ];
      _updateAzimuth();
    });

    // 磁力计 - 对齐 CompassActivity.java:95 registerListener(TYPE_MAGNETIC_FIELD)
    _magSub = magnetometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((event) {
      _geomagnetic = [
        _alpha * _geomagnetic[0] + (1 - _alpha) * event.x,
        _alpha * _geomagnetic[1] + (1 - _alpha) * event.y,
        _alpha * _geomagnetic[2] + (1 - _alpha) * event.z,
      ];
      _updateAzimuth();
    });
  }

  /// 计算方位角 - 对齐 Android SensorManager.getRotationMatrix + getOrientation
  void _updateAzimuth() {
    final r = _getRotationMatrix(_gravity, _geomagnetic);
    if (r == null) return;
    final orientation = _getOrientation(r);
    // azimuth 弧度(-π~π)转度 + 360 取模得 0-360
    var azimuth = orientation[0] * 180 / math.pi;
    azimuth = (azimuth + 360) % 360;
    state = state.copyWith(
      azimuth: azimuth,
      directionText: _directionText(azimuth),
      isLoading: false,
    );
  }

  /// getRotationMatrix - 严格对齐 AOSP SensorManager.getRotationMatrix
  /// 输入 gravity[3] + geomagnetic[3], 输出 R[9] 或 null(数据异常时)
  List<double>? _getRotationMatrix(
    List<double> gravity,
    List<double> geomagnetic,
  ) {
    final ax = gravity[0], ay = gravity[1], az = gravity[2];
    final ex = geomagnetic[0], ey = geomagnetic[1], ez = geomagnetic[2];

    // H = E × A
    var hx = ey * az - ez * ay;
    var hy = ez * ax - ex * az;
    var hz = ex * ay - ey * ax;
    final normH = math.sqrt(hx * hx + hy * hy + hz * hz);
    if (normH < 0.1) return null; // 数据不可靠
    hx /= normH;
    hy /= normH;
    hz /= normH;

    // M = A × H
    final mx = ay * hz - az * hy;
    final my = az * hx - ax * hz;
    final mz = ax * hy - ay * hx;
    final normM = math.sqrt(mx * mx + my * my + mz * mz);
    if (normM < 0.1) return null;

    // R[9]
    return [hx, hy, hz, mx / normM, my / normM, mz / normM, ax, ay, az];
  }

  /// getOrientation - 严格对齐 AOSP SensorManager.getOrientation
  /// 输入 R[9], 输出 values[3] = [azimuth, pitch, roll] 弧度
  List<double> _getOrientation(List<double> r) {
    // values[0] = atan2(R[1], R[4]) azimuth
    // values[1] = asin(-R[7]) pitch
    // values[2] = atan2(-R[6], R[8]) roll
    return [
      math.atan2(r[1], r[4]),
      math.asin(-r[7].clamp(-1.0, 1.0)),
      math.atan2(-r[6], r[8]),
    ];
  }

  /// 方位文字 - 对齐 ChaosCompassView.java:513-529
  /// (注:原版 195-345 区间有标注错误,此处保持与原版一致)
  String _directionText(double val) {
    if (val <= 15 || val >= 345) return '北';
    if (val <= 75) return '东北';
    if (val <= 105) return '东';
    if (val <= 165) return '东南';
    if (val <= 195) return '南';
    if (val <= 255) return '东南';
    if (val <= 285) return '东';
    return '东北';
  }
}

/// 指南针 ViewModel Provider
final compassViewModelProvider =
    NotifierProvider<CompassViewModel, CompassState>(CompassViewModel.new);
