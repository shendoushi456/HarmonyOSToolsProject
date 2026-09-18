// 应用内字体缩放全局状态 - 对齐安卓 Settings.System.FONT_SCALE 功能的
// 鸿蒙替代方案(鸿蒙不向三方应用开放修改系统字体大小的 API,故改为应用内缩放)。
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/prefs_storage.dart';

/// 字体缩放档位 - 对齐 tools_extra_lib TipsTextSizeDialog.kt 的 fontSizeScaleMap
class FontScaleOption {
  const FontScaleOption(this.label, this.scale);

  final String label;
  final double scale;
}

/// 档位列表 - 1.15/1.30/1.45/1.0(应用内缩放不用原版 OtherSaoMiaoFrgment
/// 的 2.0/2.5/3.0 大倍率,避免页面文字破版)
const List<FontScaleOption> kFontScaleOptions = [
  FontScaleOption('小号字体 (推荐值: 1.15x)', 1.15),
  FontScaleOption('中号字体 (推荐值: 1.30x)', 1.30),
  FontScaleOption('大号字体 (推荐值: 1.45x)', 1.45),
  FontScaleOption('恢复默认 (1.00x)', 1.0),
];

class FontScaleViewModel extends Notifier<double> {
  @override
  double build() => 1.0;

  /// 启动时加载已保存的档位(App initState 首帧后调用)。
  /// PrefsStorage 由启动页首帧后 init,这里兜底再 init 一次(幂等)。
  Future<void> load() async {
    try {
      await PrefsStorage.init();
      state = PrefsStorage.loadFontScale();
    } catch (_) {
      // 存储不可用时保持默认 1.0,不影响应用使用
    }
  }

  /// 设置字体缩放档位 - 对齐安卓 setTextSize() 写入 FONT_SCALE(此处改为
  /// 应用内状态 + 持久化)
  Future<void> setScale(double scale) async {
    state = scale;
    try {
      await PrefsStorage.saveFontScale(scale);
    } catch (_) {
      // 保存失败时当前会话仍生效
    }
  }
}

final fontScaleProvider =
    NotifierProvider<FontScaleViewModel, double>(FontScaleViewModel.new);
