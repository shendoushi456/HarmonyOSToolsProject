import '../../data/models/recipes_tools_models.dart';

/// 首页（HomeToolsTwoFragment）ViewModel。
/// 数据与 Android HomeToolsTwoFragment.initView 中的硬编码列表一一对应，
/// 页面层只负责渲染，更换马甲包 UI 时无需改动这里。
class HomeToolsViewModel {
  const HomeToolsViewModel();

  static const String _assetBase = 'assets/images/recipes_tools/';

  /// 低卡食品推荐 —— 对应 diKaTuiJianBeanList（6 条）。
  List<DiKaTuiJianItem> get diKaTuiJianList => const [
        DiKaTuiJianItem(
            imagePath: '${_assetBase}jixiong_head_ic.png',
            name: '鸡胸肉沙拉',
            kaluli: '289卡路里'),
        DiKaTuiJianItem(
            imagePath: '${_assetBase}sanwenyu_ic.png',
            name: '三文鱼配西兰花',
            kaluli: '312卡路里'),
        DiKaTuiJianItem(
            imagePath: '${_assetBase}bocai_xianren_ic.png',
            name: '菠菜蘑菇欧姆蛋',
            kaluli: '250卡路里'),
        DiKaTuiJianItem(
            imagePath: '${_assetBase}fanqie_xiaren_ic.png',
            name: '番茄虾仁魔芋面',
            kaluli: '250卡路里'),
        DiKaTuiJianItem(
            imagePath: '${_assetBase}hanshi_labaicai_ic.png',
            name: '韩式辣白菜豆腐汤',
            kaluli: '200卡路里'),
        DiKaTuiJianItem(
            imagePath: '${_assetBase}kongqi_zhaguo_ic.png',
            name: '空气炸锅椒盐花菜',
            kaluli: '80卡路里'),
      ];

  /// 菜谱分类 —— 对应 getCaiPinFenLeiBeans（5 条）。
  /// id 为安卓传给 RecipesListActivity 的 "p" 参数，原样保留（含历史错位）。
  List<CaiPinFenLeiItem> get caiPinFenLeiList => const [
        CaiPinFenLeiItem(
            imagePath: '${_assetBase}zhucai_ic.png', name: '主菜', id: '1'),
        CaiPinFenLeiItem(
            imagePath: '${_assetBase}zaocan_ic.png', name: '早餐', id: '4'),
        CaiPinFenLeiItem(
            imagePath: '${_assetBase}shala_ic.png', name: '沙拉', id: '3'),
        CaiPinFenLeiItem(
            imagePath: '${_assetBase}tianpin_ic.png', name: '甜品', id: '2'),
        CaiPinFenLeiItem(
            imagePath: '${_assetBase}lingshi_ic.png', name: '零食', id: '5'),
      ];
}
