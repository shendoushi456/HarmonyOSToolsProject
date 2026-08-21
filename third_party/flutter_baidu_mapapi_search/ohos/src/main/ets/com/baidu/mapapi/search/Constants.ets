export type AnyValue = string | boolean | number | object | null | undefined

export const METHOD_CHANNEL = 'flutter_bmfsearch'

export class HandlerType {
  static POI_SEARCH_TYPE = 0
  static DISTRICT_SEARCH_TYPE = 1
  static BUS_LINE_SEARCH_TYPE = 2
  static GEO_CODER_AND_REVERSE_GEO_CODER_SEARCH_TYPE = 3
  static ROUTE_LINE_SEARCH_TYPE = 4
  static SHARE_URL_TYPE = 5
  static SUGGESTION_SEARCH_TYPE = 6
  static RECOMMEND_STOP_TYPE = 7
  static WEATHER_TYPE = 8
  static BUILDING_SEARCH_TYPE = 9
  static AOI_SEARCH_TYPE = 10
}

export class PoiMethod {
  // 城市POI检索
  static POI_SEARCH_IN_CITY = METHOD_CHANNEL + '/poiSearch/poiSearchInCity'
  // 根据范围和检索词发起范围检索
  static POI_SEARCH_INBOUNDS = METHOD_CHANNEL + '/poiSearch/poiSearchInbounds'
  // 根据中心点、半径和检索词发起周边检索
  static POI_SEARCH_NEARBY = METHOD_CHANNEL + '/poiSearch/poiSearchNearBy'
  // 根据poi uid 发起poi详情检索
  static POI_DETAIL_SEARCH = METHOD_CHANNEL + '/poiSearch/poiDetailSearch'
  // poi室内检索
  static POI_INDOOR_SEARCH = METHOD_CHANNEL + '/poiSearch/poiIndoorSearch'
}

export class SearchMethod {
  // sug检索
  static SUGGESTION_SEARCH = METHOD_CHANNEL + '/suggestionSearch/suggestionSearch'
  // AOI检索
  static AOI_SEARCH = METHOD_CHANNEL + '/aoiSearch/aoiSearch'
  // 地理编码
  static GEO_CODE_SEARCH = METHOD_CHANNEL + '/geoSearch/geoCode'
  // 逆地理编码
  static REVERSE_GEO_CODE_SEARCH = METHOD_CHANNEL + '/geoSearch/reverseGeoCode'
  // 建筑物检索
  static BUILDING_SEARCH = METHOD_CHANNEL + '/buildingSearch/buildingSearch'
  // 行政区划检索
  static DISTRICT_SEARCH = METHOD_CHANNEL + '/districtSearch/districtSearch'
  // 天气检索
  static WEATHER_SEARCH = METHOD_CHANNEL + '/weatherSearch/weatherSearch'
  // 推荐上车点检索
  static RECOMMEND_STOP_SEARCH = METHOD_CHANNEL + '/recommendStopSearch/recommendStopSearch'
  // 公交信息检索
  static BUS_LINE_SEARCH = METHOD_CHANNEL + '/busLineSearch/busLineSearch'
}

export class RoutePlanMethod {
  // 公交路线检索（仅支持市内）
  static TRANSIT_ROUTE_SEARCH = METHOD_CHANNEL + '/routeSearch/transitSearch';
  // 公共交通路线检索（支持市内和跨城）
  static MASS_TRANSIT_ROUTE_SEARCH = METHOD_CHANNEL + '/routeSearch/massTransitSearch';
  // 驾乘路线检索
  static DRIVING_ROUTE_SEARCH = METHOD_CHANNEL + '/routeSearch/drivingSearch';
  // 步行路线检索
  static WALKING_ROUTE_SEARCH = METHOD_CHANNEL + '/routeSearch/walkingSearch';
  // 骑行路线检索
  static RIDING_ROUTE_SEARCH = METHOD_CHANNEL + '/routeSearch/ridingSearch';
  // 室内路线检索
  static INDOOR_ROUTE_SEARCH = METHOD_CHANNEL + '/routeSearch/indoorRoutePlanSearch';
}

