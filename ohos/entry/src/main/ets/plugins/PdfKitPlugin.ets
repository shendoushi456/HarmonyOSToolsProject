import { FlutterPlugin, FlutterPluginBinding, MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import common from '@ohos.app.ability.common';
import { pdfService } from '@kit.PDFKit';
import { fileIo } from '@kit.CoreFileKit';

// 图片尺寸接口 - 满足 ArkTS 严格模式
interface ImageSize {
  width: number;
  height: number;
}

// PDF Kit 原生插件 - 对齐 Android pic_toolslibrary/pdf/ 4 个 PDF Activity
// 鸿蒙 pdfService 实际能力：图片转PDF / PDF转图片 / 压缩PDF / 删除加密（无设置密码API）
export default class PdfKitPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;
  private context: common.Context | null = null;

  getUniqueClassName(): string {
    return 'PdfKitPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.context = binding.getApplicationContext();
    this.channel = new MethodChannel(binding.getBinaryMessenger(), 'qingman.pdf_kit/native');
    this.channel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        this.handleMethodCall(call, result);
      },
    });
  }

  onDetachedFromEngine(_binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
    this.context = null;
  }

  private async handleMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      switch (call.method) {
        case 'convertImagesToPdf':
          result.success(await this.convertImagesToPdf(call.args));
          break;
        case 'convertPdfToImages':
          result.success(await this.convertPdfToImages(call.args));
          break;
        case 'compressPdf':
          result.success(await this.compressPdf(call.args));
          break;
        case 'encryptPdf':
          result.success(await this.encryptPdf(call.args));
          break;
        default:
          result.notImplemented();
      }
    } catch (e) {
      result.error('PDF_KIT_ERROR', (e as Error)?.message ?? String(e), null);
    }
  }

  // ====== 图片转 PDF ======
  // 对齐 ImageToPdfProcessor.kt:20-103
  private async convertImagesToPdf(args: ESObject): Promise<string> {
    const imagePaths: string[] = args['imagePaths'] ?? [];
    const outputPath: string = args['outputPath'];
    if (imagePaths.length === 0) throw new Error('图片列表为空');

    this.ensureDir(outputPath);
    const doc = new pdfService.PdfDocument();
    const A4_WIDTH = 595;
    const A4_HEIGHT = 842;

    if (!doc.createDocument(A4_WIDTH, A4_HEIGHT)) {
      doc.releaseDocument();
      throw new Error('创建 PDF 文档失败');
    }

    for (let i = 0; i < imagePaths.length; i++) {
      const imgPath = imagePaths[i];
      const size = await this.getImageSize(imgPath);
      const scale = Math.min(A4_WIDTH / size.width, A4_HEIGHT / size.height);
      const drawW = size.width * scale;
      const drawH = size.height * scale;
      const x = (A4_WIDTH - drawW) / 2;
      const y = (A4_HEIGHT - drawH) / 2;

      const page = doc.insertBlankPage(i, A4_WIDTH, A4_HEIGHT);
      page.addImageObject(imgPath, x, y, drawW, drawH);
    }

    const ok = doc.saveDocument(outputPath);
    doc.releaseDocument();
    if (!ok) throw new Error('保存 PDF 失败');
    return outputPath;
  }

  // ====== PDF 转图片 ======
  // 对齐 PdfToImageProcessor.kt:17-96
  private async convertPdfToImages(args: ESObject): Promise<string[]> {
    const pdfPath: string = args['pdfPath'];
    const outputDir: string = args['outputDir'];
    const password: string = args['password'] ?? '';

    this.ensureDir(outputDir + '/dummy');
    const doc = new pdfService.PdfDocument();
    const loadResult = doc.loadDocument(pdfPath, password);
    if (loadResult !== pdfService.ParseResult.PARSE_SUCCESS) {
      doc.releaseDocument();
      throw new Error('PDF 加载失败，可能密码错误');
    }

    const ok = doc.convertToImage(outputDir, pdfService.ImageFormat.PNG);
    if (!ok) {
      doc.releaseDocument();
      throw new Error('PDF 转图片失败');
    }

    const imagePaths = await this.listPngFiles(outputDir);
    doc.releaseDocument();
    return imagePaths;
  }

  // ====== 压缩 PDF ======
  // 对齐 PdfCompressor.kt:28-149：渲染为图片后重新创建 PDF
  private async compressPdf(args: ESObject): Promise<string> {
    const sourcePath: string = args['sourcePath'];
    const outputPath: string = args['outputPath'];
    const password: string = args['password'] ?? '';

    this.ensureDir(outputPath);
    const srcDoc = new pdfService.PdfDocument();
    const loadResult = srcDoc.loadDocument(sourcePath, password);
    if (loadResult !== pdfService.ParseResult.PARSE_SUCCESS) {
      srcDoc.releaseDocument();
      throw new Error('PDF 加载失败');
    }

    const tmpDir = this.context!.cacheDir + '/pdf_compress_' + Date.now();
    fileIo.mkdir(tmpDir, true);

    const ok = srcDoc.convertToImage(tmpDir, pdfService.ImageFormat.PNG);
    if (!ok) {
      srcDoc.releaseDocument();
      throw new Error('PDF 渲染失败');
    }
    srcDoc.releaseDocument();

    const imagePaths = await this.listPngFiles(tmpDir);
    if (imagePaths.length === 0) throw new Error('未生成压缩图片');

    const outDoc = new pdfService.PdfDocument();
    const firstSize = await this.getImageSize(imagePaths[0]);
    if (!outDoc.createDocument(firstSize.width, firstSize.height)) {
      outDoc.releaseDocument();
      throw new Error('创建输出 PDF 失败');
    }

    for (let i = 0; i < imagePaths.length; i++) {
      const imgPath = imagePaths[i];
      const size = await this.getImageSize(imgPath);
      const page = i === 0 ? outDoc.getPage(0) : outDoc.insertBlankPage(i, size.width, size.height);
      page.addImageObject(imgPath, 0, 0, size.width, size.height);
    }

    const saveOk = outDoc.saveDocument(outputPath);
    outDoc.releaseDocument();
    if (!saveOk) throw new Error('保存压缩 PDF 失败');
    return outputPath;
  }

  // ====== 加密 PDF ======
  // 鸿蒙 pdfService 只支持 removeSecurity，不支持设置密码，因此做降级提示
  private async encryptPdf(_args: ESObject): Promise<string> {
    throw new Error('鸿蒙 PDF Kit 暂不支持为 PDF 设置打开密码，请使用其他工具');
  }

  // 确保输出文件所在目录存在
  private ensureDir(filePath: string): void {
    const lastSlash = filePath.lastIndexOf('/');
    if (lastSlash <= 0) return;
    const dir = filePath.substring(0, lastSlash);
    try {
      fileIo.access(dir);
    } catch {
      fileIo.mkdir(dir, true);
    }
  }

  // 列出目录下所有 png 文件并排序
  private async listPngFiles(dir: string): Promise<string[]> {
    try {
      const files = await fileIo.listFile(dir);
      return files
        .filter((f: string) => f.toLowerCase().endsWith('.png'))
        .sort()
        .map((f: string) => dir + '/' + f);
    } catch {
      return [];
    }
  }

  // 读取图片宽高（用于 A4 居中缩放）
  // TODO: 接入鸿蒙图片解码能力获取真实宽高，目前先按 A4 竖版处理
  private async getImageSize(_path: string): Promise<ImageSize> {
    return { width: 595, height: 842 };
  }
}
