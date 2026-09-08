import 'package:flutter/material.dart';

/// Android vector drawable pathData → Flutter Path 的轻量解析器。
/// 支持 M/m L/l C/c H/h V/v Z/z 命令，覆盖本项目迁移的
/// home.xml / recent.xml / favorite.xml 图标。
Path parseAndroidPathData(String data) {
  final path = Path();
  final matcher =
      RegExp(r'([MmLlCcHhVvZz])|(-?\d*\.?\d+(?:e[-+]?\d+)?)');
  final tokens = <String>[];
  for (final match in matcher.allMatches(data)) {
    final cmd = match.group(1);
    final num = match.group(2);
    if (cmd != null) {
      tokens.add(cmd);
    } else if (num != null) {
      tokens.add(num);
    }
  }

  var index = 0;
  double currentX = 0;
  double currentY = 0;
  double startX = 0;
  double startY = 0;
  String command = '';

  double nextNum() => double.parse(tokens[index++]);

  void moveTo(double x, double y, {bool relative = false}) {
    if (relative) {
      currentX += x;
      currentY += y;
    } else {
      currentX = x;
      currentY = y;
    }
    startX = currentX;
    startY = currentY;
    path.moveTo(currentX, currentY);
  }

  while (index < tokens.length) {
    final token = tokens[index++];
    if (RegExp(r'[A-Za-z]').hasMatch(token)) {
      command = token;
    }
    switch (command) {
      case 'M':
        final x = nextNum();
        final y = nextNum();
        moveTo(x, y);
        command = 'L'; // 后续隐式坐标按 LineTo 处理
        break;
      case 'm':
        final x = nextNum();
        final y = nextNum();
        moveTo(x, y, relative: true);
        command = 'l';
        break;
      case 'L':
        final x = nextNum();
        final y = nextNum();
        path.lineTo(x, y);
        currentX = x;
        currentY = y;
        break;
      case 'l':
        final x = nextNum();
        final y = nextNum();
        currentX += x;
        currentY += y;
        path.lineTo(currentX, currentY);
        break;
      case 'C':
        final x1 = nextNum();
        final y1 = nextNum();
        final x2 = nextNum();
        final y2 = nextNum();
        final x = nextNum();
        final y = nextNum();
        path.cubicTo(x1, y1, x2, y2, x, y);
        currentX = x;
        currentY = y;
        break;
      case 'c':
        final x1 = nextNum();
        final y1 = nextNum();
        final x2 = nextNum();
        final y2 = nextNum();
        final x = nextNum();
        final y = nextNum();
        path.cubicTo(currentX + x1, currentY + y1, currentX + x2,
            currentY + y2, currentX + x, currentY + y);
        currentX += x;
        currentY += y;
        break;
      case 'H':
        currentX = nextNum();
        path.lineTo(currentX, currentY);
        break;
      case 'h':
        currentX += nextNum();
        path.lineTo(currentX, currentY);
        break;
      case 'V':
        currentY = nextNum();
        path.lineTo(currentX, currentY);
        break;
      case 'v':
        currentY += nextNum();
        path.lineTo(currentX, currentY);
        break;
      case 'Z':
      case 'z':
        path.lineTo(startX, startY);
        currentX = startX;
        currentY = startY;
        break;
      default:
        break;
    }
  }
  return path;
}

/// 用安卓 vector drawable 的 pathData + viewport 尺寸渲染图标。
/// 用于底部导航栏 home/recent/favorite 等矢量图标保真迁移。
class AndroidVectorIcon extends StatelessWidget {
  const AndroidVectorIcon({
    super.key,
    required this.pathData,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.color,
    this.size = 32,
  });

  final String pathData;
  final double viewportWidth;
  final double viewportHeight;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _AndroidVectorPainter(
        pathData: pathData,
        viewportWidth: viewportWidth,
        viewportHeight: viewportHeight,
        color: color,
      ),
    );
  }
}

class _AndroidVectorPainter extends CustomPainter {
  _AndroidVectorPainter({
    required this.pathData,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.color,
  });

