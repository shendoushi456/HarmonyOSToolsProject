// LowPoly 图片生成服务 - 对齐 Android pic_toolslibrary/lowpoly/ 包(hugeterry 三角剖分)
// StartPolyFun: 包围三角形(initialSize=4000)→四角+50随机点→灰度(0.3/0.59/0.11)阈值 graMax=30
// 取点 shuffle 后取前 pc 个逐步 delaunayPlace → 遍历三角形取质心色填充
// Triangulation 为标准 Bowyer-Watson 增量剖分(locate/cavity/update)
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

/// 算法参数(对齐 PolyfunKey.java)
class LowPolyKey {
  static const int graMax = 30;
  static const int initialSize = 4000;
}

class _Pnt {
  final double x;
  final double y;
  const _Pnt(this.x, this.y);

  bool equals(_Pnt o) => x == o.x && y == o.y;

  /// 对齐 Pnt.vsCircumcircle(Pnt.java:557): 4x4 行列式 + 绕向归一
  /// 返回 1=外接圆外 0=圆上 -1=圆内(与安卓逐位一致,含 clockwise 翻转)
  int vsCircumcircle(_Pnt a, _Pnt b, _Pnt c) {
    // 行: [x, y, 1, x²+y²],顶点在前、当前点在末行(对齐 extend(1, dot))
    final d = _det4(
      [a.x, a.y, 1, a.x * a.x + a.y * a.y],
      [b.x, b.y, 1, b.x * b.x + b.y * b.y],
      [c.x, c.y, 1, c.x * c.x + c.y * c.y],
      [x, y, 1, x * x + y * y],
    );
    int result = d < 0 ? -1 : (d > 0 ? 1 : 0);
    // content(simplex) < 0(顺时针) → 结果取反(对齐 Pnt.java:564-565)
    final content = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
    if (content < 0) result = -result;
    return result;
  }

  /// 4x4 行列式(拉普拉斯展开,首行)
  static double _det4(List<double> r0, List<double> r1, List<double> r2,
      List<double> r3) {
    double det3(
        double a, double b, double c,
        double d, double e, double f,
        double g, double h, double i) {
      return a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g);
    }

    return r0[0] *
            det3(r1[1], r1[2], r1[3], r2[1], r2[2], r2[3], r3[1], r3[2], r3[3]) -
        r0[1] *
            det3(r1[0], r1[2], r1[3], r2[0], r2[2], r2[3], r3[0], r3[2], r3[3]) +
        r0[2] *
            det3(r1[0], r1[1], r1[3], r2[0], r2[1], r2[3], r3[0], r3[1], r3[3]) -
        r0[3] *
            det3(r1[0], r1[1], r1[2], r2[0], r2[1], r2[2], r3[0], r3[1], r3[2]);
  }
}

class _Triangle {
  final List<_Pnt> vertices;
  bool isGood = true;
  _Triangle(this.vertices);

  bool hasVertex(_Pnt p) => vertices.any((v) => v.equals(p));
}

class _Triangulation {
  final List<_Triangle> triangles = [];
  final _Pnt _initialA;
  final _Pnt _initialB;
  final _Pnt _initialC;

  _Triangulation(this._initialA, this._initialB, this._initialC) {
    triangles.add(_Triangle([_initialA, _initialB, _initialC]));
  }

  /// 对齐 delaunayPlace: 空腔=所有外接圆包含 site 的三角形(全量扫描,
  /// 与安卓 BFS 从 locate 起点扩散等价——空腔必为连通星形域),O(n)/次足够
  void delaunayPlace(_Pnt site) {
    // 对齐安卓: site 已是剖分顶点则放弃(contains(site) return)
    for (final t in triangles) {
      if (t.hasVertex(site)) return;
    }
    // getCavity: vsCircumcircle != 1(圆内/圆上)即入空腔
    final cavity = <_Triangle>{};
    for (final t in triangles) {
      if (site.vsCircumcircle(t.vertices[0], t.vertices[1], t.vertices[2]) !=
          1) {
        cavity.add(t);
      }
    }
    if (cavity.isEmpty) return;
    // update: 移除空腔,按空腔边界边(仅被一个空腔三角形共用)补 [v1,v2,site]
    for (final t in cavity) {
      t.isGood = false;
    }
    for (final t in cavity) {
      for (int i = 0; i < 3; i++) {
        final v1 = t.vertices[i];
        final v2 = t.vertices[(i + 1) % 3];
        int shared = 0;
        for (final other in cavity) {
          if (other.hasVertex(v1) && other.hasVertex(v2)) shared++;
        }
        if (shared == 1) {
          triangles.add(_Triangle([v1, v2, site]));
        }
      }
    }
    triangles.removeWhere((t) => !t.isGood);
  }
}

