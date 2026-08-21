// 搜索组件 - 对齐 Android bus/ui/SearchSection.kt
// 迁移说明：
// - Android Composable → Flutter StatelessWidget
// - Icons.Default.Search → Icons.search（Material 图标）
// - dp/sp → double（Flutter 默认逻辑像素，1dp≈1px）
// - 颜色保持原值
import 'package:flutter/material.dart';

/// 搜索组件 - 对齐 Android SearchSection
/// 用于显示搜索框和搜索按钮，默认转发到 SearchNormalSection
///
/// onSearchClick 搜索点击回调（参数对齐 Android 固定字符串"搜索路线、站点、目的地"）
class SearchSection extends StatelessWidget {
  const SearchSection({
    super.key,
    required this.onSearchClick,
  });

  /// 搜索点击回调
  final void Function(String) onSearchClick;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android SearchSection → SearchNormalSection(onSearchClick)
    return SearchNormalSection(onSearchClick: onSearchClick);
  }
}

/// 地图搜索栏组件 - 对齐 Android MapSearchSection
/// 圆角卡片样式，搜索图标 + 提示文字 + 橙色"搜索"按钮
class MapSearchSection extends StatelessWidget {
  const MapSearchSection({
    super.key,
    required this.onSearchClick,
  });

  /// 搜索点击回调
  final void Function(String) onSearchClick;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Card(横向前距 20dp, 圆角 21dp, 阴影 4dp, 白底)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: () => onSearchClick('搜索路线、站点、目的地'),
          child: SizedBox(
            height: 42,
            child: Row(
              children: [
                const SizedBox(width: 16),
                // 搜索图标 - 对齐 Android Icon(Icons.Default.Search, tint = 0xff5183F4, size 20)
                const Icon(
                  Icons.search,
                  size: 20,
                  color: Color(0xff5183F4),
                ),
                const SizedBox(width: 10),
                // 搜索提示文字 - 对齐 Android Text("搜索路线、站点、目的地", color = 0xFF131415, fontSize 12)
                const Expanded(
                  child: Text(
                    '搜索路线、站点、目的地',
                    style: TextStyle(
                      color: Color(0xFF131415),
                      fontSize: 12,
                    ),
                  ),
                ),
                // 搜索按钮 - 对齐 Android Box(背景 0xFFEB5F00, 圆角右上/右下 21)
                Container(
                  height: 42,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEB5F00),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(21),
                      bottomRight: Radius.circular(21),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '搜索',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 弧形搜索栏组件 - 对齐 Android SearchArcSection
/// 顶部状态栏内嵌的绿色背景搜索栏，含独立白色搜索按钮
class SearchArcSection extends StatelessWidget {
  const SearchArcSection({
    super.key,
    required this.onSearchClick,
  });

  /// 搜索点击回调
  final void Function(String) onSearchClick;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Column(statusBarsPadding + 横向 20dp)
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              // 搜索栏主体 - 对齐 Android Box(高 42dp, 背景 0xff23D19B, 圆角 10)
              Material(
                color: const Color(0xff23D19B),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onSearchClick('搜索路线、站点、目的地'),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        // 白色内搜索框 - 对齐 Android Row(背景白, 圆角 16, padding 4)
                        Expanded(
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            // 对齐 Android 右侧留白 80dp（给"搜索"按钮腾出位置）
                            margin: const EdgeInsets.only(right: 80),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  size: 20,
                                  color: Color(0xff131415),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    '搜索路线、站点、目的地',
                                    style: TextStyle(
                                      color: Color(0xff131415),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 独立"搜索"按钮 - 对齐 Android Box(align CenterEnd, 宽 68 高 24, 白底圆角 12, 文字 0xFF31C580)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 68,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '搜索',
                        style: TextStyle(
                          color: Color(0xFF31C580),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 普通搜索栏组件 - 对齐 Android SearchNormalSection
/// 白色圆角卡片，搜索图标 + 提示文字 + 绿色"搜索"按钮
class SearchNormalSection extends StatelessWidget {
  const SearchNormalSection({
    super.key,
    required this.onSearchClick,
  });

  /// 搜索点击回调
  final void Function(String) onSearchClick;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Card(横向前 20 后 20, 高 42, 圆角 10, 阴影 4dp, 白底)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onSearchClick('搜索路线、站点、目的地'),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Row(
              children: [
                // 搜索图标 - 对齐 Android Icon(tint = 0xff171715, size 20)
                const Icon(
                  Icons.search,
                  size: 20,
                  color: Color(0xff171715),
                ),
                const SizedBox(width: 10),
                // 提示文字 - 对齐 Android Text(color = 0xff171715, fontSize 12)
                const Text(
                  '搜索路线、站点、目的地',
                  style: TextStyle(
                    color: Color(0xff171715),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                // 搜索按钮 - 对齐 Android Box(高 24, 圆角 6, 背景 0xFF31C580, padding horizontal 19)
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  decoration: BoxDecoration(
                    color: const Color(0xFF31C580),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '搜索',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 中间型搜索栏组件 - 对齐 Android SearchNormalBetweenSection
/// 左侧白色卡片 + 右侧深色图标按钮的组合样式
class SearchNormalBetweenSection extends StatelessWidget {
  const SearchNormalBetweenSection({
    super.key,
    required this.onSearchClick,
  });

  /// 搜索点击回调
  final void Function(String) onSearchClick;

  @override
  Widget build(BuildContext context) {
    // 对齐 Android Row(横向 padding 20, clickable)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSearchClick('搜索路线、站点、目的地'),
          child: Row(
            children: [
              // 左侧白色卡片 - 对齐 Android Card(weight 1, 高 42, 圆角 10, 阴影 4dp)
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(left: 16),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    '搜索路线、站点、目的地',
                    style: TextStyle(
                      color: Color(0xFF131415),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              // 右侧深色图标按钮 - 对齐 Android Box(宽 56 高 42, 圆角 10, 背景 0xFF150E0B)
              Container(
                width: 56,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF150E0B),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
