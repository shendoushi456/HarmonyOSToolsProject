import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../router/route_names.dart';
import '../../life_tools/pages/tally/tally_page.dart';
import '../../life_tools/pages/checklist/checklist_page.dart';
import '../../life_tools/pages/notebook/notebook_list_page.dart';
import '../../life_tools/pages/webview/web_tool_page.dart';
import '../../image_process/models/image_process_type.dart';
import '../../image_process/pages/image_process_page.dart';
import '../../menu_home/pages/qr_generate_page.dart';
import '../../menu_home/pages/qr_scan_page.dart';
import '../../menu_home/pages/pdf_to_image_page.dart';
import '../../menu_home/pages/image_to_pdf_page.dart';
import '../../menu_home/pages/pdf_encrypt_page.dart';
import '../../menu_home/pages/pdf_compress_page.dart';
import '../../portable_tools/pages/magnifier_camera_page.dart';
import '../../portable_tools/pages/spyglass_camera_page.dart';
import '../../portable_tools/pages/pixel_image_page.dart';
import '../../portable_tools/pages/watermark_image_page.dart';
import '../../recognition/models/recognition_type.dart';
import '../../other_scan_tools/pages/base_conversion_page.dart';
import '../../other_scan_tools/pages/currency_converter_page.dart';
import '../../other_scan_tools/pages/hidden_image_page.dart';
import '../../other_scan_tools/pages/low_poly_page.dart';
import '../../other_scan_tools/pages/relatives_calculator_page.dart';
import '../models/tool_definition.dart';

/// The only place that converts a catalogue destination into a Flutter route.
/// It lets catalogue consumers (homepage, favourites and a future skin) share
/// exactly the same functional behaviour.
class ToolNavigationService {
  ToolNavigationService._();

  static Future<void> open(BuildContext context, ToolDefinition tool) {
    switch (tool.destination) {
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
      case ToolDestination.spyglass:
        return SpyglassCameraPage.push(context);
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
      // 对齐 EatActivity(KEY=https://ol.woobx.cn/tool/json-editor)
      case ToolDestination.jsonEditor:
        return WebToolPage.push(
          context,
          title: 'json编辑器',
          url: 'https://ol.woobx.cn/tool/json-editor',
        );
      // PDF 四功能(master_mianfeisaosaowang 分支实现，PDF转图片保存到相册)。
      case ToolDestination.pdfToImage:
        return PdfToImagePage.push(context);
      case ToolDestination.imageToPdf:
        return ImageToPdfPage.push(context);
      case ToolDestination.pdfEncrypt:
        return PdfEncryptPage.push(context);
      case ToolDestination.pdfCompress:
        return PdfCompressPage.push(context);
      // 特效图(对齐安卓 PictureLowPolyActivity，功能取
      // master_dasushangwangtong_huawei 分支 LowPolyPage)。
      case ToolDestination.lowPoly:
        return Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LowPolyPage()),
        );
      // 隐藏图(对齐安卓 PictureHideActivity，合成见 hidden_image_service)。
      case ToolDestination.hiddenImage:
        return HiddenImagePage.push(context);
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
}
