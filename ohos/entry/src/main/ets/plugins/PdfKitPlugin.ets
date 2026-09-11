import { FlutterPlugin, FlutterPluginBinding, MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import common from '@ohos.app.ability.common';
import { pdfService } from '@kit.PDFKit';
import { fileIo, picker } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { image } from '@kit.ImageKit';

// 带 code 的插件错误，Dart 侧据此区分“用户取消”等场景
class PdfKitError extends Error {
  readonly code: string;

  constructor(code: string, message: string) {
    super(message);
    this.code = code;
  }
}

// 图片尺寸接口 - 满足 ArkTS 严格模式
interface ImageSize {
  width: number;
  height: number;
}

// PDF Kit 原生插件 - 对齐 Android pic_toolslibrary/pdf/ 4 个 PDF Activity
// 鸿蒙 pdfService 实际能力：图片转PDF / PDF转图片 / 压缩PDF / 删除加密
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
          result.success(await this.convertImagesToPdf(call));
          break;
        case 'convertPdfToImages':
          result.success(await this.convertPdfToImages(call));
          break;
        case 'compressPdf':
          result.success(await this.compressPdf(call));
          break;
        case 'encryptPdf':
          result.success(await this.encryptPdf(call));
          break;
        default:
          result.notImplemented();
      }
    } catch (e) {
      if (e instanceof PdfKitError) {
        hilog.error(0x0000, 'PdfKitPlugin', `code=%{public}s msg=%{public}s`, e.code, e.message);
        result.error(e.code, e.message, null);
      } else {
        const msg = (e as Error)?.message ?? String(e);
        hilog.error(0x0000, 'PdfKitPlugin', `code=PDF_KIT_ERROR msg=%{public}s`, msg);
        result.error('PDF_KIT_ERROR', msg, null);
      }
    }
  }

  // ====== 图片转 PDF ======
  // 对齐 ImageToPdfProcessor.kt:20-103
  // 注意：Dart Map 在 ArkTS 侧解码为 Map 实例，必须用 call.argument() 取值，
  // 直接 args['key'] 索引访问会得到 undefined。
  // widths/heights 由 Flutter 侧用 image 包读取的真实尺寸传入，
  // 缺失时回退 A4 竖版。
  private async convertImagesToPdf(call: MethodCall): Promise<string> {
    const rawList: ESObject = call.argument('imagePaths');
    const imagePaths: string[] = (rawList ?? []) as string[];
    const outputPath: string = call.argument('outputPath') as string;
    const rawWidths: ESObject = call.argument('widths');
    const widths: number[] = (rawWidths ?? []) as number[];
    const rawHeights: ESObject = call.argument('heights');
    const heights: number[] = (rawHeights ?? []) as number[];
    const fileName: string = (call.argument('fileName') as string) ?? '';
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
      // 校验图片在原生侧可见，把“路径不可访问”与后续 API 失败区分开
      try {
        fileIo.accessSync(imgPath);
      } catch {
        throw new Error(`图片文件不可访问：${imgPath}`);
      }
      const srcW = (i < widths.length && widths[i] > 0) ? widths[i] : A4_WIDTH;
      const srcH = (i < heights.length && heights[i] > 0) ? heights[i] : A4_HEIGHT;
      const scale = Math.min(A4_WIDTH / srcW, A4_HEIGHT / srcH);
      const drawW = srcW * scale;
      const drawH = srcH * scale;
      const x = (A4_WIDTH - drawW) / 2;
      const y = (A4_HEIGHT - drawH) / 2;

      // createDocument 后文档已自带第 0 页；第 1 张复用首页，其余往后插入，
      // 避免首页空白。
      const page = i === 0 ? doc.getPage(0) : doc.insertBlankPage(i, A4_WIDTH, A4_HEIGHT);
      try {
        page.addImageObject(imgPath, x, y, drawW, drawH);
      } catch (e) {
        doc.releaseDocument();
        throw new Error(`插入图片失败(${imgPath})：${(e as Error)?.message ?? String(e)}`);
      }
    }

    const ok = doc.saveDocument(outputPath);
    doc.releaseDocument();
    if (!ok) throw new Error(`保存 PDF 失败(${outputPath})`);

    // 弹出系统保存位置选择（默认下载目录），把 PDF 导出到用户可见目录
    return await this.exportToUserLocation(outputPath, fileName);
  }

  /**
   * 通过系统文档保存选择器把沙箱内 PDF 保存到用户选择的目录。
   * 应用沙箱外的公共目录（下载/文档）无法直接写入，必须走系统保存选择器。
   */
  private async exportToUserLocation(sandboxPath: string, fileName: string): Promise<string> {
    const saveName = this.safeSaveName(fileName);
    const documentSaveOptions: picker.DocumentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = [saveName];
    // 本 SDK 无 DocumentSavePicker，保存统一走 DocumentViewPicker.save()
    const documentViewPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker();
    const uris: Array<string> = await documentViewPicker.save(documentSaveOptions);
    if (!uris || uris.length === 0) {
      throw new PdfKitError('PDF_SAVE_CANCELED', '已取消保存');
    }
    const targetUri = uris[0];
    // 标准写法：先 openSync(uri) 拿 fd 再 copy，避免 copyFile 直接收 uri 的解析差异
    let targetFile: fileIo.File | undefined;
    try {
      targetFile = await fileIo.open(targetUri, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE);
      await fileIo.copyFile(sandboxPath, targetFile.fd);
    } catch (e) {
      throw new Error(`导出到所选位置失败(${targetUri})：${(e as Error)?.message ?? String(e)}`);
    } finally {
      if (targetFile) {
        try {
          await fileIo.close(targetFile);
        } catch {
          // 关闭失败不影响保存结果
        }
      }
    }
    return targetUri;
  }

  // 保存文件名兜底：去掉非法字符，缺省用时间戳命名
  private safeSaveName(fileName: string): string {
    const cleaned = fileName.replace(/[\\/:*?"<>|]/g, '_').trim();
    return cleaned.endsWith('.pdf') && cleaned.length > 4 ? cleaned : `images_to_pdf_${Date.now()}.pdf`;
  }

  // ====== PDF 转图片 ======
  // 使用 PDFKit 普通 convertToImage() 模式，不处理加密 PDF 密码。
  private async convertPdfToImages(call: MethodCall): Promise<string[]> {
    const pdfPath: string = call.argument('pdfPath') as string;
    const outputDir: string = call.argument('outputDir') as string;

    if (!pdfPath || !outputDir) throw new Error('PDF 路径或输出目录为空');
    this.ensureDir(outputDir + '/.keep');
    const doc = new pdfService.PdfDocument();
    // 不传密码：加密 PDF 不属于本功能的处理范围。
    const loadResult = doc.loadDocument(pdfPath);
    if (loadResult !== pdfService.ParseResult.PARSE_SUCCESS) {
      doc.releaseDocument();
      throw new Error('PDF 加载失败，请确认文件有效且未加密');
    }

    const ok = doc.convertToImage(outputDir, pdfService.ImageFormat.PNG);
    if (!ok) {
      doc.releaseDocument();
      throw new Error('PDF 转图片失败');
    }

    const imagePaths = await this.listPngFiles(outputDir);
    doc.releaseDocument();
    if (imagePaths.length === 0) {
      throw new Error('PDF 转图片成功，但未找到输出图片');
    }
    return imagePaths;
  }

  // ====== 压缩 PDF ======
  // 对齐 PdfCompressor.kt:28-149：每页渲染成图片后重新创建 PDF
  // 鸿蒙实现：每页渲染为无损 PNG → 缩放到 dpi 等效分辨率 → ImagePacker 以
  // JPEG(quality) 重编码 → 按源页面尺寸重建 PDF。
  // convertToImage 无质量/分辨率参数，渲染尺寸系统默认偏高，若不缩放，
  // 位图化的每页 JPEG 会比矢量内容更大，导致“压缩”反而膨胀。
  private async compressPdf(call: MethodCall): Promise<string> {
    const sourcePath: string = call.argument('sourcePath') as string;
    const outputPath: string = call.argument('outputPath') as string;
    const rawPassword: ESObject = call.argument('password');
    const password: string = (rawPassword ?? '') as string;
    const rawQuality: ESObject = call.argument('jpegQuality');
    const jpegQuality: number = typeof rawQuality === 'number' ? rawQuality : 0.9;
    const rawDpi: ESObject = call.argument('dpi');
    const dpi: number = typeof rawDpi === 'number' && rawDpi > 0 ? rawDpi : 120;

    this.ensureDir(outputPath);
    const srcDoc = new pdfService.PdfDocument();
    const loadResult = srcDoc.loadDocument(sourcePath, password);
    if (loadResult !== pdfService.ParseResult.PARSE_SUCCESS) {
      srcDoc.releaseDocument();
      throw new Error('PDF 加载失败');
    }

    // 1. 记录每页物理尺寸（PDF pt，1pt = 1/72 英寸），用于重建与缩放计算
    const pageCount = srcDoc.getPageCount();
    const pageSizes: ImageSize[] = [];
    for (let i = 0; i < pageCount; i++) {
      const page = srcDoc.getPage(i);
      pageSizes.push({ width: page.getWidth(), height: page.getHeight() });
    }

    const tmpRoot = this.context!.cacheDir + '/pdf_compress_' + Date.now();
    const pngDir = tmpRoot + '/png';
    const jpgDir = tmpRoot + '/jpg';
    fileIo.mkdir(pngDir, true);
    fileIo.mkdir(jpgDir, true);

    // 2. 每页渲染为无损 PNG 中间文件
    const renderOk = srcDoc.convertToImage(pngDir, pdfService.ImageFormat.PNG);
    srcDoc.releaseDocument();
    if (!renderOk) throw new Error('PDF 渲染失败');

    const pngFiles = await this.listPngFiles(pngDir);
    if (pngFiles.length === 0) throw new Error('未生成压缩图片');

    // 3. PNG → 按 dpi 缩放 → JPEG(quality)
    const quality = Math.round(jpegQuality * 100);
    const jpegPaths: string[] = [];
    for (let i = 0; i < pngFiles.length; i++) {
      // 页面 pt 尺寸 × dpi/72 = 目标像素；与渲染页数量不齐时按 A4 兜底
      const size: ImageSize = i < pageSizes.length ? pageSizes[i] : { width: 595, height: 842 };
      const targetW = Math.round(size.width * dpi / 72);
      const targetH = Math.round(size.height * dpi / 72);
      const jpgPath = jpgDir + '/page_' + (i + 1) + '.jpg';
      await this.reencodeJpeg(pngFiles[i], jpgPath, quality, targetW, targetH);
      jpegPaths.push(jpgPath);
    }

    // 4. 用 JPEG 重建 PDF（页面尺寸保持源 PDF 的 pt 尺寸）
    const firstSize: ImageSize = pageSizes.length > 0 ? pageSizes[0] : { width: 595, height: 842 };
    const outDoc = new pdfService.PdfDocument();
    if (!outDoc.createDocument(firstSize.width, firstSize.height)) {
      outDoc.releaseDocument();
      throw new Error('创建输出 PDF 失败');
    }
    for (let i = 0; i < jpegPaths.length; i++) {
      const size: ImageSize = i < pageSizes.length ? pageSizes[i] : { width: 595, height: 842 };
      const page = i === 0 ? outDoc.getPage(0) : outDoc.insertBlankPage(i, size.width, size.height);
      page.addImageObject(jpegPaths[i], 0, 0, size.width, size.height);
    }

    const saveOk = outDoc.saveDocument(outputPath);
    outDoc.releaseDocument();
    if (!saveOk) throw new Error(`保存压缩 PDF 失败(${outputPath})`);

    const saveName = outputPath.substring(outputPath.lastIndexOf('/') + 1);
    return await this.exportToUserLocation(outputPath, saveName);
  }

  // PNG → 缩放到目标像素(只缩不放) → JPEG(quality)。
  // 依赖 @kit.ImageKit 的 createPixelMap(desiredSize) + ImagePacker
  // （pdfService.convertToImage 无质量/分辨率参数）。
  private async reencodeJpeg(srcPath: string, dstPath: string, quality: number, targetW: number, targetH: number): Promise<void> {
    const source = image.createImageSource(srcPath);
    const packer = image.createImagePacker();
    let pixelMap: image.PixelMap | null = null;
    let dstFile: fileIo.File | undefined;
    try {
      const info = await source.getImageInfo();
      // 目标分辨率低于渲染分辨率才缩放，避免放大损失
      const scale = Math.min(1, targetW / info.size.width);
      const decodeOpts: image.DecodingOptions = {};
      if (scale < 1) {
        decodeOpts.desiredSize = {
          width: Math.max(1, Math.round(info.size.width * scale)),
          height: Math.max(1, Math.round(info.size.height * scale)),
        };
      }
      pixelMap = await source.createPixelMap(decodeOpts);
      dstFile = await fileIo.open(dstPath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE);
      const packOpts: image.PackingOption = { format: 'image/jpeg', quality: quality };
      await packer.packToFile(pixelMap, dstFile.fd, packOpts);
    } catch (e) {
      throw new Error(`图片重编码失败(${srcPath})：${(e as Error)?.message ?? String(e)}`);
    } finally {
      packer.release();
      source.release();
      pixelMap?.release();
      if (dstFile) {
        try {
          await fileIo.close(dstFile);
        } catch {
          // 关闭失败不影响结果
        }
      }
    }
  }

  // ====== 加密 PDF ======
  // 对齐 PdfSecurityProcessor.kt:20-58
  // 本 SDK 的 HMS pdfService 提供 setPdfPassword(password): boolean，
  // 流程：loadDocument → setPdfPassword → saveDocument → releaseDocument
  private async encryptPdf(call: MethodCall): Promise<string> {
    const sourcePath: string = call.argument('sourcePath') as string;
    const outputPath: string = call.argument('outputPath') as string;
    const password: string = call.argument('password') as string;
    if (!sourcePath || !password) throw new Error('缺少 PDF 路径或密码');

    this.ensureDir(outputPath);
    const doc = new pdfService.PdfDocument();
    const loadResult = doc.loadDocument(sourcePath);
    if (loadResult !== pdfService.ParseResult.PARSE_SUCCESS) {
      doc.releaseDocument();
      throw new Error('PDF 加载失败，请确认文件有效');
    }

    const encryptOk = doc.setPdfPassword(password);
    if (!encryptOk) {
      doc.releaseDocument();
      throw new Error('设置密码失败');
    }
    const saveOk = doc.saveDocument(outputPath);
    doc.releaseDocument();
    if (!saveOk) throw new Error(`保存加密 PDF 失败(${outputPath})`);

    // 导出到用户选择的公共目录（下载/文档），保存名沿用输出文件名
    const saveName = outputPath.substring(outputPath.lastIndexOf('/') + 1);
    return await this.exportToUserLocation(outputPath, saveName);
  }

  // 确保输出文件所在目录存在
  private ensureDir(filePath: string): void {
    const lastSlash = filePath.lastIndexOf('/');
    if (lastSlash <= 0) return;
    const dir = filePath.substring(0, lastSlash);
    try {
      fileIo.accessSync(dir);
    } catch {
      fileIo.mkdirSync(dir, true);
    }
  }

  // 列出目录下所有 png 文件并排序
  private async listPngFiles(dir: string): Promise<string[]> {
    try {
      const files = await fileIo.listFile(dir);
      return files
        .filter((f: string) => f.toLowerCase().endsWith('.png'))
        .sort((left: string, right: string) => this.comparePageFileNames(left, right))
        .map((f: string) => dir + '/' + f);
    } catch {
      return [];
    }
  }

  // convertToImage() 的文件名包含页码；按页码排序，避免 page_10 排在 page_2 前面。
  private comparePageFileNames(left: string, right: string): number {
    const leftNumber = this.pageNumber(left);
    const rightNumber = this.pageNumber(right);
    if (leftNumber !== rightNumber) return leftNumber - rightNumber;
    return left.localeCompare(right);
  }

  private pageNumber(fileName: string): number {
    const matches = fileName.match(/(\d+)(?=\.png$)/i);
    return matches ? Number(matches[1]) : Number.MAX_SAFE_INTEGER;
  }
}