class LowPolyService {
  LowPolyService._();
  static final LowPolyService instance = LowPolyService._();

  /// 生成 LowPoly 图片
  /// [pc] 精度点数(对齐 PolyfunKey.pc,seekbar 600~2400)
  /// 返回 PNG 字节;失败返回 null
  Future<Uint8List?> generate(Uint8List sourceBytes, int pc) async {
    final decoded = img.decodeImage(sourceBytes);
    if (decoded == null) return null;

    // 处理尺寸上限(安卓 DrawingCache 等效;过大控制 Dart 耗时)
    const maxSide = 600;
    img.Image work = decoded;
    if (work.width > maxSide || work.height > maxSide) {
      final scale = maxSide / math.max(work.width, work.height);
      work = img.copyResize(work,
          width: (work.width * scale).round(),
          height: (work.height * scale).round());
    }
    final width = work.width;
    final height = work.height;

    // 包围三角形(对齐 initialSize=4000)
    final dt = _Triangulation(
      _Pnt(-LowPolyKey.initialSize.toDouble(), -LowPolyKey.initialSize.toDouble()),
      _Pnt(LowPolyKey.initialSize.toDouble(), -LowPolyKey.initialSize.toDouble()),
      _Pnt(0, LowPolyKey.initialSize.toDouble()),
    );

    // 四角端点 + 50 个随机点
    dt.delaunayPlace(const _Pnt(1, 1));
    dt.delaunayPlace(_Pnt(1, (height - 1).toDouble()));
    dt.delaunayPlace(_Pnt((width - 1).toDouble(), 1));
    dt.delaunayPlace(_Pnt((width - 1).toDouble(), (height - 1).toDouble()));
    final random = math.Random(DateTime.now().millisecondsSinceEpoch);
    for (int i = 0; i < 50; i++) {
      dt.delaunayPlace(
          _Pnt(random.nextInt(width).toDouble(), random.nextInt(height).toDouble()));
    }

    // 灰度取点(0.3/0.59/0.11,阈值 graMax=30,留 R 通道 >30 的像素)
    final candidates = <_Pnt>[];
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final p = work.getPixel(x, y);
        final grey =
            (p.r.toDouble() * 0.3 + p.g.toDouble() * 0.59 + p.b.toDouble() * 0.11)
                .toInt();
        if (grey > LowPolyKey.graMax) {
          candidates.add(_Pnt(x.toDouble(), y.toDouble()));
        }
      }
    }
    candidates.shuffle(random);
    final count = math.min(candidates.length, pc);
    for (int i = 0; i < count; i++) {
      dt.delaunayPlace(candidates[i]);
    }

    // 绘制: 三个点都在图内的三角形取质心色填充(对齐 DrawTriangle.drawTriangle)
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
        ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        ui.Paint()..color = const ui.Color(0xFFFFFFFF));
    for (final triangle in dt.triangles) {
      final vs = triangle.vertices;
      int inCount = 3;
      double xd = 0, yd = 0;
      for (final pnt in vs) {
        final x = pnt.x;
        final y = pnt.y;
        xd += x;
        yd += y;
        if (x < 0 || x > width || y < 0 || y > height) inCount -= 1;
      }
      if (inCount != 3) continue;
      final cx = (xd / 3).clamp(0, width - 1).toInt();
      final cy = (yd / 3).clamp(0, height - 1).toInt();
      final p = work.getPixel(cx, cy);
      final paint = ui.Paint()
        ..color = ui.Color.fromARGB(255, p.r.toInt(), p.g.toInt(), p.b.toInt())
        ..style = ui.PaintingStyle.fill;
      final path = ui.Path()
        ..moveTo(vs[0].x, vs[0].y)
        ..lineTo(vs[1].x, vs[1].y)
        ..lineTo(vs[2].x, vs[2].y)
        ..close();
      canvas.drawPath(path, paint);
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
