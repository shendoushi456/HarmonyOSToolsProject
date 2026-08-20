import http from '@ohos.net.http';
import util from '@ohos.util';
import { BusinessError } from '@ohos.base';
import MethodChannel, { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { FlutterEngine, MethodCall } from '@ohos/flutter_ohos';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';

const TAG = 'DocumentUploadPlugin';
const LOG_TAG = 'wdfyqqsj';
const CHANNEL_NAME = 'hm.ruisi.saosaole/document_upload';

/**
 * 使用 HarmonyOS NetStack 上传文档。
 *
 * Dart Socket 在上传较长的 application/x-www-form-urlencoded 请求体时会被
 * 对端重置；这里保留 Dart 生成的有道签名和参数，仅切换实际传输实现。
 */
export default class DocumentUploadPlugin {
  private channel?: MethodChannel;

  static register(flutterEngine: FlutterEngine): DocumentUploadPlugin {
    const plugin = new DocumentUploadPlugin();
    plugin.attach(flutterEngine);
    return plugin;
  }

  attach(flutterEngine: FlutterEngine): void {
    const messenger = flutterEngine.dartExecutor.getBinaryMessenger();
    this.channel = new MethodChannel(messenger, CHANNEL_NAME);
    this.channel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        if (call.method === 'upload') {
          this.upload(call, result);
          return;
        }
        result.notImplemented();
      }
    });
  }

  detach(): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = undefined;
  }

  private async upload(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      const url = call.argument('url') as string;
      const fields = call.argument('fields') as Map<string, string>;
      if (!url || !fields) {
        result.error('invalid_arguments', '缺少上传参数', null);
        return;
      }

      const encodedFields: string[] = [];
      const entries = fields.entries();
      for (let entry = entries.next(); !entry.done; entry = entries.next()) {
        const key = entry.value[0];
        const value = entry.value[1];
        encodedFields.push(`${this.formEncode(key)}=${this.formEncode(value)}`);
      }
      const formBody = encodedFields.join('&');
      // 文档接口要求 UTF-8 的表单。显式传入字节数组和 Content-Length，避免
      // NetStack 对较长字符串请求体采用服务端不兼容的发送方式。
      const formBytes = new util.TextEncoder().encodeInto(formBody);
      const fileName = fields.get('fileName') ?? '';
      const fileType = fields.get('fileType') ?? '';
      const langFrom = fields.get('langFrom') ?? '';
      const langTo = fields.get('langTo') ?? '';
      const qLength = (fields.get('q') ?? '').length;
      const appKey = fields.get('appKey') ?? '';
      const salt = fields.get('salt') ?? '';
      const curtime = fields.get('curtime') ?? '';
      Log.d(
        TAG,
        `${LOG_TAG} upload request: url=${url}, method=POST, ` +
          `contentType=application/x-www-form-urlencoded; charset=UTF-8, ` +
          `fileName=${fileName}, fileType=${fileType}, langFrom=${langFrom}, langTo=${langTo}, ` +
          `q=<base64 omitted, length=${qLength}>, appKey=${this.maskSuffix(appKey)}, ` +
          `salt=${salt}, curtime=${curtime}, sign=<masked>, signType=${fields.get('signType') ?? ''}, ` +
          `docType=${fields.get('docType') ?? ''}, formBytes=${formBytes.byteLength}`
      );
      const request = http.createHttp();
      try {
        const response = await request.request(url, {
          method: http.RequestMethod.POST,
          extraData: formBytes.buffer,
          expectDataType: http.HttpDataType.STRING,
          header: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'Accept': 'application/json',
            'Content-Length': formBytes.byteLength.toString()
          },
          connectTimeout: 120000,
          readTimeout: 120000,
          usingProtocol: http.HttpProtocol.HTTP1_1,
          usingCache: false
        });
        const responseText = response.result as string;
        Log.d(
          TAG,
          `${LOG_TAG} upload response: status=${response.responseCode}, ` +
            `bodyLength=${responseText.length}, body=${this.safeResponseLog(responseText)}`
        );
        result.success(responseText);
      } finally {
        request.destroy();
      }
    } catch (error) {
      const businessError = error as BusinessError;
      const message = businessError?.message ?? JSON.stringify(error);
      const detail = `NetStack error: code=${businessError?.code ?? 'unknown'}, message=${message}`;
      Log.e(TAG, `${LOG_TAG} upload failed: ${detail}`);
      result.error('native_upload_failed', detail, null);
    }
  }

  /**
   * 对齐 OkHttp FormBody：空格编码为 '+'，并编码 HTML 表单保留字符。
   * 不能直接传 Object 给 NetStack，否则它的序列化格式不是 x-www-form-urlencoded。
   */
  private formEncode(value: string): string {
    return encodeURIComponent(value)
      .replace(/%20/g, '+')
      .replace(/[!'()*]/g, (character: string): string => {
        return `%${character.charCodeAt(0).toString(16).toUpperCase()}`;
      });
  }

  private maskSuffix(value: string): string {
    const visibleLength = 4;
    if (value.length <= visibleLength) {
      return '****';
    }
    return `***${value.substring(value.length - visibleLength)}`;
  }

  private safeResponseLog(value: string): string {
    const maxLength = 2000;
    return value.length <= maxLength ? value : `${value.substring(0, maxLength)}...<truncated>`;
  }
}
