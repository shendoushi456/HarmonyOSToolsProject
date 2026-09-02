/// ViewpointFragment 的景点展示模型；与页面交互状态分离，方便整体替换 UI。
class ViewpointAttraction {
  const ViewpointAttraction({
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.destination,
    this.guideType,
  });

  final String name;
  final String description;
  final String imageAsset;
  final ViewpointDestination destination;
  final String? guideType;
}

enum ViewpointDestination { disneyShanghai, disneyHongKong, imageGuide, leshan }