  final String pathData;
  final double viewportWidth;
  final double viewportHeight;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / viewportWidth;
    canvas.save();
    canvas.scale(scale, scale);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..isAntiAlias = true;
    canvas.drawPath(parseAndroidPathData(pathData), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AndroidVectorPainter oldDelegate) =>
      oldDelegate.pathData != pathData ||
      oldDelegate.color != color ||
      oldDelegate.viewportWidth != viewportWidth;
}

/// toolbox_c 底部导航图标库（pathData 摘自 recipes_module drawable）。
class ToolboxVectorIcons {
  static const String home =
      'M15.199,3.287v8.626c0,1.815 -1.473,3.286 -3.286,3.286H3.286C1.473,15.199 0,13.728 0,11.913V3.287C0,1.472 1.473,0 3.286,0h8.627C13.729,0 15.199,1.472 15.199,3.287zM29.714,0h-8.627c-1.813,0 -3.286,1.472 -3.286,3.287v8.626c0,1.815 1.473,3.286 3.286,3.286h8.627c1.813,0 3.286,-1.471 3.286,-3.286V3.287C33,1.472 31.527,0 29.714,0zM11.913,17.801H3.286C1.473,17.801 0,19.271 0,21.087v8.627C0,31.527 1.473,33 3.286,33h8.627c1.813,0 3.286,-1.473 3.286,-3.286v-8.627C15.199,19.271 13.729,17.801 11.913,17.801zM29.714,17.801h-8.627c-1.813,0 -3.286,1.471 -3.286,3.286v8.627c0,1.813 1.473,3.286 3.286,3.286h8.627C31.527,33 33,31.527 33,29.714v-8.627C33,19.271 31.527,17.801 29.714,17.801z';

  static const String recent =
      'M446.906,299.769c-5.865,-76.359 -41.417,-124.21 -72.781,-166.436C345.083,94.241 320,60.483 320,10.685c0,-4 -2.24,-7.656 -5.792,-9.489c-3.563,-1.844 -7.844,-1.542 -11.083,0.812c-47.104,33.706 -86.406,90.515 -100.135,144.719c-9.531,37.737 -10.792,80.161 -10.969,108.18c-43.5,-9.291 -53.354,-74.359 -53.458,-75.068c-0.49,-3.375 -2.552,-6.312 -5.552,-7.916c-3.031,-1.583 -6.594,-1.698 -9.667,-0.177c-2.281,1.104 -55.99,28.394 -59.115,137.355C64.01,312.726 64,316.362 64,319.997c0,105.857 86.135,191.987 192,191.987c0.146,0.01 0.302,0.031 0.427,0c0.042,0 0.083,0 0.135,0C362.167,511.681 448,425.667 448,319.997C448,314.674 446.906,299.769 446.906,299.769zM256,490.652c-35.292,0 -64,-30.581 -64,-68.172c0,-1.281 -0.01,-2.573 0.083,-4.156c0.427,-15.853 3.438,-26.675 6.74,-33.873c6.188,13.291 17.25,25.509 35.219,25.509c5.896,0 10.667,-4.771 10.667,-10.666c0,-15.186 0.313,-32.706 4.094,-48.518c3.365,-14.02 11.406,-28.936 21.594,-40.893c4.531,15.52 13.365,28.081 21.99,40.341c12.344,17.54 25.104,35.675 27.344,66.6c0.135,1.833 0.271,3.677 0.271,5.656C320,460.07 291.292,490.652 256,490.652z';

  static const String favorite =
      'M343.611,22.543c-22.614,0 -44.227,5.184 -64.238,15.409c-13.622,6.959 -26.135,16.205 -36.873,27.175c-10.738,-10.97 -23.251,-20.216 -36.873,-27.175c-20.012,-10.225 -41.625,-15.409 -64.239,-15.409C63.427,22.543 0,85.97 0,163.932c0,55.219 29.163,113.866 86.678,174.314c48.022,50.471 106.816,92.543 147.681,118.95l8.141,5.261l8.141,-5.261c40.865,-26.406 99.659,-68.479 147.681,-118.95C455.837,277.798 485,219.151 485,163.932C485,85.97 421.573,22.543 343.611,22.543z';
}
