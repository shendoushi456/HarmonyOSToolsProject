import 'package:flutter/material.dart';

/// 首页(view)消费的纯数据描述，与 UI 解耦；这样整体马甲包换皮时只需替换
/// `menuToolboxCSectionsProvider` 即可保留交互和跳转行为。
class MenuToolboxCSection {
  const MenuToolboxCSection._({
    required this.kind,
    this.bannerAsset,
    this.identificationCards = const <MenuIdentificationCard>[],
    this.extractionCards = const <MenuExtractionCard>[],
    this.qrCard,
    this.toolListItem,
  });

  /// 智能扫描横幅(无点击事件，仅展示图片)
  const MenuToolboxCSection.banner(String asset)
      : this._(kind: MenuToolboxCSectionKind.banner, bannerAsset: asset);

  /// 识别功能一行三卡片
  const MenuToolboxCSection.identification(List<MenuIdentificationCard> cards)
      : this._(
          kind: MenuToolboxCSectionKind.identification,
          identificationCards: cards,
        );

  /// 文字提取 + 二维码扫描
  const MenuToolboxCSection.extraction(List<MenuExtractionCard> cards)
      : this._(
          kind: MenuToolboxCSectionKind.extraction,
          extractionCards: cards,
        );

  /// 制作二维码卡片
  const MenuToolboxCSection.qrCard(MenuQrCard card)
      : this._(
          kind: MenuToolboxCSectionKind.qrCard,
          qrCard: card,
        );

  /// 工具列表项(文档扫描 / 格式转换 等)
  const MenuToolboxCSection.toolList(MenuToolListItem item)
      : this._(
          kind: MenuToolboxCSectionKind.toolList,
          toolListItem: item,
        );

  final MenuToolboxCSectionKind kind;
  final String? bannerAsset;
  final List<MenuIdentificationCard> identificationCards;
  final List<MenuExtractionCard> extractionCards;
  final MenuQrCard? qrCard;
  final MenuToolListItem? toolListItem;
}

enum MenuToolboxCSectionKind { banner, identification, extraction, qrCard, toolList }

/// 识别功能卡片 - 对应 Android IdentificationCard
class MenuIdentificationCard {
  const MenuIdentificationCard({
    required this.title,
    required this.iconAsset,
    required this.backgroundColor,
    required this.onTap,
  });

  final String title;
  final String iconAsset;
  final Color backgroundColor;

  /// 由 ViewModel 层注入 BuildContext 之后的回调；保持 model 与 UI 解耦。
  final void Function(BuildContext context) onTap;
}

/// 提取/扫描卡片 - 对应 Android ExtractionCard
class MenuExtractionCard {
  const MenuExtractionCard({
    required this.title,
    required this.backgroundAsset,
    required this.iconAsset,
    required this.onTap,
  });

  final String title;
  final String backgroundAsset;
  final String iconAsset;
  final void Function(BuildContext context) onTap;
}

/// 制作二维码卡片 - 对应 Android CreateQrCard
class MenuQrCard {
  const MenuQrCard({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String iconAsset;
  final void Function(BuildContext context) onTap;
}

/// 工具列表项 - 对应 Android ToolListItem(文档扫描/格式转换)
class MenuToolListItem {
  const MenuToolListItem({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String iconAsset;
  final void Function(BuildContext context) onTap;
}