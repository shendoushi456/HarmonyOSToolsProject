import { MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { HandlerType, PoiMethod, RoutePlanMethod, SearchMethod, ShareUrlMethod } from '../Constants';
import AoiSearchHandler from './AoiSearchHandler';
import BaseHandler from './BaseHandler';
import BuildingSearchHandler from './BuildingSearchHandler';
import BusLineSearchHandler from './BusLineSearchHandler';
import DistrictSearchHandler from './DistrictSearchHandler';
import GeoCodeSearchHandler from './GeoCodeSearchHandler';
import PoiSearchHandler from './PoiSearchHandler';
import RecommendStopSearchHandler from './RecommendStopSearchHandler';
import RoutePlanSearchHandler from './RoutePlanSearchHandler';
import ShareUrlHandler from './ShareUrlHandler';
import SugSearchHandler from './SugSearchHandler';
import WeatherSearchHandler from './WeatherSearchHandler';


export class HandlerFactory {
  private sHandlerMap: Map<number, BaseHandler>

  constructor(channel: MethodChannel | null) {
    this.sHandlerMap = new Map
    this.sHandlerMap.set(HandlerType.POI_SEARCH_TYPE, new PoiSearchHandler(channel))
    this.sHandlerMap.set(HandlerType.SUGGESTION_SEARCH_TYPE, new SugSearchHandler(channel))
    this.sHandlerMap.set(HandlerType.GEO_CODER_AND_REVERSE_GEO_CODER_SEARCH_TYPE, new GeoCodeSearchHandler(channel))
    this.sHandlerMap.set(HandlerType.ROUTE_LINE_SEARCH_TYPE, new RoutePlanSearchHandler(channel))
    this.sHandlerMap.set(HandlerType.SHARE_URL_TYPE, new ShareUrlHandler(channel))
    this.sHandlerMap.set(HandlerType.DISTRICT_SEARCH_TYPE, new DistrictSearchHandler(channel))
    this.sHandlerMap.set(HandlerType.AOI_SEARCH_TYPE, new AoiSearchHandler(channel))
    this.sHandlerMap.set(HandlerType.BUILDING_SEARCH_TYPE, new BuildingSearchHandler(channel))
    this.sHandlerMap.set(HandlerType.WEATHER_TYPE, new WeatherSearchHandler(channel))
    this.sHandlerMap.set(HandlerType.RECOMMEND_STOP_TYPE, new RecommendStopSearchHandler(channel))
    this.sHandlerMap.set(HandlerType.BUS_LINE_SEARCH_TYPE, new BusLineSearchHandler(channel))
  }

  /**
   *  将消息分发给对应的功能handler
   */
  dispatchMethodHandler(call: MethodCall, result: MethodResult) {
    let method: string = call.method
    let handler: BaseHandler | null = null
    switch (method) {
      //城市检索
      case PoiMethod.POI_SEARCH_IN_CITY:
    //区域检索
      case PoiMethod.POI_SEARCH_INBOUNDS:
    //周边检索
      case PoiMethod.POI_SEARCH_NEARBY:
    //室内检索
      case PoiMethod.POI_INDOOR_SEARCH:
    //详情检索
      case PoiMethod.POI_DETAIL_SEARCH:
        handler = this.sHandlerMap.get(HandlerType.POI_SEARCH_TYPE) as BaseHandler
        break
    //sug检索
      case SearchMethod.SUGGESTION_SEARCH:
        handler = this.sHandlerMap.get(HandlerType.SUGGESTION_SEARCH_TYPE) as BaseHandler
        break
    //地理编码
      case SearchMethod.GEO_CODE_SEARCH:
    //逆地理编码
      case SearchMethod.REVERSE_GEO_CODE_SEARCH:
        handler = this.sHandlerMap.get(HandlerType.GEO_CODER_AND_REVERSE_GEO_CODER_SEARCH_TYPE) as BaseHandler
        break
    //行政区划检索
      case SearchMethod.DISTRICT_SEARCH:
        handler = this.sHandlerMap.get(HandlerType.DISTRICT_SEARCH_TYPE) as BaseHandler
        break
    //AOI检索
      case SearchMethod.AOI_SEARCH:
        handler = this.sHandlerMap.get(HandlerType.AOI_SEARCH_TYPE) as BaseHandler
        break
    //建筑物检索
      case SearchMethod.BUILDING_SEARCH:
        handler = this.sHandlerMap.get(HandlerType.BUILDING_SEARCH_TYPE) as BaseHandler
        break
    //天气检索
      case SearchMethod.WEATHER_SEARCH:
        handler = this.sHandlerMap.get(HandlerType.WEATHER_TYPE) as BaseHandler
        break
    //推荐上车点
      case SearchMethod.RECOMMEND_STOP_SEARCH:
        handler = this.sHandlerMap.get(HandlerType.RECOMMEND_STOP_TYPE) as BaseHandler
        break
    //公交信息检索
      case SearchMethod.BUS_LINE_SEARCH:
        handler = this.sHandlerMap.get(HandlerType.BUS_LINE_SEARCH_TYPE) as BaseHandler
        break
      case RoutePlanMethod.TRANSIT_ROUTE_SEARCH:
      case RoutePlanMethod.MASS_TRANSIT_ROUTE_SEARCH:
      case RoutePlanMethod.DRIVING_ROUTE_SEARCH:
      case RoutePlanMethod.RIDING_ROUTE_SEARCH:
      case RoutePlanMethod.WALKING_ROUTE_SEARCH:
      case RoutePlanMethod.INDOOR_ROUTE_SEARCH:
        handler = this.sHandlerMap.get(HandlerType.ROUTE_LINE_SEARCH_TYPE) as BaseHandler
        break
      case ShareUrlMethod.PoiDetailShareUrl:
      case ShareUrlMethod.LocationShareUrl:
      case ShareUrlMethod.RoutePlanShareUrl:
        handler = this.sHandlerMap.get(HandlerType.SHARE_URL_TYPE) as BaseHandler
        break
      default:
        result?.success(false)
        break

    }
    if (handler) {
      handler.handlerMethodCallResult(call, result)
    }
  }

  release() {
    if (this.sHandlerMap) {
      this.sHandlerMap.forEach((handler) => {
        if (handler) {
          handler.clean()
        }
      })
      this.sHandlerMap.clear()
    }
  }
}