export class ShareUrlMethod {
  // poi详情短串分享url
  static PoiDetailShareUrl = METHOD_CHANNEL + '/shareURL/requestPoiDetailShareURL'
  // 路线规划短串分享url
  static RoutePlanShareUrl = METHOD_CHANNEL + '/shareURL/requestRoutePlanShareURL'
  // location短串分享url
  static LocationShareUrl = METHOD_CHANNEL + '/shareURL/requestLocationShareURL'
}

export class PoiSortBasicType {
  /**
   * 宾馆行业，默认排序
   */
  static HOTEL_DEFAULT = 0
  /**
   * 宾馆行业，按价格排序
   */
  static HOTEL_PRICE = 1
  /**
   * 宾馆行业，按距离排序（只对周边检索有效）
   */
  static HOTEL_DISTANCE = 2
  /**
   * 宾馆行业，按好评排序
   */
  static HOTEL_TOTAL_SCORE = 3
  /**
   * 宾馆行业，按星级排序
   */
  static HOTEL_LEVEL = 4
  /**
   * 宾馆行业，按卫生排序
   */
  static HOTEL_HEALTH_SCORE = 5
  /**
   * 餐饮行业，默认排序
   */
  static CATER_DEFAULT = 6
  /**
   * 餐饮行业，按价格排序
   */
  static CATER_PRICE = 7
  /**
   * 餐饮行业，按距离排序（只对周边检索有效）
   */
  static CATER_DISTANCE = 8
  /**
   * <餐饮行业，按口味排序
   */
  static CATER_TASTE_RATING = 9
  /**
   * 餐饮行业，按好评排序
   */
  static CATER_OVERALL_RATING = 10
  /**
   * 餐饮行业，按服务排序
   */
  static CATER_SERVICE_RATING = 11
  /**
   * 生活娱乐行业，默认排序
   */
  static LIFE_DEFAULT = 12
  /**
   * 生活娱乐行业，按价格排序
   */
  static LIFE_PRICE = 13
  /**
   * 生活娱乐行业，按距离排序（只对周边检索有效）
   */
  static LIFE_DISTANCE = 14
  /**
   * 生活娱乐行业，按好评排序
   */
  static LIFE_OVERALL_RATING = 15
  /**
   * 生活娱乐行业，按服务排序
   */
  static LIFE_COMMENT_NUMBER = 16
}

export enum ErrorCode {
  /** 检索结果正常返回 */
  NO_ERROR,

  /**检索词有岐义*/
  AMBIGUOUS_KEYWORD,

  /**检索地址有岐义*/
  AMBIGUOUS_ROURE_ADDR,

  /**该城市不支持公交搜索*/
  NOT_SUPPORT_BUS,

  /**不支持跨城市公交*/
  NOT_SUPPORT_BUS_2CITY,

  /**没有找到检索结果*/
  RESULT_NOT_FOUND,

  /**起终点太近*/
  ST_EN_TOO_NEAR,

  /**key错误*/
  KEY_ERROR,

  /**网络连接错误*/
  NETWORK_ERROR,

  /**网络连接超时*/
  NETWORK_TIMEOUT,

  /**还未完成鉴权，请在鉴权通过后重试*/
  PERMISSION_UNFINISHED,

  /**室内图ID错误*/
  INDOOR_ID_ERROR,

  /**室内图检索楼层错误*/
  FLOOR_ERROR,

  /**起终点不在支持室内路线的室内图内*/
  INDOOR_ROUTE_NO_IN_BUILDING,

  /**起终点不在同一个室内*/
  INDOOR_ROUTE_NO_IN_SAME_BUILDING,

  /**参数错误*/
  PARAMETER_ERROR,

  /**服务器错误*/
  SERVER_ERROR,
}

