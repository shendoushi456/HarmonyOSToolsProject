import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../favorite/repositories/favorite_repository.dart';
import '../../menu_fragment/models/tool_definition.dart';

/// LifeFragment.kt 的工具目录(对齐 ic_collection_1~19 顺序)。
///
/// 按需求排除 4 个不迁移项:
/// - 特效图(ic_collection_12/PictureLowPolyActivity)
/// - 隐藏图(ic_collection_13/PictureHideActivity)
/// - 马赛克(ic_collection_16/ToolsPictureBlurActivity)
/// - 望远镜(ic_collection_20/SpyglassToolsActivity)
final lifeFavoriteToolDefinitionsProvider = Provider<List<ToolDefinition>>((ref) {
  return const [
    ToolDefinition(
      id: ToolId.qrRecognition,
      title: '二维码扫描',
      iconAsset: AppAssets.lifeFavoriteQrScan,
      destination: ToolDestination.qrScan,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.qrGenerate,
      title: '生成二维码',
      iconAsset: AppAssets.lifeFavoriteQrGenerate,
      destination: ToolDestination.qrGenerate,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.textRecognition,
      title: '文字识别',
      iconAsset: AppAssets.lifeFavoriteTextRecognition,
      destination: ToolDestination.recognitionText,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.plantRecognition,
      title: '花草识别',
      iconAsset: AppAssets.lifeFavoritePlantRecognition,
      destination: ToolDestination.recognitionPlant,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.ingredientRecognition,
      title: '果蔬识别',
      iconAsset: AppAssets.lifeFavoriteIngredientRecognition,
      destination: ToolDestination.recognitionIngredient,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.animalRecognition,
      title: '动物识别',
      iconAsset: AppAssets.lifeFavoriteAnimalRecognition,
      destination: ToolDestination.recognitionAnimal,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.imageToPdf,
      title: '图片转PDF',
      iconAsset: AppAssets.lifeFavoriteImageToPdf,
      destination: ToolDestination.imageToPdf,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.pdfToImage,
      title: 'PDF转图片',
      iconAsset: AppAssets.lifeFavoritePdfToImage,
      destination: ToolDestination.pdfToImage,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.pdfEncrypt,
      title: '加密PDF',
      iconAsset: AppAssets.lifeFavoritePdfEncrypt,
      destination: ToolDestination.pdfEncrypt,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.pdfCompress,
      title: '压缩PDF',
      iconAsset: AppAssets.lifeFavoritePdfCompress,
      destination: ToolDestination.pdfCompress,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.pixelImage,
      title: '像素图',
      iconAsset: AppAssets.lifeFavoritePixelImage,
      destination: ToolDestination.pixelImage,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.imageColourize,
      title: '黑白上色',
      iconAsset: AppAssets.lifeFavoriteColourize,
      destination: ToolDestination.imageColourize,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.eatToday,
      title: '今天吃什么',
      iconAsset: AppAssets.lifeFavoriteEat,
      destination: ToolDestination.eatToday,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.relativesCalculator,
      title: '亲戚关系计算器',
      iconAsset: AppAssets.lifeFavoriteRelatives,
      destination: ToolDestination.relativesCalculator,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.currencyConverter,
      title: '汇率换算',
      iconAsset: AppAssets.lifeFavoriteCurrency,
      destination: ToolDestination.currencyConverter,
      placement: MenuToolPlacement.lifeFavorite,
    ),
    ToolDefinition(
      id: ToolId.magnifier,
      title: '放大镜',
      iconAsset: AppAssets.lifeFavoriteMagnifier,
      destination: ToolDestination.magnifier,
      placement: MenuToolPlacement.lifeFavorite,
    ),
  ];
});

/// LifeFragment 收藏页状态 - 对齐 LifeFragment.kt:146-266 的
/// isEditMode/selectedItems/favoriteTools 三个 Compose 状态。
class LifeFavoriteState {
  const LifeFavoriteState({
    this.isEditMode = false,
    this.favoriteIds = const <ToolId>{},
    this.selectedIds = const <ToolId>{},
    this.isLoading = true,
  });

  /// 是否处于编辑收藏模式
  final bool isEditMode;

  /// 已保存的收藏(对齐 favoriteTools + SP "favorite_tools")
  final Set<ToolId> favoriteIds;

  /// 编辑模式下的临时勾选(对齐 selectedItems)
  final Set<ToolId> selectedIds;

  final bool isLoading;

  /// 非编辑模式的展示列表:编辑模式显示全部;收藏为空显示全部;否则只显示收藏
  List<ToolDefinition> displayTools(List<ToolDefinition> catalog) {
    if (isEditMode || favoriteIds.isEmpty) {
      return catalog;
    }
    return catalog
        .where((tool) => favoriteIds.contains(tool.id))
        .toList(growable: false);
  }
}

/// LifeFragment 收藏页 ViewModel - 复用 FavoriteRepository 做持久化。
class LifeFavoriteViewModel extends Notifier<LifeFavoriteState> {
  final _repository = FavoriteRepository();

  @override
  LifeFavoriteState build() {
    Future.microtask(_load);
    return const LifeFavoriteState();
  }

  Future<void> _load() async {
    final ids = await _repository.load();
    state = LifeFavoriteState(favoriteIds: ids, isLoading: false);
  }

  /// 进入编辑模式,勾选初始化为当前收藏 - 对齐 LaunchedEffect(isEditMode)
  void enterEditMode() {
    state = LifeFavoriteState(
      isEditMode: true,
      favoriteIds: state.favoriteIds,
      selectedIds: state.favoriteIds,
      isLoading: false,
    );
  }

  /// 编辑模式下切换勾选 - 对齐 onItemSelect
  void toggleSelect(ToolId id) {
    final selected = {...state.selectedIds};
    if (!selected.add(id)) {
      selected.remove(id);
    }
    state = LifeFavoriteState(
      isEditMode: true,
      favoriteIds: state.favoriteIds,
      selectedIds: selected,
      isLoading: false,
    );
  }

  /// 保存勾选并退出编辑 - 对齐悬浮按钮 clickable 保存分支
  /// (注意:安卓此路径无 Toast,TopAppBar 的 onSave 是未被触发的死代码)
  Future<void> saveAndExit() async {
    state = LifeFavoriteState(
      isEditMode: false,
      favoriteIds: state.selectedIds,
      selectedIds: state.selectedIds,
      isLoading: false,
    );
    await _repository.save(state.selectedIds);
  }
}

final lifeFavoriteViewModelProvider =
    NotifierProvider<LifeFavoriteViewModel, LifeFavoriteState>(
  LifeFavoriteViewModel.new,
);
