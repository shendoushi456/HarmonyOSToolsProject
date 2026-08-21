import { ERRORNO } from '@bdmap/search';
import { MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';

const REQUEST_ERROR = 25

export default abstract class BaseHandler {
  protected result?: MethodResult
  protected call?: MethodCall
  protected method: string = ''
  private errorCodeMap = new Map<ERRORNO, number>()
  private channel: MethodChannel | null = null

  constructor(channel: MethodChannel | null) {
    this.channel = channel
    this.errorCodeMap.set(ERRORNO.NO_ERROR, 0);
    this.errorCodeMap.set(ERRORNO.AMBIGUOUS_KEYWORD, 1);
    this.errorCodeMap.set(ERRORNO.AMBIGUOUS_ROURE_ADDR, 2);
    this.errorCodeMap.set(ERRORNO.NOT_SUPPORT_BUS, 3);
    this.errorCodeMap.set(ERRORNO.NOT_SUPPORT_BUS_2CITY, 4);
    this.errorCodeMap.set(ERRORNO.RESULT_NOT_FOUND, 5);
    this.errorCodeMap.set(ERRORNO.ST_EN_TOO_NEAR, 6);
    this.errorCodeMap.set(ERRORNO.KEY_ERROR, 7);
    this.errorCodeMap.set(ERRORNO.NETWORK_ERROR, 8);
    this.errorCodeMap.set(ERRORNO.NETWORK_TIME_OUT, 9);
    this.errorCodeMap.set(ERRORNO.PERMISSION_UNFINISHED, 10);
    this.errorCodeMap.set(ERRORNO.POIINDOOR_BID_ERROR, 11);
    this.errorCodeMap.set(ERRORNO.POIINDOOR_FLOOR_ERROR, 12);
    this.errorCodeMap.set(ERRORNO.INDOOR_ROUTE_NO_IN_BUILDING, 13);
    this.errorCodeMap.set(ERRORNO.INDOOR_ROUTE_NO_IN_SAME_BUILDING, 14);
    this.errorCodeMap.set(ERRORNO.SEARCH_OPTION_ERROR, 15);
    this.errorCodeMap.set(ERRORNO.SEARCH_SERVER_INTERNAL_ERROR, 16);
    this.errorCodeMap.set(ERRORNO.NO_ADVANCED_PERMISSION, 18);
    this.errorCodeMap.set(ERRORNO.NO_DATA_FOR_LATLNG, 19);
    this.errorCodeMap.set(ERRORNO.INVALID_DISTRICT_ID, 20);
    this.errorCodeMap.set(ERRORNO.POIINDOOR_SERVER_ERROR, 21);
    this.errorCodeMap.set(ERRORNO.MASS_TRANSIT_SERVER_ERROR, 22);
    this.errorCodeMap.set(ERRORNO.MASS_TRANSIT_OPTION_ERROR, 23);
    this.errorCodeMap.set(ERRORNO.MASS_TRANSIT_NO_POI_ERROR, 24);
    this.errorCodeMap.set(ERRORNO.REQUEST_ERROR, 25);
  }

  handlerMethodCallResult(call: MethodCall, result: MethodResult) {
    this.call = call
    this.result = result
    if (this.call) {
      this.method = call.method
      this.handleMethod()
    }
  }

  abstract handleMethod()

  protected callback(method: string, value: Object, errorCode: number) {
    this.channel?.invokeMethod(method, new Map().set('result', value).set('errorCode', errorCode))
  }

  protected getErrorCode(code?: ERRORNO | undefined): number {
    if (code != undefined) {
      return this.errorCodeMap.get(code) ?? REQUEST_ERROR
    }
    return REQUEST_ERROR
  }

  protected sendReturnResult(result: boolean) {
    this.result?.success(new Map().set('result', result))
  }

  abstract clean()
}