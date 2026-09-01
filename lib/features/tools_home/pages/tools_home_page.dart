// 对齐 Android ScanToolsFragment.kt + MenuFragment.kt(合并页, 替换常用工具 tab)。
// 结构(用户指定): 顶栏"生活工具"(无设置图标) + 花费记账卡 + 四项扫描卡
//   (银行卡识别[原拍照存档改为]/文字识别/扫描二维码/二维码生成) + 汇率换算卡
//   + 花草识别/果蔬识别/动物识别 列表。
// 排除(源页未选用部分): 放大镜/字体大小黄卡、便捷工具 PDF 区、OtherTools 2×2 网格。
// 纯静态入口页(无数据交互) → 无需 ViewModel, 功能全部复用既有页面。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../router/route_names.dart';
import '../../life_tools/pages/tally/tally_page.dart';
import '../../menu_home/pages/qr_generate_page.dart';
import '../../menu_home/pages/qr_scan_page.dart';
import '../../recognition/models/recognition_type.dart';
import '../../scan_menu/pages/currency_converter_page.dart';

class ToolsHomePage extends StatelessWidget {
  const ToolsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 页面背景 - 对齐两源页 HomeScreen/ToolboxScreen background Color(0XFFFBF3F1)
      backgroundColor: const Color(0xFFFBF3F1),
      body: SafeArea(
        child: Column(
          children: [
            // TopBar - ScanToolsFragment: 90dp 高, "生活工具" 22sp Medium 黑 居中(用户确认不带设置图标)
            const SizedBox(
              height: 25,
              child: Center(
                child: Text(
                  '生活工具',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
            // 滚动主体 - ToolboxScreen Column(padding top 12, H 20, spacedBy 16)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 50),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ① 花费记账(ScanTools → AuxToolItem, 外层 padding top 22)
                      Padding(
                        padding: const EdgeInsets.only(top: 22),
                        child: _ExpenseCard(onTap: () => TallyPage.push(context)),
                      ),
                      const SizedBox(height: 16),
                      // ② 四项扫描卡(MenuFragment AuxToolsSection 内卡)
                      const _ScanItemsCard(),
                      const SizedBox(height: 16),
                      // ③ 汇率换算卡(ScanToolsFragment CurrencyExchangeScreen)
                      const _CurrencyCard(),
                      // ④ 识别区(MenuFragment RecognitionToolsSection, 自身顶部 Spacer 16)
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          children: [
                            _RecognitionItem(
                              icon: AppAssets.toolsHomePlant,
                              title: '花草识别',
                              onTap: () => context.push(RoutePaths.recognition,
                                  extra: RecognitionType.plant),
                            ),
                            const SizedBox(height: 12),
                            _RecognitionItem(
                              icon: AppAssets.toolsHomeVegetable,
                              title: '果蔬识别',
                              onTap: () => context.push(RoutePaths.recognition,
                                  extra: RecognitionType.ingredient),
                            ),
                            const SizedBox(height: 12),
                            _RecognitionItem(
                              icon: AppAssets.toolsHomeAnimal,
                              title: '动物识别',
                              onTap: () => context.push(RoutePaths.recognition,
                                  extra: RecognitionType.animal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 花费记账卡 - 对齐 ScanToolsFragment AuxToolItem(行 1250-1411)
/// Card 白 圆角10 elev2; Row(padding V12): mtoolsl_jz 40dp(start10)
///   + Column(start10): 标题 12sp Medium #131415 / 副题 10sp #848484
class _ExpenseCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ExpenseCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Image.asset(AppAssets.toolsHomeExpense,
                  width: 40, height: 40),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '花费记账',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF131415)),
                  ),
                  Text(
                    '添加账本，一目了然',
                    style:
                        TextStyle(fontSize: 10, color: Color(0xFF848484)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 四项扫描卡 - 对齐 MenuFragment AuxToolsSection 内卡(行 319-389)
/// Card 白 圆角10 elev2; Column(padding H18 V6): Row 4×weight(图标50 + 8 + 12sp #1E1E1E)
/// 注: 首项原为"拍照存档", 按用户要求改为银行卡识别。
class _ScanItemsCard extends StatelessWidget {
  const _ScanItemsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _ScanItem(
              icon: AppAssets.toolsHomeBankCard,
              label: '银行卡识别',
              // 安卓 VIEW_FROM_CAR_BANKCARD
              onTap: () => context.push(RoutePaths.recognition,
                  extra: RecognitionType.bankCard),
            ),
          ),
          Expanded(
            child: _ScanItem(
              icon: AppAssets.toolsHomeTextOcr,
              label: '文字识别',
              // 安卓 VIEW_FROM_WORD
              onTap: () => context.push(RoutePaths.recognition,
                  extra: RecognitionType.text),
            ),
          ),
          Expanded(
            child: _ScanItem(
              icon: AppAssets.toolsHomeQrScan,
              label: '扫描二维码',
              // 安卓 scanQrCode()
              onTap: () => QrScanPage.push(context),
            ),
          ),
          Expanded(
            child: _ScanItem(
              icon: AppAssets.toolsHomeQrGenerate,
              label: '二维码生成',
              // 安卓 QRCodeActivity
              onTap: () => QrGeneratePage.push(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// 四项扫描卡单项 - 对齐 MenuFragment PdfToolItem(图标 50dp + Spacer 8 + 12sp w500 #1E1E1E 居中)
class _ScanItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _ScanItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Image.asset(icon, width: 50, height: 50),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ],
      ),
    );
  }
}

/// 汇率换算卡 - 对齐 ScanToolsFragment CurrencyExchangeScreen(行 223-349)
/// Card 白 圆角10 elev2, 整卡点击 → HuiLvConversionActivity;
/// 标题"汇率换算" 18sp(start16 top16) + Padding16:
///   Row[人民币 (CNY) | 16 | 美元 (USD)] + 16 + Row[0 | 16 | 0],
///   各盒 bg #FEE7AC 圆角5 paddingV12 居中 13sp w500 #1E1E1E(静态展示)
class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => CurrencyConverterPage.push(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: _cardDecoration(),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, top: 16),
              child: Text(
                '汇率换算',
                style: TextStyle(fontSize: 18, color: Color(0xFF1E1E1E)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _CurrencyBox(text: '人民币 (CNY)')),
                      SizedBox(width: 16),
                      Expanded(child: _CurrencyBox(text: '美元 (USD)')),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _CurrencyBox(text: '0')),
                      SizedBox(width: 16),
                      Expanded(child: _CurrencyBox(text: '0')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 汇率卡内静态盒 - bg #FEE7AC 圆角5 paddingV12 居中 13sp w500 #1E1E1E
class _CurrencyBox extends StatelessWidget {
  final String text;
  const _CurrencyBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFEE7AC),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E1E1E),
        ),
      ),
    );
  }
}

/// 识别区列表项 - 对齐 MenuFragment RecognitionToolItem(行 834-909)
/// Card 白 圆角10 elev2; Row(padding H16 V13 center):
///   Box 40×40 白 圆角6 center: 图标 36dp + 10 + 标题 14sp w500 #2C2C2C
///   + weight 空隙 + "点击识别" 12sp #1E1E1E(end6) + white_jt 6×10 黑色 tint
class _RecognitionItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;
  const _RecognitionItem(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // 图标容器: 40×40 白底 圆角6
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Image.asset(icon, width: 36, height: 36),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Text(
                '点击识别',
                style: TextStyle(fontSize: 12, color: Color(0xFF1E1E1E)),
              ),
            ),
            // white_jt 6×10, 对齐 ColorFilter.tint(Color.Black)
            Image.asset(
              AppAssets.whiteArrow,
              width: 6,
              height: 10,
              color: const Color(0xFF000000),
              colorBlendMode: BlendMode.srcIn,
            ),
          ],
        ),
      ),
    );
  }
}

/// 统一卡片装饰 - Compose Card elevation 2dp 的轻阴影近似
BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: const Color(0xFFFFFFFF),
    borderRadius: BorderRadius.circular(10),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1F000000),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
  );
}
