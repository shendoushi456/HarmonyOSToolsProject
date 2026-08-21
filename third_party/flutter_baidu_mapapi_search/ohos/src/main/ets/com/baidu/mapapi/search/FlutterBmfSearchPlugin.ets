import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { METHOD_CHANNEL } from './Constants';
import { HandlerFactory } from './handler/HandlerFactory';


export default class FlutterBmfSearchPlugin implements FlutterPlugin, MethodCallHandler {
  private sChannel: MethodChannel | null = null;
  private sHandlerFactory: HandlerFactory | null = null;

  constructor() {
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.sChannel = new MethodChannel(binding.getBinaryMessenger(), METHOD_CHANNEL);
    this.sChannel.setMethodCallHandler(this)
    this.sHandlerFactory = new HandlerFactory(this.sChannel)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.sChannel != null) {
      this.sChannel.setMethodCallHandler(null)
    }
    if (this.sHandlerFactory != null) {
      this.sHandlerFactory.release()
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (!call || !result || !call.method || !this.sHandlerFactory) {
      return
    }
    this.sHandlerFactory.dispatchMethodHandler(call, result)
  }

  getUniqueClassName(): string {
    return "FlutterBmfSearchPlugin"
  }
}