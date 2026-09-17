// 网速测试服务 - 对齐 Android wifimeter/Thread/ 三个线程类 + HttpUploadTest
// GetSpeedTestHostsHandler(抓 speedtest.net 配置与服务器表) + PingTest + DevilDownloadTest + HttpUploadTest
// 鸿蒙 Dart 侧无法 Process 调 ping, 用 HTTP 请求耗时模拟 instantRtt(保真展示行为)
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// 单台测速服务器信息(对齐 GetSpeedTestHostsHandler.mapValue 的 7 元组)
class SpeedTestServer {
  final String uploadUrl; // mapKey: server url= 属性
  final String lat;
  final String lon;
  final String name;
  final String country;
  final String cc;
  final String sponsor; // ls.get(5) 显示为 hostname
  final String host; // ls.get(6) ping 目标,原形如 xxx:8080

  const SpeedTestServer({
    required this.uploadUrl,
    required this.lat,
    required this.lon,
    required this.name,
    required this.country,
    required this.cc,
    required this.sponsor,
    required this.host,
  });
}

/// 服务器抓取结果(对齐 GetSpeedTestHostsHandler)
class SpeedTestHostsResult {
  final double selfLat;
  final double selfLon;
  final List<SpeedTestServer> servers;
  final bool finished;

  const SpeedTestHostsResult({
    required this.selfLat,
    required this.selfLon,
    required this.servers,
    required this.finished,
  });
}

/// Ping 测试结果(对齐 PingTest)
class PingTestResult {
  final double avgRtt;
  final double instantRtt;
  const PingTestResult({required this.avgRtt, required this.instantRtt});
}

/// 下载测试进行中回调返回值
class DownloadProgress {
  final double instantDownloadRate; // Mbps
  final bool finished;
  final double finalDownloadRate;
  const DownloadProgress({
    required this.instantDownloadRate,
    required this.finished,
    this.finalDownloadRate = 0,
  });
}

/// 上传测试进行中回调返回值
class UploadProgress {
  final double instantUploadRate; // Mbps
  final bool finished;
  final double finalUploadRate;
  const UploadProgress({
    required this.instantUploadRate,
    required this.finished,
    this.finalUploadRate = 0,
  });
}

class SpeedTestService {
  final HttpClient _client = HttpClient();

  /// 内置兜底服务器列表 - 远程服务器表拉取失败时仍可测速
  /// (取自 speedtest.net 服务器表实测数据,华南/香港区域节点)
  static const List<SpeedTestServer> _fallbackServers = [
    SpeedTestServer(
      uploadUrl: 'http://suntechspeedtest.com:8080/speedtest/upload.php',
      lat: '22.2500', lon: '114.1667', name: 'Hong Kong',
      country: 'Hong Kong', cc: 'HK', sponsor: 'STC',
      host: 'suntechspeedtest.com:8080',
    ),
    SpeedTestServer(
      uploadUrl: 'http://speedtest21.hkbn.net:8080/speedtest/upload.php',
      lat: '22.2500', lon: '114.1667', name: 'Hong Kong',
      country: 'Hong Kong', cc: 'HK', sponsor: 'HKBN',
      host: 'speedtest21.hkbn.net:8080',
    ),
    SpeedTestServer(
      uploadUrl: 'http://sunmobile.hkspeedtest.com:8080/speedtest/upload.php',
      lat: '22.2500', lon: '114.1667', name: 'Hong Kong',
      country: 'Hong Kong', cc: 'HK', sponsor: 'Sun Mobile',
      host: 'sunmobile.hkspeedtest.com:8080',
    ),
    SpeedTestServer(
      uploadUrl: 'http://speedtest.hk210.hkg.cn.ctcsci.com:8080/speedtest/upload.php',
      lat: '22.2500', lon: '114.1667', name: 'Hong Kong',
      country: 'Hong Kong', cc: 'HK', sponsor: 'CTCSCI TECH LTD',
      host: 'speedtest.hk210.hkg.cn.ctcsci.com:8080',
    ),
    SpeedTestServer(
      uploadUrl: 'http://speedtest.hkg.fdcservers.net:8080/speedtest/upload.php',
      lat: '22.2500', lon: '114.1667', name: 'Hong Kong',
      country: 'Hong Kong', cc: 'HK', sponsor: 'fdcservers.net',
      host: 'speedtest.hkg.fdcservers.net:8080',
    ),
    SpeedTestServer(
      uploadUrl: 'http://hkthspeedtest02.telstraglobal.net:8080/speedtest/upload.php',
      lat: '22.2500', lon: '114.1667', name: 'Hong Kong',
      country: 'Hong Kong', cc: 'HK', sponsor: 'Telstra International',
      host: 'hkthspeedtest02.telstraglobal.net:8080',
    ),
  ];

