import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../router/route_names.dart';
import '../../life_tools/pages/tally/tally_page.dart';
import '../../life_tools/pages/checklist/checklist_page.dart';
import '../../life_tools/pages/notebook/notebook_list_page.dart';
import '../../life_tools/pages/webview/web_tool_page.dart';
import '../../image_process/models/image_process_type.dart';
import '../../image_process/pages/image_process_page.dart';
import '../../menu_home/pages/image_to_pdf_page.dart';
import '../../menu_home/pages/pdf_compress_page.dart';
import '../../menu_home/pages/pdf_encrypt_page.dart';
import '../../menu_home/pages/pdf_to_image_page.dart';
import '../../menu_home/pages/qr_generate_page.dart';
import '../../menu_home/pages/qr_scan_page.dart';
import '../../portable_tools/pages/magnifier_camera_page.dart';
import '../../portable_tools/pages/pixel_image_page.dart';
import '../../portable_tools/pages/watermark_image_page.dart';
import '../../recognition/models/recognition_type.dart';
import '../../other_scan_tools/pages/base_conversion_page.dart';
import '../../other_scan_tools/pages/currency_converter_page.dart';
import '../../other_scan_tools/pages/relatives_calculator_page.dart';
import '../../scan_menu/pages/document_camera_page.dart';
import '../../scan_menu/pages/document_capture_preview_page.dart';
import '../models/tool_definition.dart';

/// The only place that converts a catalogue destination into a Flutter route.
/// It lets catalogue consumers (homepage, favourites and a future skin) share
/// exactly the same functional behaviour.
class ToolNavigationService {
  ToolNavigationService._();

  static Future<void> open(BuildContext context, ToolDefinition tool) {
    return openDestination(context, tool.destination);
  }

  /// 按 destination 直接导航 - 供非 ToolDefinition 目录(如 Compose 版首页)复用
  static Future<void> openDestination(
    BuildContext context,
    ToolDestination destination,
  ) {
    switch (destination) {
      case ToolDestination.qrGenerate:
        return QrGeneratePage.push(context);
      case ToolDestination.recognitionText:
        return _recognition(context, RecognitionType.text);
      case ToolDestination.qrScan:
        return QrScanPage.push(context);
      case ToolDestination.recognitionPlant:
        return _recognition(context, RecognitionType.plant);
      case ToolDestination.recognitionIngredient:
        return _recognition(context, RecognitionType.ingredient);
      case ToolDestination.recognitionAnimal:
        return _recognition(context, RecognitionType.animal);
      case ToolDestination.watermark:
        return WatermarkImagePage.push(context);
      case ToolDestination.pixelImage:
        return PixelImagePage.push(context);
      case ToolDestination.magnifier:
        return MagnifierCameraPage.push(context);
      case ToolDestination.tally:
        return TallyPage.push(context);
      case ToolDestination.imageStyleTransfer:
        return _imageProcess(context, ImageProcessType.styleTransfer);
      case ToolDestination.selfieAnime:
        return _imageProcess(context, ImageProcessType.selfieAnime);
      case ToolDestination.imageColourize:
        return _imageProcess(context, ImageProcessType.colourize);
      case ToolDestination.relativesCalculator:
        return RelativesCalculatorPage.push(context);
      case ToolDestination.currencyConverter:
        return OtherCurrencyConverterPage.push(context);
      case ToolDestination.dateCalculator:
        return WebToolPage.push(
          context,
          title: '日期计算器',
          url: 'https://ol.woobx.cn/tool/date-calculator',
        );
      case ToolDestination.baseConverter:
        return BaseConversionPage.push(context);
      case ToolDestination.eatToday:
        // return PdfToImagePage.push(context);
        return WebToolPage.push(
          context,
          title: '今天吃什么',
          url: 'assets/game/jintianchishenme/index.html',
        );
      case ToolDestination.notebook:
        return NotebookListPage.push(context);
      case ToolDestination.travelChecklist:
        return ChecklistPage.push(context);
      case ToolDestination.randomNumber:
        return WebToolPage.push(
          context,
          title: '随机数生成',
          url: 'https://ol.woobx.cn/tool/random-number',
        );
      case ToolDestination.imageToPdf:
        return ImageToPdfPage.push(context);
      case ToolDestination.pdfToImage:
        return PdfToImagePage.push(context);
      case ToolDestination.pdfEncrypt:
        return PdfEncryptPage.push(context);
      case ToolDestination.pdfCompress:
        return PdfCompressPage.push(context);
      case ToolDestination.photoArchive:
        // 拍照存档链路 - 对齐 Android CameraWenDangActivity:
        // 拍照 → 预览/保存/裁剪(scan_menu 模块)
        return _photoArchive(context);
    }
  }

  static Future<void> _recognition(
    BuildContext context,
    RecognitionType type,
  ) async {
    context.push(RoutePaths.recognition, extra: type);
  }

  static Future<void> _imageProcess(
    BuildContext context,
    ImageProcessType type,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ImageProcessPage(type: type)),
    );
  }

  /// 拍照存档:DocumentCameraPage 拍照后进入预览/保存/裁剪链路
  static Future<void> _photoArchive(BuildContext context) async {
    final file = await DocumentCameraPage.capture(context);
    if (file != null && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DocumentCapturePreviewPage(file: file)),
      );
    }
  }
}
