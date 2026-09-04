import 'package:flutter/material.dart';

/// A stable description of a user-facing tool.
///
/// This is deliberately the single catalogue for MenuFragment and the future
/// favourites editor.  Pages do not own a second, independently maintained
/// list of tools.
class ToolDefinition {
  const ToolDefinition({
    required this.id,
    required this.title,
    required this.iconAsset,
    this.favoriteIconAsset,
    required this.destination,
    required this.placement,
    this.subtitle,
    this.backgroundColor,
  });

  final ToolId id;
  final String title;
  final String? subtitle;
  final String iconAsset;

  /// Android FavoriteListFragment's icon, distinct from a source-page icon.
  final String? favoriteIconAsset;
  final ToolDestination destination;
  final MenuToolPlacement placement;
  final Color? backgroundColor;
}

/// Persist this id, rather than a display string, when favourites are added.
enum ToolId {
  qrGenerate,
  textRecognition,
  qrRecognition,
  plantRecognition,
  ingredientRecognition,
  animalRecognition,
  watermark,
  mosaic,
  magnifier,
  tally,
  pixelImage,
  imageStyleTransfer,
  selfieAnime,
  imageColourize,
  relativesCalculator,
  currencyConverter,
  dateCalculator,
  baseConverter,
  eatToday,
  notebook,
  travelChecklist,
  randomNumber,
  documentScan,
}

/// UI-independent destination understood by [ToolNavigationService].
enum ToolDestination {
  qrGenerate,
  recognitionText,
  qrScan,
  recognitionPlant,
  recognitionIngredient,
  recognitionAnimal,
  watermark,
  pixelImage,
  magnifier,
  tally,
  imageStyleTransfer,
  selfieAnime,
  imageColourize,
  relativesCalculator,
  currencyConverter,
  dateCalculator,
  baseConverter,
  eatToday,
  notebook,
  travelChecklist,
  randomNumber,
  documentScan,
}

enum MenuToolPlacement {
  qrBanner,
  quickAction,
  commonTool,
  otherScanImageProcess,
  otherScanCalculator,
  otherScanOther,
}