  /// 抓取配置(本机经纬度)+服务器列表
  /// 对齐 GetSpeedTestHostsHandler.run,并增强:
  /// 配置失败不中断、https/http 双通道重试、远程列表为空时回退内置服务器
  Future<SpeedTestHostsResult> fetchHosts() async {
    double selfLat = 0.0;
    double selfLon = 0.0;
    // 1. speedtest-config.php 取本机经纬度(对齐 lat="/lon=" 解析)
    for (final url in [
      'https://www.speedtest.net/speedtest-config.php',
      'http://www.speedtest.net/speedtest-config.php',
    ]) {
      try {
        final req = await _client.getUrl(Uri.parse(url));
        final res = await req.close();
        if (res.statusCode == 200) {
          final body = await res
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .toList();
          for (final line in body) {
            if (!line.contains('isp=')) continue;
            selfLat = double.parse(
                line.split('lat="')[1].split(' ')[0].replaceAll('"', ''));
            selfLon = double.parse(
                line.split('lon="')[1].split(' ')[0].replaceAll('"', ''));
            break;
          }
          if (selfLat != 0 || selfLon != 0) break; // 配置解析成功
        }
      } catch (_) {
        // 换下一个通道重试(不再像安卓一样中断服务器表抓取)
      }
    }

    // 2. speedtest-servers-static.php 取服务器表
    final List<SpeedTestServer> servers = [];
    for (final url in [
      'https://www.speedtest.net/speedtest-servers-static.php',
      'http://www.speedtest.net/speedtest-servers-static.php',
    ]) {
      try {
        final req = await _client.getUrl(Uri.parse(url));
        final res = await req.close();
        if (res.statusCode == 200) {
          final body = await res
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .toList();
          for (final line in body) {
            if (!line.contains('<server url')) continue;
            final uploadUrl = line.split('server url="')[1].split('"')[0];
            final lat = line.split('lat="')[1].split('"')[0];
            final lon = line.split('lon="')[1].split('"')[0];
            final name = line.split('name="')[1].split('"')[0];
            final country = line.split('country="')[1].split('"')[0];
            final cc = line.split('cc="')[1].split('"')[0];
            final sponsor = line.split('sponsor="')[1].split('"')[0];
            final host = line.split('host="')[1].split('"')[0];
            servers.add(SpeedTestServer(
              uploadUrl: uploadUrl,
              lat: lat,
              lon: lon,
              name: name,
              country: country,
              cc: cc,
              sponsor: sponsor,
              host: host,
            ));
          }
          if (servers.isNotEmpty) break;
        }
      } catch (_) {
        // 换下一个通道重试
      }
    }
    // 3. 兜底: 远程拉取为空(设备网络/DNS 异常)时使用内置服务器
    if (servers.isEmpty) {
      servers.addAll(_fallbackServers);
    }
    return SpeedTestHostsResult(
        selfLat: selfLat, selfLon: selfLon, servers: servers, finished: true);
  }

  /// 选择距离最近的服务器(对齐 mainrun 中 Location.distanceTo 择优)
  /// 返回 null 表示服务器表为空(对齐 info==null 的"出了点小差错")
  SpeedTestServer? findNearestServer(
      SpeedTestHostsResult hosts, Set<String> tempBlackList) {
    double tmp = 19349458; // 对齐安卓初始最大距离
    SpeedTestServer? nearest;
    for (final server in hosts.servers) {
      if (tempBlackList.contains(server.sponsor)) continue;
      final distance = _distanceKm(
          hosts.selfLat, hosts.selfLon,
          double.tryParse(server.lat) ?? 0, double.tryParse(server.lon) ?? 0) *
          1000; // 折算米,对齐 distanceTo
      if (tmp > distance) {
        tmp = distance;
        nearest = server;
      }
    }
    return nearest;
  }

