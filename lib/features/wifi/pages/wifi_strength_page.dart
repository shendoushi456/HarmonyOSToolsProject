// WiFi 详情页 - 对齐 Android wifimeter/Activity/WiFiStrengthActivity + activity_wifi_strength.xml
// 黑底, 45sdp 标题栏(back+白字"WiFi 详情"), ArcSeekBar 信号环 + 12 字段信息卡
// 700ms 轮询(对齐 CountDownTimer(60000, tiempoMilisegundos=700))
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/network/wifi_native_channel.dart';
import '../models/wifi_dto.dart';
import '../utils/wifi_box_support.dart';
import 'widgets/arc_signal_ring.dart';
import 'widgets/wifi_box_dialogs.dart';

class WifiStrengthPage extends StatefulWidget {
  const WifiStrengthPage({super.key});

  @override
  State<WifiStrengthPage> createState() => _WifiStrengthPageState();
}

class _WifiStrengthPageState extends State<WifiStrengthPage> {
  final WifiNativeChannel _channel = WifiNativeChannel.instance;

  WifiConnectionDetailDTO? _detail;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 对齐 solicitarPermisos 分支: 已授权→wifi 开?连?GPS? → 启动轮询/弹窗
    Future.microtask(_startFlow);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startFlow() async {
    // 鸿蒙位置权限已在首页申请,此处仅对齐功能分支
    final wifiOn = await _channel.isWifiActive();
    if (!wifiOn) {
      if (!mounted) return;
      _showWifiOffAlert(); // 对齐 alertaActivarWifi
      _startPolling();
      return;
    }
    _startPolling();
  }

  void _startPolling() {
    // 对齐 actualizarIntensidadWifi(700): CountDownTimer 60s/700ms,到点重启(等效周期轮询)
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) => _refresh());
    _refresh();
  }

  Future<void> _refresh() async {
    final detail = await _channel.getConnectionDetail();
    if (!mounted) return;
    setState(() => _detail = detail);
  }

  /// 对齐 alertaActivarWifi: "wifi/请打开 wifi..."弹窗,确认跳系统 WiFi 面板。
  /// 注: 原版另有 alertaAbrirConfiguracionGPS(gps.json 弹窗),鸿蒙侧无 GPS 检测
  /// 通道,本次未迁移该分支
  void _showWifiOffAlert() {
    showWifiSystemDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Column(
          children: [
            // ===== 标题栏 45: back + "WiFi 详情" =====
            SizedBox(
              height: 45 + MediaQuery.of(context).padding.top,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text('WiFi 详情',
                            style: TextStyle(
                                color: Colors.white, fontSize: 15)),
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
            // ===== 信号环 + 百分比 =====
            _buildArcSection(),
            const SizedBox(height: 4),
            // 绿字"Wifi 信号强度"(对齐 green_color 12sp bold)
            const Text('Wifi 信号强度',
                style: TextStyle(
                    color: WifiBoxSupport.greenColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            // ===== 信息卡两列滚动区 =====
            Expanded(child: _buildInfoCards()),
          ],
        ),
      ),
    );
  }

  Widget _buildArcSection() {
    final detail = _detail;
    // 对齐 calculateSignalLevel(rssi,101): (rssi+100)*100/50
    final percent = detail == null || detail.rssi == 0
        ? 0
        : WifiBoxSupport.calculateSignalLevel(detail.rssi, 101);
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: ArcSignalRing(
        progress: percent.toDouble(),
        size: 150,
        centerChild: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$percent',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 30, height: 1)),
                const Text('%',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            const Text('WIFI SIGNAL',
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  /// 信息卡(对齐 ScrollView 内 6 行两列 strength_item_box + 末行 DNS 单卡)
  Widget _buildInfoCards() {
    final detail = _detail;
    final empty = detail == null;
    // 对齐 NPE 时 limpiarCampos: 全空字段
    final nombreRed = empty ? '' : detail.ssid.replaceAll('"', '');
    final rssi = empty ? '' : '${detail.rssi} dBm';
    final intensidad = empty
        ? ''
        : WifiBoxSupport.intensityText(
            WifiBoxSupport.calculateSignalLevel(detail.rssi, 5));
    final velocidad = empty ? '' : '${detail.linkSpeed} Mbps';
    final ip = empty ? '' : detail.ip;
    // 对齐 Android getConnectionInfo().getMacAddress()(本机 WLAN MAC;
    // 鸿蒙侧经 getDeviceMacAddress 获取,无授权时为空串)
    final mac = empty ? '' : detail.mac;
    final gateway = empty ? '' : detail.gateway;
    final mask = empty ? '' : WifiBoxSupport.subnetMask(detail.ipPrefixLength);
    // 对齐 BSSID 大写
    final bssid = empty ? '' : detail.bssid.toUpperCase();
    final hidden = empty ? '' : (detail.isHidden ? '是' : '否');
    final frequency = empty ? '' : '${detail.frequency} MHz';
    final canal = empty
        ? ''
        : '${WifiBoxSupport.channelOf(detail.frequency)}';
    final dns = empty
        ? ''
        : '${detail.dns1}\n${detail.dns2}';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: _infoBox('网络名称 (SSID)：', nombreRed)),
              Expanded(child: _infoBox('RSSI:', rssi)),
            ]),
            Row(children: [
              Expanded(child: _infoBox('信号强度：', intensidad)),
              Expanded(child: _infoBox('速度：', velocidad)),
            ]),
            Row(children: [
              Expanded(child: _infoBox('IP 地址：', ip)),

              Expanded(child: _infoBox('DNS：', dns)),
              // MAC 地址隐藏: 鸿蒙三方无 GET_WIFI_LOCAL_MAC 授权(安装期即拒),
              // 系统返回不了本机 MAC,留空占位;若日后拿到 ACL 授权可恢复展示
              // if (mac.isNotEmpty)
              //   Expanded(child: _infoBox('MAC 地址：', mac)),
            ]),
            Row(children: [
              Expanded(child: _infoBox('网关：', gateway)),
              Expanded(child: _infoBox('子网掩码：', mask)),
            ]),
            Row(children: [
              Expanded(child: _infoBox('BSSID：', bssid)),
              Expanded(child: _infoBox('隐藏网络：', hidden)),
            ]),
            Row(children: [
              Expanded(child: _infoBox('频率：', frequency)),
              Expanded(child: _infoBox('频道：', canal)),
            ]),
            // Row(children: [
            //   Expanded(child: _infoBox('DNS：', dns)),
            //   const Expanded(child: SizedBox()),
            // ]),
          ],
        ),
      ),
    );
  }

  /// 单个信息卡(对齐 strength_item_box: #12171E 圆角5,标题绿字 10sp bold,值白字 10sp bold)
  Widget _infoBox(String label, String value) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF12171E),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: WifiBoxSupport.greenColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