  /// Haversine 距离(km),对齐 Android Location.distanceTo
  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a = 0.5 -
        0.5 * math.cos(dLat) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            (1 - math.cos(dLon)) /
            2;
    return r * 2 * math.asin(math.sqrt(a));
  }

  /// Ping 测试(对齐 PingTest,3 次)
  /// 安卓用 `ping -c 3`; Dart 侧用 HTTP 请求耗时替代
  /// 用 http 探测(现代 Ookla 服务器会把 http 307 到 https,握手耗时同样反映 RTT)
  Future<PingTestResult> pingTest(String serverHost, {int count = 3}) async {
    final host = serverHost.replaceAll(':8080', '');
    final instantList = <double>[];
    for (int i = 0; i < count; i++) {
      final sw = Stopwatch()..start();
      try {
        final req = await _client
            .getUrl(Uri.parse('http://$host/'))
            .timeout(const Duration(seconds: 5));
        final res = await req.close();
        await res.drain<void>();
        sw.stop();
        instantList.add(sw.elapsedMicroseconds / 1000.0);
      } catch (_) {
        sw.stop();
        instantList.add(0); // 不可达时记 0,对齐安卓 Unreachable return
      }
    }
    final valid = instantList.where((v) => v > 0).toList();
    final avg = valid.isEmpty
        ? 0.0
        : valid.reduce((a, b) => a + b) / valid.length;
    final instant = instantList.isNotEmpty ? instantList.last : 0.0;
    return PingTestResult(avgRtt: avg, instantRtt: instant);
  }

  /// 下载测试(对齐 DevilDownloadTest: 两张大图依次下载,8 秒超时)
  /// [onProgress] 以安卓 while 读流节奏(约每 10KB 回调)反馈瞬时速率
  /// 注意: 保持原始 http URL(dart:io 自动跟随 307 到 Ookla 官方 TLS 域名;
  /// 强转 https 直连旧域名会握手失败,即测速 0.00 的根因)
  Future<double> downloadTest(
    String baseUrl, {
    void Function(double instantRate)? onProgress,
  }) async {
    final fileUrls = <String>[
      '${baseUrl}random4000x4000.jpg',
      '${baseUrl}random3000x3000.jpg',
    ];
    final startTime = DateTime.now();
    int downloadedByte = 0;
    double instantRate = 0;
    for (final link in fileUrls) {
      try {
        var uri = Uri.parse(link);
        var req = await _client.getUrl(uri);
        var res = await req.close();
        // 防御: dart:io 未自动跟随的重定向手动跟随一次
        if (res.isRedirect) {
          final loc = res.headers.value(HttpHeaders.locationHeader);
          await res.drain<void>();
          if (loc == null) continue;
          uri = uri.resolve(loc);
          req = await _client.getUrl(uri);
          res = await req.close();
        }
        if (res.statusCode != HttpStatus.ok) continue;
        await for (final chunk in res) {
          downloadedByte += chunk.length;
          final e = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
          // 对齐 setInstantDownloadRate: (byte*8/1e6)/elapsed Mbps
          instantRate = _round2((downloadedByte * 8) / (1000 * 1000) / e);
          onProgress?.call(instantRate);
          if (e >= 8) break; // 对齐 timeout=8
        }
        final e = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
        if (e >= 8) break;
      } catch (_) {
        break; // 对齐安卓 catch break outer
      }
    }
    final elapsed = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
    // 对齐 finalDownloadRate
    return _round2((downloadedByte * 8) / (1000 * 1000.0) / elapsed);
  }

  /// 上传测试(对齐 HttpUploadTest: 4 线程并发 POST 150KB 块,8 秒超时)
  /// 保持原始 http URL;POST 遇 307/302 重定向时手动跟随并重发 body
  /// (dart:io 重定向不会自动重发请求体)
  Future<double> uploadTest(
    String uploadUrl, {
    void Function(double instantRate)? onProgress,
  }) async {
    var url = Uri.parse(uploadUrl);
    final buffer = Uint8List(150 * 1024);
    final startTime = DateTime.now();
    int uploadedKByte = 0;

    Future<void> worker() async {
      while (true) {
        try {
          final total =
              DateTime.now().difference(startTime).inMilliseconds / 1000.0;
          if (total >= 8) break; // 对齐 timeout=8
          final req = await _client.postUrl(url);
          req.headers.set(HttpHeaders.connectionHeader, 'Keep-Alive');
          req.add(buffer);
          final res = await req.close();
          // 307/302 重定向: 更新 url 后重发(重定向请求体不自动重发)
          if (res.isRedirect) {
            final loc = res.headers.value(HttpHeaders.locationHeader);
            await res.drain<void>();
            if (loc != null) {
              url = url.resolve(loc);
            }
            continue;
          }
          await res.drain<void>();
          // 对齐 uploadedKByte += buffer.length / 1024.0(安卓此处为整型截断累加)
          uploadedKByte += buffer.length ~/ 1024;
          final e = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
          // 对齐 getInstantUploadRate: ((KB/1000)*8)/elapsed
          onProgress?.call(_round2(((uploadedKByte / 1000.0) * 8) / e));
          if (e >= 8) break;
        } catch (_) {
          break; // 对齐安卓 catch break
        }
      }
    }

    await Future.wait([worker(), worker(), worker(), worker()]);
    final elapsed = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
    return _round2(((uploadedKByte / 1000.0) * 8) / elapsed);
  }

  double _round2(double v) => (v * 100).roundToDouble() / 100;

  void dispose() => _client.close();

  // ==================== 自研测速(不依赖 speedtest.net 链路) ====================
  // 背景: speedtest.net 协议链在鸿蒙设备端脆弱(远程拉取失败/跨协议 307 跟随
  // 不确定/第三方老旧节点测试文件下线),故改用国内稳定 CDN + 公共 echo 端点

  /// 微信官方 CDN 大文件(国内最稳,支持 Range 分段)
  static const String _cdnDownloadUrl =
      'https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe';

  /// 上传 echo 端点(国外回程,数值偏低仅供参考)
  static const String _uploadEchoUrl = 'https://httpbin.org/post';

  /// 延迟测试(自研): 对 CDN 主机 HEAD 请求取 TTFB 平均(毫秒)
  Future<PingTestResult> pingCdnTest({int count = 3}) async {
    final list = <double>[];
    for (int i = 0; i < count; i++) {
      final sw = Stopwatch()..start();
      try {
        final req = await _client
            .headUrl(Uri.parse(_cdnDownloadUrl))
            .timeout(const Duration(seconds: 5));
        final res = await req.close();
        await res.drain<void>();
        sw.stop();
        list.add(sw.elapsedMicroseconds / 1000.0);
      } catch (_) {
        sw.stop();
        list.add(0); // 不可达记 0
      }
    }
    final valid = list.where((v) => v > 0).toList();
    final avg =
        valid.isEmpty ? 0.0 : valid.reduce((a, b) => a + b) / valid.length;
    final instant = list.isNotEmpty ? list.last : 0.0;
    return PingTestResult(avgRtt: avg, instantRtt: instant);
  }

  /// 下载测速(自研): 微信 CDN Range 分段 [connections] 并发,
  /// [timeoutSec] 秒窗口内统计接收字节,返回 Mbps
  Future<double> downloadCdnTest({
    void Function(double instantRate)? onProgress,
    int timeoutSec = 8,
    int connections = 4,
  }) async {
    const chunkSize = 50 * 1024 * 1024; // 每连接 50MB 区间
    int total = 0;
    final startTime = DateTime.now();

    Future<void> worker(int idx) async {
      final start = idx * chunkSize;
      final end = start + chunkSize - 1;
      try {
        final req = await _client.getUrl(Uri.parse(_cdnDownloadUrl));
        req.headers.set(HttpHeaders.rangeHeader, 'bytes=$start-$end');
        final res = await req.close();
        if (res.statusCode != HttpStatus.partialContent &&
            res.statusCode != HttpStatus.ok) {
          return;
        }
        await for (final chunk in res) {
          total += chunk.length;
          final e =
              DateTime.now().difference(startTime).inMilliseconds / 1000.0;
          if (e <= 0) continue;
          onProgress?.call(_round2((total * 8) / 1e6 / e));
          if (e >= timeoutSec) break;
        }
      } catch (_) {
        // 单连接失败不影响其余连接
      }
    }

    await Future.wait(
        [for (int i = 0; i < connections; i++) worker(i)]);
    final elapsed =
        DateTime.now().difference(startTime).inMilliseconds / 1000.0;
    if (elapsed <= 0) return 0;
    return _round2((total * 8) / 1e6 / elapsed);
  }

  /// 上传测速(自研): [connections] 并发向 echo 端点循环 POST 512KB 块,
  /// [timeoutSec] 秒窗口内统计上传字节,返回 Mbps(国外回程,数值偏低仅供参考)
  Future<double> uploadCdnTest({
    void Function(double instantRate)? onProgress,
    int timeoutSec = 8,
    int connections = 4,
  }) async {
    final buffer = Uint8List(512 * 1024);
    int total = 0;
    final startTime = DateTime.now();

    Future<void> worker() async {
      while (true) {
        final e0 =
            DateTime.now().difference(startTime).inMilliseconds / 1000.0;
        if (e0 >= timeoutSec) break;
        try {
          final req = await _client.postUrl(Uri.parse(_uploadEchoUrl));
          req.headers
              .set(HttpHeaders.contentTypeHeader, 'application/octet-stream');
          req.add(buffer);
          final res = await req.close();
          await res.drain<void>();
          total += buffer.length;
          final e =
              DateTime.now().difference(startTime).inMilliseconds / 1000.0;
          if (e <= 0) continue;
          onProgress?.call(_round2((total * 8) / 1e6 / e));
        } catch (_) {
          break; // echo 端点失败则该 worker 退出
        }
      }
    }

    await Future.wait([for (int i = 0; i < connections; i++) worker()]);
    final elapsed =
        DateTime.now().difference(startTime).inMilliseconds / 1000.0;
    if (elapsed <= 0) return 0;
    return _round2((total * 8) / 1e6 / elapsed);
  }
}
