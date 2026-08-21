import { CoordType, Initializer, LatLng } from '@bdmap/base';
import {
  AoiResult,
  BikingRouteLine,
  BikingRouteResult,
  BikingStep,
  BuildingResult,
  BusLineResult,
  CityInfo,
  DistrictResult,
  DrivingRouteLine,
  DrivingRouteResult,
  DrivingStep,
  GeoCodeResult,
  MassTransitRouteLine,
  MassTransitRouteResult,
  MassTransitStep,
  ParentPoiInfo,
  parseGeoStr2LLArray,
  parseStrPathToLLArray,
  PoiChildrenInfo,
  PoiDetailInfo,
  PoiDetailSearchResult,
  PoiIndoorResult,
  PoiInfo,
  PoiResult,
  RecommendStopResult,
  ReverseGeoCodeResult,
  RouteNode,
  SuggestAddrInfo,
  SuggestionResult,
  TaxiInfo,
  TransitResultNode,
  TransitRouteLine,
  TransitRouteResult,
  TransitStep,
  VehicleInfo,
  WalkingRouteLine,
  WalkingRouteResult,
  WalkingStep,
  WeatherResult
} from '@bdmap/search';
import { AnyValue } from './Constants';
import { isBoolean, isNumber, isString } from './FlutterDataConvert';
import LogUtil from './LogUtil';
import { List } from '@kit.ArkTS';

/**
 * 将原生层对象转换为Flutter层参数
 */
export default class NativeDataConvert {
  static latLngToMap(position: LatLng | null | undefined, isNeedMapKey?: boolean,
    mapKey: string = 'coord'): Map<string, object | number> {
    let resultMap: Map<string, object> = new Map;
    if (position) {
      let map: Map<string, number> = new Map;
      map.set('latitude', position.lat);
      map.set('longitude', position.lng);
      if (isNeedMapKey) {
        resultMap.set(mapKey, map);
      } else {
        return map
      }
    }
    return resultMap
  }

  static PoiResultToMap(poiResult: PoiResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (poiResult) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', isString(id) ? String(id) : '')
      resultMap.set('totalPageNum', poiResult.totalPageNum ?? -1)
      resultMap.set('curPageIndex', poiResult.currentPageNum ?? -1)
      resultMap.set('totalPOINum', poiResult.totalPoiNum ?? -1)
      resultMap.set('curPOINum', poiResult.currentPageCapacity ?? -1)
      if (poiResult.arrayPoiInfo && poiResult.arrayPoiInfo.length > 0) {
        let poiArray = new Array<Map<string, AnyValue>>()
        poiResult.arrayPoiInfo.forEach((value, index) => {
          let poi = NativeDataConvert.poiInfoToMap(value)
          if (poi) {
            poiArray[index] = poi
          }
        })
        if (poiArray.length > 0) {
          resultMap.set('poiInfoList', poiArray)
        }
      }
      return resultMap
    }
    return
  }

  static poiInfoToMap(poiInfo: PoiInfo): Nullable<Map<string, AnyValue>> {
    if (poiInfo) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('name', poiInfo.name ?? '')
      if (poiInfo.location) {
        resultMap.set('pt', NativeDataConvert.latLngToMap(poiInfo.location, false))
      }
      resultMap.set('address', poiInfo.address ?? '')
      resultMap.set('phone', poiInfo.phoneNum ?? '')
      resultMap.set('uid', poiInfo.uid ?? '')
      resultMap.set('province', poiInfo.province ?? '')
      resultMap.set('city', poiInfo.city ?? '')
      resultMap.set('area', poiInfo.area ?? '')
      resultMap.set('streetID', poiInfo.street_id ?? '')
      resultMap.set('tag', poiInfo.tag ?? '')
      resultMap.set('hasDetailInfo', poiInfo.hasCaterDetails ?? false)
      resultMap.set('direction', poiInfo.direction ?? '')
      resultMap.set('distance', poiInfo.distance ? poiInfo.distance : 0)
      resultMap.set('zipCode', poiInfo.postCode ?? '')
      resultMap.set('adcode', poiInfo.address ?? '')

      let parentMap = NativeDataConvert.poiParentToMap(poiInfo.parentPoiInfo)
      if (parentMap) {
        resultMap.set('parentPOI', parentMap)
      }
      if (poiInfo.poiDetailInfo) {
        resultMap.set('detailInfo', NativeDataConvert.poiDetailInfoToMap(poiInfo.poiDetailInfo))
      }
      return resultMap
    }
    return
  }

  static poiDetailInfoToMap(poiDetailInfo: PoiDetailInfo | undefined): Nullable<Map<string, AnyValue>> {
    if (poiDetailInfo) {
      let detailInfoMap = new Map<string, AnyValue>()
      detailInfoMap.set('imageNumber', poiDetailInfo.imageNum ? poiDetailInfo.imageNum : 0)
      detailInfoMap.set('grouponNumber', poiDetailInfo.grouponNum ? poiDetailInfo.grouponNum : 0)
      detailInfoMap.set('checkInNumber', poiDetailInfo.checkinNum ? poiDetailInfo.checkinNum : 0)
      detailInfoMap.set('favoriteNumber', poiDetailInfo.favoriteNum ? poiDetailInfo.favoriteNum : 0)
      detailInfoMap.set('commentNumber', poiDetailInfo.commentNum ? poiDetailInfo.commentNum : 0)
      detailInfoMap.set('discountNumber', poiDetailInfo.discountNum ? poiDetailInfo.discountNum : 0)
      detailInfoMap.set('overallRating', poiDetailInfo.overallRating ?? 0)
      detailInfoMap.set('facilityRating', poiDetailInfo.facilityRating ?? 0)
      detailInfoMap.set('tasteRating', poiDetailInfo.tasteRating ?? 0)
      detailInfoMap.set('serviceRating', poiDetailInfo.serviceRating ?? 0)
      detailInfoMap.set('hygieneRating', poiDetailInfo.hygieneRating ?? 0)
      detailInfoMap.set('environmentRating', poiDetailInfo.environmentRating ?? 0)
      detailInfoMap.set('technologyRating', poiDetailInfo.technologyRating ?? 0)
      detailInfoMap.set('price', poiDetailInfo.price ?? 0)
      detailInfoMap.set('tag', poiDetailInfo.tag ?? '')
      detailInfoMap.set('type', poiDetailInfo.type ?? '')
      detailInfoMap.set('detailURL', poiDetailInfo.detailUrl ?? '')
      detailInfoMap.set('openingHours', poiDetailInfo.shopHours ?? '')
      detailInfoMap.set('distance', poiDetailInfo.distance ?? 0)
      if (poiDetailInfo.naviLocation) {
        detailInfoMap.set('naviLocation', NativeDataConvert.latLngToMap(poiDetailInfo.naviLocation))
      }
      if (poiDetailInfo.poiChildrenInfoList && poiDetailInfo.poiChildrenInfoList.length > 0) {
        let childArray = new Array<Map<string, AnyValue>>()
        poiDetailInfo.poiChildrenInfoList.forEach((value, index) => {
          let child = NativeDataConvert.poiChildToMap(value)
          if (child) {
            childArray[index] = child
          }
        })
        if (childArray.length > 0) {
          detailInfoMap.set('children', childArray)
        }
      }
      return detailInfoMap
    }
    return
  }

  // 详情检索专用
  static PoiDetailResultToMap(poiDetailSearchResult: PoiDetailSearchResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (poiDetailSearchResult) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', isString(id) ? String(id) : '')
      if (poiDetailSearchResult.poiDetailInfoList) {
        let detailInfoArray = new Array<Map<string, AnyValue>>()
        let index = 0;
        poiDetailSearchResult.poiDetailInfoList?.forEach((poiDetailInfo) => {
          if (poiDetailInfo) {
            let poiInfoMap = new Map<string, AnyValue>()
            poiInfoMap.set('name', poiDetailInfo.name ?? '')
            if (poiDetailInfo.location) {
              poiInfoMap.set('pt', NativeDataConvert.latLngToMap(poiDetailInfo.location, false))
            }
            poiInfoMap.set('address', poiDetailInfo.address ?? '')
            poiInfoMap.set('phone', poiDetailInfo.telephone ?? '')
            poiInfoMap.set('uid', poiDetailInfo.uid ?? '')
            poiInfoMap.set('province', poiDetailInfo.province ?? '')
            poiInfoMap.set('city', poiDetailInfo.city ?? '')
            poiInfoMap.set('area', poiDetailInfo.area ?? '')
            poiInfoMap.set('streetID', poiDetailInfo.streetId ?? '')
            poiInfoMap.set('tag', poiDetailInfo.tag ?? '')
            poiInfoMap.set('distance', poiDetailInfo.distance ?? 0)
            poiInfoMap.set('detail', poiDetailInfo.detail ?? 0)
            poiInfoMap.set('adcode', poiDetailInfo.address ?? '')
            poiInfoMap.set('label', poiDetailInfo.label ?? '')
            poiInfoMap.set('newAlias', poiDetailInfo.newAlias ?? '')
            poiInfoMap.set('classifiedPoiTag', poiDetailInfo.classifiedPoiTag ?? '')
            poiInfoMap.set('parentId', poiDetailInfo.parentId ?? '')
            let detailMap = NativeDataConvert.poiDetailInfoToMap(poiDetailInfo)
            poiInfoMap.set('detailInfo', detailMap)
            poiInfoMap.set('hasDetailInfo', detailMap ? true : false)
            detailInfoArray[index++] = poiInfoMap
          }
        })
        resultMap.set('poiInfoList', detailInfoArray)
        resultMap.set('totalPOINum', detailInfoArray.length)
      }
      return resultMap
    }
    return
  }

  static poiIndoorToMap(poiIndoor: PoiIndoorResult, id: AnyValue,
    curPageIndex: AnyValue): Nullable<Map<string, AnyValue>> {
    if (poiIndoor && poiIndoor.arrayPoiInfo) {
      let resultMap = new Map<string, AnyValue>()
      let indoorInfoArray = new Array<Map<string, AnyValue>>()
      let index = 0;
      poiIndoor.arrayPoiInfo.forEach(poiIndoorInfo => {
        let indoorMap = new Map<string, AnyValue>()
        indoorMap.set('name', poiIndoorInfo.name ?? '')
        indoorMap.set('uid', poiIndoorInfo.uid ?? '')
        indoorMap.set('indoorID', poiIndoorInfo.bid ?? '')
        indoorMap.set('floor', poiIndoorInfo.floor ?? '')
        indoorMap.set('address', poiIndoorInfo.address ?? '')
        indoorMap.set('city', poiIndoorInfo.cid ? poiIndoorInfo.cid.toString() : '')
        indoorMap.set('phone', poiIndoorInfo.phone ?? '')
        if (poiIndoorInfo.latLng) {
          indoorMap.set('pt', NativeDataConvert.latLngToMap(poiIndoorInfo.latLng, false))
        }
        indoorMap.set('tag', poiIndoorInfo.tag ?? '')
        indoorMap.set('tag', poiIndoorInfo.tag ?? '')
        indoorMap.set('price', poiIndoorInfo.price ? poiIndoorInfo.price : 0)
        indoorMap.set('starLevel', poiIndoorInfo.starLevel ? poiIndoorInfo.starLevel : 0)
        indoorMap.set('grouponFlag', poiIndoorInfo.isGroup)
        indoorMap.set('takeoutFlag', poiIndoorInfo.isTakeOut)
        indoorMap.set('waitedFlag', poiIndoorInfo.isWaited)
        indoorMap.set('grouponNum', poiIndoorInfo.groupNum ? poiIndoorInfo.groupNum : 0)
        indoorMap.set('discount', poiIndoorInfo.discount ? poiIndoorInfo.discount : 0)
        indoorInfoArray[index++] = indoorMap
      })
      resultMap.set('id', isString(id) ? String(id) : '')
      resultMap.set('poiIndoorInfoList', indoorInfoArray)
      resultMap.set('totalPOINum', poiIndoor.poiNum)
      resultMap.set('totalPageNum', poiIndoor.pageNum)
      resultMap.set('curPOINum', indoorInfoArray.length)
      resultMap.set('curPageIndex', isNumber(curPageIndex) ? curPageIndex : 0)
      return resultMap
    }
    return
  }

  static SuggestionResultToMap(result: SuggestionResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result && result.suggestionList) {
      let resultMap = new Map<string, AnyValue>()
      let itemList = new List<Map<string, AnyValue>>()
      result.suggestionList.forEach((item) => {
        if (item) {
          let itemMap = new Map<string, AnyValue>()
          itemMap.set('key', item.key)
          itemMap.set('uid', item.uid)
          itemMap.set('city', item.city)
          itemMap.set('district', item.district)
          itemMap.set('tag', item.tag)
          itemMap.set('address', item.address)
          itemMap.set('location', NativeDataConvert.latLngToMap(item.pt))
          if (item.poiChildrenInfoList) {
            let childrenList = new List<Map<string, AnyValue>>()
            item.poiChildrenInfoList.forEach((childItem) => {
              if (childItem) {
                let childMap = new Map<string, AnyValue>()
                childMap.set('uid', childItem.uid)
                childMap.set('name', childItem.name)
                childMap.set('showName', childItem.showName)
                childrenList.add(childMap)
              }
            })
            itemMap.set('children', childrenList)
          }
          itemList.add(itemMap)
        }
      })
      resultMap.set('id', id)
      resultMap.set('suggestionList', itemList)
      return resultMap
    }
    return
  }

  static GeoCodeResultToMap(result: GeoCodeResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', id)
      resultMap.set('level', result.level ?? '')
      resultMap.set('precise', result.precise ? result.precise : 0)
      resultMap.set('confidence', result.confidence ? result.confidence : 0)
      resultMap.set('location', NativeDataConvert.latLngToMap(result.location))
      return resultMap
    }
    return
  }

  static DistrictResultToMap(result: DistrictResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', id)
      resultMap.set('code', result.cityCode ? result.cityCode : 0)
      resultMap.set('name', result.cityName)
      resultMap.set('center', NativeDataConvert.latLngToMap(result.centerPt))
      if (result.polylines) {
        let outerList = new List<List<object>>()
        result.polylines.forEach(innerArray => {
          if (innerArray) {
            let innerList = new List<object>()
            innerArray.forEach(value => {
              if (value) {
                let latLngMap = NativeDataConvert.latLngToMap(value)
                if (latLngMap) {
                  innerList.add(latLngMap)
                }
              }
            })
            outerList.add(innerList)
          }
        })
        resultMap.set('paths', outerList)
      }
      return resultMap
    }
    return
  }

  static AoiResultToMap(result: AoiResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result && result.aoiList) {
      let resultMap = new Map<string, AnyValue>()
      let itemList = new List<Map<string, AnyValue>>()
      result.aoiList.forEach((item) => {
        if (item) {
          let itemMap = new Map<string, AnyValue>()
          itemMap.set('name', item.aoiName ?? '')
          itemMap.set('uid', item.uid ?? '')
          itemMap.set('nearestDistance', item.nearestDistance ? item.nearestDistance : 0)
          itemMap.set('relation', item.relation ? item.relation : 0)
          itemMap.set('order', item.order ? item.order : 0)
          itemMap.set('type', item.aoiType?.valueOf() ?? 0)
          itemMap.set('paths', item.polygon ?? '')
          itemList.add(itemMap)
        }
      })
      resultMap.set('id', id)
      resultMap.set('aoiInfoList', itemList)
      return resultMap
    }
    return
  }

  static BuildingResultToMap(result: BuildingResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result && result.buildingList) {
      let resultMap = new Map<string, AnyValue>()
      let itemList = new List<Map<string, AnyValue>>()
      result.buildingList.forEach((item) => {
        if (item) {
          let itemMap = new Map<string, AnyValue>()
          itemMap.set('height', item.height ? item.height : 0)
          itemMap.set('paths', item.geom ?? '')
          itemMap.set('accuracy', item.accuracy ? item.accuracy : 0)
          itemMap.set('structId', item.structId ?? '')
          itemMap.set('label', item.label ? item.label : 0)
          if (item.center && item.center.match(',')) {
            let centerArray = item.center.split(',')
            if (centerArray.length == 2) {
              itemMap.set('center', new Map().set('latitude', Number(centerArray[1])).set('longitude', centerArray[0]))
            }
          }

          itemList.add(itemMap)
        }
      })
      resultMap.set('id', id)
      resultMap.set('buildingList', itemList)
      return resultMap
    }
    return
  }

  static ReverseGeoCodeResultToMap(result: ReverseGeoCodeResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', id)
      resultMap.set('location', NativeDataConvert.latLngToMap(result.location))
      resultMap.set('address', result.address ?? '')
      resultMap.set('businessCircle', result.businessCircle ?? '')
      resultMap.set('sematicDescription', result.sematicDescription ?? '')
      if (result.addressDetail) {
        let detailMap = new Map<string, AnyValue>()
        detailMap.set('country', result.addressDetail.countryName ?? '')
        detailMap.set('province', result.addressDetail.province ?? '')
        detailMap.set('city', result.addressDetail.city ?? '')
        detailMap.set('district', result.addressDetail.district ?? '')
        detailMap.set('town', result.addressDetail.town ?? '')
        detailMap.set('streetName', result.addressDetail.street ?? '')
        detailMap.set('streetNumber', result.addressDetail.streetNumber ?? '')
        detailMap.set('adCode', String(result.addressDetail.adcode))
        detailMap.set('countryCode', String(result.addressDetail.countryCode))
        detailMap.set('direction', result.addressDetail.direction ?? '')
        detailMap.set('distance',
          result.addressDetail.distance ? result.addressDetail.distance?.toString() : '0')
        resultMap.set('addressDetail', detailMap)
      }
      if (result.poiRegionsInfoList) {
        let regionList = new List<Map<string, AnyValue>>()
        result.poiRegionsInfoList.forEach(item => {
          if (item) {
            let itemMap = new Map<string, AnyValue>()
            itemMap.set('regionDescription', item.directionDesc ?? '')
            itemMap.set('regionName', item.regionName ?? '')
            itemMap.set('regionTag', item.regionTag ?? '')
            regionList.add(itemMap)
          }
        })
        resultMap.set('poiRegions', regionList)
      }
      if (result.poiList) {
        let poiList = new List<Map<string, AnyValue>>()
        result.poiList.forEach(item => {
          let poi = NativeDataConvert.poiInfoToMap(item)
          if (poi) {
            poiList.add(poi)
          }
        })
        resultMap.set('poiList', poiList)
      }
      return resultMap
    }
    return
  }

  static WeatherResultToMap(result: WeatherResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', id)

      if (result.realTimeWeather) {
        let realTimeMap = new Map<string, AnyValue>()
        realTimeMap.set('relativeHumidity',
          result.realTimeWeather.relativeHumidity ? result.realTimeWeather.relativeHumidity : 0)
        realTimeMap.set('sensoryTemp',
          result.realTimeWeather.sensoryTemp ? result.realTimeWeather.sensoryTemp : 0)
        realTimeMap.set('phenomenon', result.realTimeWeather.phenomenon ?? '')
        realTimeMap.set('windDirection', result.realTimeWeather.windDirection ?? '')
        realTimeMap.set('windPower', result.realTimeWeather.windPower ?? '')
        realTimeMap.set('updateTime', result.realTimeWeather.updateTime ?? '')
        realTimeMap.set('temperature',
          result.realTimeWeather.temperature ? result.realTimeWeather.temperature : 0)
        realTimeMap.set('clouds', result.realTimeWeather.clouds ? result.realTimeWeather.clouds : 0)
        realTimeMap.set('hourlyPrecipitation',
          result.realTimeWeather.hourlyPrecipitation ? result.realTimeWeather.hourlyPrecipitation : 0)
        realTimeMap.set('visibility',
          result.realTimeWeather.visibility ? result.realTimeWeather.visibility : 0)
        realTimeMap.set('O3', result.realTimeWeather.O3 ? result.realTimeWeather.O3 : 0)
        realTimeMap.set('PM2_5', result.realTimeWeather.PM2_5 ? result.realTimeWeather.PM2_5 : 0)
        realTimeMap.set('SO2', result.realTimeWeather.SO2 ? result.realTimeWeather.SO2 : 0)
        realTimeMap.set('airQualityIndex',
          result.realTimeWeather.airQualityIndex ? result.realTimeWeather.airQualityIndex : 0)
        realTimeMap.set('PM10', result.realTimeWeather.PM10 ? result.realTimeWeather.PM10 : 0)
        realTimeMap.set('CO', result.realTimeWeather.CO ? result.realTimeWeather.CO : 0)
        resultMap.set('realTimeWeather', realTimeMap)
      }

      if (result.location) {
        let locationMap = new Map<string, AnyValue>()
        locationMap.set('country', result.location.country ?? '')
        locationMap.set('province', result.location.province ?? '')
        locationMap.set('city', result.location.city ?? '')
        locationMap.set('districtName', result.location.districtName ?? '')
        locationMap.set('districtID', result.location.districtID ?? '')
        resultMap.set('location', locationMap)
      }

      if (result.forecasts) {
        let list = new List<object>()
        result.forecasts.forEach(item => {
          if (item) {
            let itemMap = new Map<string, AnyValue>()
            itemMap.set('lowestTemp', item.lowestTemp ? item.lowestTemp : 0)
            itemMap.set('highestTemp', item.lowestTemp ? item.highestTemp : 0)
            itemMap.set('airQualityIndex', item.airQualityIndex ? item.airQualityIndex : 0)
            itemMap.set('date', item.date ?? '')
            itemMap.set('week', item.week ?? '')
            itemMap.set('windPowerDay', item.windPowerDay ?? '')
            itemMap.set('windPowerNight', item.windPowerNight ?? '')
            itemMap.set('windDirectionDay', item.windDirectionDay ?? '')
            itemMap.set('windDirectionrNight', item.windDirectionNight ?? '')
            itemMap.set('phenomenonDay', item.phenomenonDay ?? '')
            itemMap.set('phenomenonNight', item.phenomenonNight ?? '')
            list.add(itemMap)
          }
        })
        resultMap.set('forecasts', list)
      }

      if (result.forecastHours) {
        let list = new List<object>()
        result.forecastHours.forEach(item => {
          if (item) {
            let itemMap = new Map<string, AnyValue>()
            itemMap.set('relativeHumidity', item.relativeHumidity ? item.relativeHumidity : 0)
            itemMap.set('temperature', item.temperature ? item.temperature : 0)
            itemMap.set('clouds', item.clouds ? item.clouds : 0)
            itemMap.set('hourlyPrecipitation', item.hourlyPrecipitation ? item.hourlyPrecipitation : 0)
            itemMap.set('dataTime', item.dataTime ?? '')
            itemMap.set('windDirection', item.windDirection ?? '')
            itemMap.set('windPower', item.windPower ?? '')
            itemMap.set('phenomenon', item.phenomenon ?? '')
            list.add(itemMap)
          }
        })
        resultMap.set('forecastHours', list)
      }

      if (result.lifeIndexes) {
        let list = new List<object>()
        result.lifeIndexes.forEach(item => {
          if (item) {
            let itemMap = new Map<string, AnyValue>()
            itemMap.set('name', item.name ?? '')
            itemMap.set('brief', item.brief ?? '')
            itemMap.set('detail', item.detail ?? '')
            list.add(itemMap)
          }
        })
        resultMap.set('lifeIndexes', list)
      }

      if (result.weatherAlerts) {
        let list = new List<object>()
        result.weatherAlerts.forEach(item => {
          if (item) {
            let itemMap = new Map<string, AnyValue>()
            itemMap.set('type', item.type ?? '')
            itemMap.set('level', item.level ?? '')
            itemMap.set('desc', item.desc ?? '')
            LogUtil.debug(`title=${item.title}`)
            itemMap.set('title', item.title ?? '')
            list.add(itemMap)
          }
        })
        resultMap.set('weatherAlerts', list)
      }

      return resultMap
    }
    return
  }

  static BusLineResultToMap(result: BusLineResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', id)

      resultMap.set('busLineName', result.busLineName ?? '')
      resultMap.set('busLineDirection', result.lineDirection ?? '')
      resultMap.set('uid', result.uid ?? '')
      resultMap.set('startTime', result.startTime ?? '')
      resultMap.set('endTime', result.endTime ?? '')
      resultMap.set('isMonTicket', isBoolean(result.isMonthTicket) ? result.isMonthTicket : false)
      resultMap.set('basicPrice', result.basePrice ? result.basePrice : 0)
      resultMap.set('totalPrice', result.maxPrice ? result.maxPrice : 0)

      if (result.stations) {
        let list = new List<object>()
        result.stations.forEach(item => {
          if (item) {
            let itemMap = new Map<string, AnyValue>()
            itemMap.set('uid', item.uid ?? '')
            itemMap.set('title', item.title ?? '')
            itemMap.set('location', NativeDataConvert.latLngToMap(item.location))
            list.add(itemMap)
          }
        })
        resultMap.set('busStations', list)
      }

      if (result.steps) {
        let list = new List<object>()
        result.steps.forEach(item => {
          if (item) {
            let itemMap = new Map<string, AnyValue>()
            itemMap.set('distance', item.distance ? item.distance : 0)
            itemMap.set('duration', item.duration ? item.duration : 0)
            itemMap.set('name', item.name ?? '')
            if (item.wayPoints) {
              let childList = new List<object>()
              item.wayPoints.forEach(childItem => {
                if (childItem) {
                  let step = NativeDataConvert.latLngToMap(childItem)
                  if (step) {
                    childList.add(step)
                  }
                }
              })
              itemMap.set('points', childList)
            }
            list.add(itemMap)
          }
        })
        resultMap.set('busSteps', list)
      }
      return resultMap
    }
    return
  }

  static RecommendStopResultToMap(result: RecommendStopResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', id)

      if (result.recommendStopInfoList) {
        let list = new List<object>()
        result.recommendStopInfoList.forEach(item => {
          if (item) {
            let itemMap = new Map<string, AnyValue>()
            itemMap.set('name', item.name ?? '')
            itemMap.set('address', item.address ?? '')
            itemMap.set('uid', item.id ?? '')
            itemMap.set('distance', item.distance ? item.distance : 0)
            if (Initializer.coordType = CoordType.GCJ02) {
              itemMap.set('location', NativeDataConvert.latLngToMap(new LatLng(item.lat_gcj02ll, item.lng_gcj02ll)))
            } else {
              itemMap.set('location', NativeDataConvert.latLngToMap(new LatLng(item.lat_bd09ll, item.lng_bd09ll)))
            }
            list.add(itemMap)
          }
        })
        resultMap.set('recommendStopInfoList', list)
      }

      if (result.stationInfoList) {
        let list = new List<object>()
        result.stationInfoList.forEach(item => {
          if (item) {
            let itemMap = new Map<string, AnyValue>()
            itemMap.set('stationName', item.stationName ?? '')
            if (item.recommendStops) {
              let childList = new List<object>()
              item.recommendStops.forEach(childItem => {
                if (childItem) {
                  let childItemMap = new Map<string, AnyValue>()
                  childItemMap.set('name', childItem.name ?? '')
                  childItemMap.set('address', childItem.address ?? '')
                  childItemMap.set('uid', childItem.id ?? '')
                  childItemMap.set('distance', childItem.distance ? childItem.distance : 0)
                  if (Initializer.coordType == CoordType.GCJ02) {
                    childItemMap.set('location',
                      NativeDataConvert.latLngToMap(new LatLng(childItem.lat_gcj02ll, childItem.lng_gcj02ll)))
                  } else {
                    childItemMap.set('location',
                      NativeDataConvert.latLngToMap(new LatLng(childItem.lat_bd09ll, childItem.lng_bd09ll)))
                  }
                  childList.add(childItemMap)
                }
              })
              itemMap.set('recommendStopsInfoList', childList)
            }
            list.add(itemMap)
          }
        })
        resultMap.set('stationInfoList', list)
      }

      return resultMap
    }
    return
  }

  static poiParentToMap(poiParent: ParentPoiInfo | null | undefined): Nullable<Map<string, AnyValue>> {
    if (poiParent) {
      let parentMap = new Map<string, AnyValue>()
      parentMap.set('name', poiParent.parentPoiName ?? '')
      parentMap.set('tag', poiParent.parentPoiTag ?? '')
      parentMap.set('address', poiParent.parentPoiAddress ?? '')
      parentMap.set('direction', poiParent.parentPoiDirection ?? '')
      parentMap.set('uid', poiParent.parentPoiUid ?? '')
      if (poiParent.parentPoiLocation) {
        parentMap.set('pt', NativeDataConvert.latLngToMap(poiParent.parentPoiLocation, false))
      }
      parentMap.set('distance', poiParent.parentPoiDistance ? poiParent.parentPoiDistance : 0)
      return parentMap
    }
    return
  }

  static poiChildToMap(poiChild: PoiChildrenInfo): Nullable<Map<string, AnyValue>> {
    if (poiChild) {
      let childMap = new Map<string, AnyValue>()
      childMap.set('name', poiChild.name ?? '')
      childMap.set('uid', poiChild.uid ?? '')
      childMap.set('tag', poiChild.tag ?? '')
      childMap.set('showName', poiChild.showName ?? '')
      childMap.set('address', poiChild.address ?? '')
      if (poiChild.location) {
        childMap.set('pt', NativeDataConvert.latLngToMap(poiChild.location, false))
      }
      return childMap
    }
    return
  }

  static massTransitRouteResultToMap(result: MassTransitRouteResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', id)
      resultMap.set('totalRoutes', result.total)
      if (result.massTaxiInfo && result.massTaxiInfo.length > 0) {
        //flutter层只接收一个taxiInfo
        let taxiInfoMap = NativeDataConvert.taxiInfoToMap(result.massTaxiInfo[0])
        if (taxiInfoMap) {
          resultMap.set('taxiInfo', taxiInfoMap)
        }
      }
      NativeDataConvert.suggestAddrInfoToMap(resultMap, result.suggestAddrInfo)
      NativeDataConvert.massTransitRoutesToMap(resultMap, result.routeLines, NativeDataConvert.isSameCity(result))
      NativeDataConvert.transitResultNodeToMap(resultMap, result.origin, 'origin')
      NativeDataConvert.transitResultNodeToMap(resultMap, result.destination, 'destination')
      return resultMap
    }
    return
  }

  static transitResultNodeToMap(resultMap: Map<string, AnyValue>, result: TransitResultNode | undefined | null,
    key: string) {
    if (result) {
      let map = new Map<string, AnyValue>()
      map.set('cityName', result.cityName ?? '')
      map.set('cityID', result.cityId ? result.cityId : 0)
      let ptMap = NativeDataConvert.latLngToMap(result.location)
      if (ptMap) {
        map.set('pt', ptMap)
      }
      resultMap.set(key, map)
    }
  }

  static bikingRouteResultToMap(result: BikingRouteResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', id)
      NativeDataConvert.suggestAddrInfoToMap(resultMap, result.suggestAddrInfo)
      NativeDataConvert.bikingRoutesToMap(resultMap, result.routeLines)
      return resultMap
    }
    return
  }

  static walkingRouteResultToMap(result: WalkingRouteResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', id)
      NativeDataConvert.suggestAddrInfoToMap(resultMap, result.suggestAddrInfo)
      NativeDataConvert.walkingRoutesToMap(resultMap, result.routeLines)
      let taxiInfoMap = NativeDataConvert.taxiInfoToMap(result.taxiInfo)
      if (taxiInfoMap) {
        resultMap.set('BMFTaxiInfo', taxiInfoMap)
      }
      return resultMap
    }
    return
  }

  static drivingRouteResultToMap(result: DrivingRouteResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', id)
      NativeDataConvert.suggestAddrInfoToMap(resultMap, result.suggestAddrInfo)
      if (result.taxiInfos) {
        let taxiList = new List<AnyValue>()
        result.taxiInfos.forEach(taxiInfo => {
          let taxiInfoMap = NativeDataConvert.taxiInfoToMap(taxiInfo)
          if (taxiInfoMap) {
            taxiList.add(taxiInfoMap)
          }
        })
        resultMap.set('taxiInfos', taxiList)
      }
      NativeDataConvert.drivingRoutesToMap(resultMap, result.routeLines)
      return resultMap
    }
    return
  }

  static TransitRouteResultToMap(result: TransitRouteResult,
    id: AnyValue): Nullable<Map<string, AnyValue>> {
    if (result) {
      let resultMap = new Map<string, AnyValue>()
      resultMap.set('id', id)
      let taxiInfoMap = NativeDataConvert.taxiInfoToMap(result.taxiInfo)
      if (taxiInfoMap) {
        resultMap.set('taxiInfo', taxiInfoMap)
      }
      NativeDataConvert.suggestAddrInfoToMap(resultMap, result.suggestAddrInfo)
      NativeDataConvert.transitRoutesToMap(resultMap, result.routeLines)
      return resultMap
    }
    return
  }

  static isSameCity(result: MassTransitRouteResult): boolean {
    if (result) {
      if (result.origin && result.destination) {
        if (result.origin.cityId && result.destination.cityId && result.origin.cityId == result.destination.cityId) {
          return true
        }
      }
    }
    return false
  }

  static massTransitRoutesToMap(resultMap: Map<string, AnyValue>, result: MassTransitRouteLine[] | undefined,
    isSameCity: boolean) {
    if (result && result.length > 0) {
      let routeList = new List<AnyValue>()
      result.forEach(routeItem => {
        if (routeItem && routeItem.newSteps && routeItem.newSteps.length > 0) {
          let stepMap = new Map<string, AnyValue>()
          let stepList = new List<AnyValue>()
          routeItem.newSteps.forEach(stepItemArray => {
            if (stepItemArray && stepItemArray.length > 0) {
              let stemItemMap = new Map<string, AnyValue>()
              let stepChildList = new List<AnyValue>()
              stepItemArray.forEach(stepChild => {
                let stepChildMap = NativeDataConvert.massTransitSubStepToMap(stepChild)
                if (stepChildMap) {
                  stepChildList.add(stepChildMap)
                }
              })
              stemItemMap.set('steps', stepChildList)
              stemItemMap.set('isSubStep', !isSameCity)
              stepList.add(stemItemMap)
            }
          })
          stepMap.set('steps', stepList)
          stepMap.set('price', routeItem.price)
          stepMap.set('title', routeItem.title)
          stepMap.set('distance', routeItem.distance)
          let durationMap = NativeDataConvert.durationToMap(routeItem.duration)
          if (durationMap) {
            stepMap.set('duration', durationMap)
          }
          NativeDataConvert.routeNodeToMap(stepMap, routeItem.starting, 'starting')
          NativeDataConvert.routeNodeToMap(stepMap, routeItem.terminal, 'terminal')
          routeList.add(stepMap)
        }
      })
      resultMap.set('routes', routeList)
    }
  }

  static walkingRoutesToMap(resultMap: Map<string, AnyValue>, result: WalkingRouteLine[] | undefined) {
    if (result && result.length > 0) {
      let routeList = new List<AnyValue>()
      result.forEach(routeItem => {
        if (routeItem && routeItem.steps && routeItem.steps.length > 0) {
          let stepMap = new Map<string, AnyValue>()
          let stepList = new List<AnyValue>()
          routeItem.steps.forEach(stepItem => {
            let stepMap = NativeDataConvert.walkingStepToMap(stepItem)
            if (stepMap) {
              stepList.add(stepMap)
            }
          })
          stepMap.set('steps', stepList)

          stepMap.set('distance', routeItem.distance)
          stepMap.set('title', routeItem.title)
          let durationMap = NativeDataConvert.durationToMap(routeItem.duration)
          if (durationMap) {
            stepMap.set('duration', durationMap)
          }
          NativeDataConvert.routeNodeToMap(stepMap, routeItem.starting, 'starting')
          NativeDataConvert.routeNodeToMap(stepMap, routeItem.terminal, 'terminal')
          routeList.add(stepMap)
        }
      })
      resultMap.set('routes', routeList)
    }
  }

  static bikingRoutesToMap(resultMap: Map<string, AnyValue>, result: BikingRouteLine[] | undefined) {
    if (result && result.length > 0) {
      let routeList = new List<AnyValue>()
      result.forEach(routeItem => {
        if (routeItem && routeItem.steps && routeItem.steps.length > 0) {
          let stepMap = new Map<string, AnyValue>()
          let stepList = new List<AnyValue>()
          routeItem.steps.forEach(stepItem => {
            let stepMap = NativeDataConvert.bikingStepToMap(stepItem)
            if (stepMap) {
              stepList.add(stepMap)
            }
          })
          stepMap.set('steps', stepList)

          stepMap.set('distance', routeItem.distance)
          stepMap.set('title', routeItem.title)
          let durationMap = NativeDataConvert.durationToMap(routeItem.duration)
          if (durationMap) {
            stepMap.set('duration', durationMap)
          }
          NativeDataConvert.routeNodeToMap(stepMap, routeItem.starting, 'starting')
          NativeDataConvert.routeNodeToMap(stepMap, routeItem.terminal, 'terminal')
          routeList.add(stepMap)
        }
      })
      resultMap.set('routes', routeList)
    }
  }

  static drivingRoutesToMap(resultMap: Map<string, AnyValue>, result: DrivingRouteLine[] | undefined) {
    if (result && result.length > 0) {
      let routeList = new List<AnyValue>()
      result.forEach(routeItem => {
        if (routeItem && routeItem.steps && routeItem.steps.length > 0) {
          let stepMap = new Map<string, AnyValue>()
          let stepList = new List<AnyValue>()
          routeItem.steps.forEach(stepItem => {
            let stepMap = NativeDataConvert.drivingStepToMap(stepItem)
            if (stepMap) {
              stepList.add(stepMap)
            }
          })
          stepMap.set('steps', stepList)

          if (routeItem.wayPoints && routeItem.wayPoints) {
            let wayPointList = new List<AnyValue>()
            routeItem.wayPoints.forEach(wayPointItem => {
              if (wayPointItem) {
                let map = new Map<string, AnyValue>()
                map.set('uid', wayPointItem.uid)
                map.set('title', wayPointItem.title)
                map.set('location', NativeDataConvert.latLngToMap(wayPointItem.location))
                wayPointList.add(map)
              }
            })
            resultMap.set('wayPoints', wayPointList)
          }

          stepMap.set('lightNum', routeItem.lightNum)
          stepMap.set('congestionMetres', routeItem.congestionDistance)
          stepMap.set('taxiFares', routeItem.toll)

          stepMap.set('distance', routeItem.distance)
          stepMap.set('title', routeItem.title)
          let durationMap = NativeDataConvert.durationToMap(routeItem.duration)
          if (durationMap) {
            stepMap.set('duration', durationMap)
          }
          NativeDataConvert.routeNodeToMap(stepMap, routeItem.starting, 'starting')
          NativeDataConvert.routeNodeToMap(stepMap, routeItem.terminal, 'terminal')
          routeList.add(stepMap)
        }
      })
      resultMap.set('routes', routeList)
    }
  }

  static transitRoutesToMap(resultMap: Map<string, AnyValue>, result: TransitRouteLine[] | undefined) {
    if (result && result.length > 0) {
      let routeList = new List<AnyValue>()
      result.forEach(routeItem => {
        if (routeItem && routeItem.steps && routeItem.steps.length > 0) {
          let stepMap = new Map<string, AnyValue>()
          let stepList = new List<AnyValue>()
          routeItem.steps.forEach(stepItem => {
            let stepMap = NativeDataConvert.transitStepToMap(stepItem)
            if (stepMap) {
              stepList.add(stepMap)
            }
          })
          stepMap.set('steps', stepList)
          stepMap.set('distance', routeItem.distance)
          stepMap.set('title', routeItem.title)
          let durationMap = NativeDataConvert.durationToMap(routeItem.duration)
          if (durationMap) {
            stepMap.set('duration', durationMap)
          }
          NativeDataConvert.routeNodeToMap(stepMap, routeItem.starting, 'starting')
          NativeDataConvert.routeNodeToMap(stepMap, routeItem.terminal, 'terminal')
          routeList.add(stepMap)
        }
      })
      resultMap.set('routes', routeList)
    }
  }

  static durationToMap(duration: number): Nullable<Map<string, AnyValue>> {
    if (duration > 0) {
      let day = duration / (60 * 60 * 24)
      day = Number.parseInt(day.toString())
      duration = duration - day * (60 * 60 * 24)
      let hour = duration / (60 * 60)
      hour = Number.parseInt(hour.toString())
      duration = duration - hour * (60 * 60)
      let minute = duration / 60
      minute = Number.parseInt(minute.toString())
      duration = duration - hour * 60
      let second = duration
      let durationMap = new Map<string, AnyValue>()
      durationMap.set('dates', day)
      durationMap.set('hours', hour)
      durationMap.set('minutes', minute)
      durationMap.set('seconds', second)
      return durationMap
    }
    return
  }

  static massTransitSubStepToMap(result: MassTransitStep | undefined): Nullable<Map<string, AnyValue>> {
    if (result) {
      let stepItemMap = new Map<string, AnyValue>()
      stepItemMap.set('instructions', result.instructions ?? '')
      stepItemMap.set('stepType', result.vehicleType ? result.vehicleType.valueOf() : -1)
      stepItemMap.set('distance', result.distance)
      stepItemMap.set('name', result.name)
      stepItemMap.set('pointsCount', result.wayPoints ? result.wayPoints.length : 0)
      stepItemMap.set('duration', result.duration)
      let entranceMap = NativeDataConvert.latLngToMap(result.startLocation)
      if (entranceMap) {
        stepItemMap.set('entraceCoor', entranceMap)
      }
      let endMap = NativeDataConvert.latLngToMap(result.endLocation)
      if (endMap) {
        stepItemMap.set('exitCoor', endMap)
      }
      if (result.pathString) {
        let pointsArray = parseStrPathToLLArray(result.pathString)
        if (pointsArray && pointsArray.length > 0) {
          let points = new List<AnyValue>()
          pointsArray.forEach(item => {
            let pointMap = NativeDataConvert.latLngToMap(item)
            if (pointMap) {
              points.add(pointMap)
            }
          })
          stepItemMap.set('points', points)
        }
      }
      if (result.trafficConditions && result.trafficConditions.length > 0) {
        let trafficList = new List<AnyValue>()
        result.trafficConditions.forEach(item => {
          if (item) {
            let trafficMap = new Map<string, AnyValue>()
            trafficMap.set('trafficStatus', item.trafficStatus)
            trafficMap.set('trafficGeoCnt', item.trafficGeoCnt)
            trafficList.add(trafficMap)
          }
        })
        stepItemMap.set('trafficConditions', trafficList)
      }

      if (result.busInfo) {
        let map = new Map<string, AnyValue>()
        map.set('name', result.busInfo.name)
        map.set('departureStation', result.busInfo.departureStation)
        map.set('arriveTime', result.busInfo.arriveTime)
        map.set('departureTime', result.busInfo.departureTime)
        map.set('arriveStation', result.busInfo.arriveStation)
        map.set('passStationNum', result.busInfo.stopNum ? result.busInfo.stopNum : 0)
        map.set('type', result.busInfo.type ? result.busInfo.type : 0)
        stepItemMap.set('busAndSubwayVehicleInfo', map)
      }

      if (result.planeInfo) {
        let map = new Map<string, AnyValue>()
        map.set('name', result.planeInfo.name)
        map.set('departureStation', result.planeInfo.departureStation)
        map.set('arriveTime', result.planeInfo.arriveTime)
        map.set('departureTime', result.planeInfo.departureTime)
        map.set('arriveStation', result.planeInfo.arriveStation)
        map.set('price', result.planeInfo.price)
        map.set('discount', result.planeInfo.discount)
        map.set('airlines', result.planeInfo.airlines)
        map.set('bookingUrl', result.planeInfo.booking)
        stepItemMap.set('planeVehicleInfo', map)
      }

      if (result.coachInfo) {
        let map = new Map<string, AnyValue>()
        map.set('name', result.coachInfo.name)
        map.set('departureStation', result.coachInfo.departureStation)
        map.set('arriveTime', result.coachInfo.arriveTime)
        map.set('departureTime', result.coachInfo.departureTime)
        map.set('arriveStation', result.coachInfo.arriveStation)
        map.set('price', result.coachInfo.price)
        map.set('bookingUrl', result.coachInfo.booking)
        map.set('providerName', result.coachInfo.providerName)
        map.set('providerUrl', result.coachInfo.providerUrl)
        stepItemMap.set('coachVehicleInfo', map)
      }

      if (result.trainInfo) {
        let map = new Map<string, AnyValue>()
        map.set('name', result.trainInfo.name)
        map.set('departureStation', result.trainInfo.departureStation)
        map.set('arriveTime', result.trainInfo.arriveTime)
        map.set('departureTime', result.trainInfo.departureTime)
        map.set('arriveStation', result.trainInfo.arriveStation)
        map.set('price', result.trainInfo.price ? result.trainInfo.price : 0)
        map.set('booking', result.trainInfo.booking ?? '')
        stepItemMap.set('trainVehicleInfo', map)
      }
      return stepItemMap
    }
    return
  }

  static walkingStepToMap(result: WalkingStep | undefined): Nullable<Map<string, AnyValue>> {
    if (result) {
      let stepItemMap = new Map<string, AnyValue>()

      stepItemMap.set('distance', result.distance)
      stepItemMap.set('duration', result.duration)
      stepItemMap.set('pointsCount', result.wayPoints ? result.wayPoints.length : 0)
      stepItemMap.set('name', result.name)
      if (result.pathString) {
        let points = new List<AnyValue>()
        let pathArray = parseGeoStr2LLArray(result.pathString);
        if (pathArray) {
          pathArray.forEach(item => {
            let pointMap = NativeDataConvert.latLngToMap(item)
            if (pointMap) {
              points.add(pointMap)
            }
          })
        }
        stepItemMap.set('points', points)
      }
      stepItemMap.set('direction', result.direction)
      NativeDataConvert.routeNodeToMap(stepItemMap, result.entrance, 'entrace')
      NativeDataConvert.routeNodeToMap(stepItemMap, result.exit, 'exit')
      stepItemMap.set('entraceInstruction', result.entranceInstructions ?? '')
      stepItemMap.set('exitInstruction', result.exitInstructions ?? '')
      stepItemMap.set('instruction', result.instructions ?? '')
      return stepItemMap
    }
    return
  }

  static bikingStepToMap(result: BikingStep | undefined): Nullable<Map<string, AnyValue>> {
    if (result) {
      let stepItemMap = new Map<string, AnyValue>()

      stepItemMap.set('distance', result.distance)
      stepItemMap.set('duration', result.duration)
      stepItemMap.set('pointsCount', result.wayPoints ? result.wayPoints.length : 0)
      stepItemMap.set('name', result.name)
      if (result.pathString) {
        let points = new List<AnyValue>()
        let pathArray = parseStrPathToLLArray(result.pathString);
        if (pathArray) {
          pathArray.forEach(item => {
            let pointMap = NativeDataConvert.latLngToMap(item)
            if (pointMap) {
              points.add(pointMap)
            }
          })
        }
        stepItemMap.set('points', points)
      }
      stepItemMap.set('direction', result.direction)
      NativeDataConvert.routeNodeToMap(stepItemMap, result.entrance, 'entrace')
      NativeDataConvert.routeNodeToMap(stepItemMap, result.exit, 'exit')
      stepItemMap.set('entraceInstruction', result.entranceInstructions ?? '')
      stepItemMap.set('exitInstruction', result.exitInstructions ?? '')
      stepItemMap.set('instruction', result.instructions ?? '')
      stepItemMap.set('turnType', result.turnType ?? '')
      stepItemMap.set('restrictionsStatus', result.restrictionsStatus ? result.restrictionsStatus : 0)
      stepItemMap.set('restrictionsInfo', result.restrictionsInfo ?? '')
      return stepItemMap
    }
    return
  }

  static drivingStepToMap(result: DrivingStep | undefined): Nullable<Map<string, AnyValue>> {
    if (result) {
      let stepItemMap = new Map<string, AnyValue>()
      stepItemMap.set('direction', result.direction)
      stepItemMap.set('entraceInstruction', result.entranceInstructions)
      stepItemMap.set('exitInstruction', result.exitInstructions)
      stepItemMap.set('instruction', result.instructions)
      stepItemMap.set('numTurns', result.numTurns)
      stepItemMap.set('hasTrafficsInfo', (result.trafficList && result.trafficList.length > 0) ? true : false)
      stepItemMap.set('traffics', result.trafficList)
      stepItemMap.set('distance', result.distance)
      stepItemMap.set('roadLevel', result.roadLevel)
      stepItemMap.set('roadName', result.roadName)
      stepItemMap.set('name', result.name)
      stepItemMap.set('pointsCount', result.wayPoints ? result.wayPoints.length : 0)
      stepItemMap.set('duration', result.duration)
      NativeDataConvert.routeNodeToMap(stepItemMap, result.entrance, 'entrace')
      NativeDataConvert.routeNodeToMap(stepItemMap, result.exit, 'exit')
      if (result.pathList) {
        let points = new List<AnyValue>()
        result.pathList.forEach(item => {
          let pointMap = NativeDataConvert.latLngToMap(item)
          if (pointMap) {
            points.add(pointMap)
          }
        })
        stepItemMap.set('points', points)
      }
      return stepItemMap
    }
    return
  }

  static transitStepToMap(result: TransitStep | undefined): Nullable<Map<string, AnyValue>> {
    if (result) {
      let stepItemMap = new Map<string, AnyValue>()
      stepItemMap.set('instruction', result.instructions ?? '')
      stepItemMap.set('stepType', result.stepType ? result.stepType.valueOf() : 0)
      stepItemMap.set('distance', result.distance)
      stepItemMap.set('name', result.name)
      stepItemMap.set('pointsCount', result.wayPoints ? result.wayPoints.length : 0)
      stepItemMap.set('duration', result.duration)
      NativeDataConvert.routeNodeToMap(stepItemMap, result.entrance, 'entrace')
      NativeDataConvert.routeNodeToMap(stepItemMap, result.exit, 'exit')
      NativeDataConvert.vehicleInfoToMap(stepItemMap, result.vehicleInfo, 'vehicleInfo')
      if (result.pathString) {
        let pointsArray = parseGeoStr2LLArray(result.pathString)
        if (pointsArray && pointsArray.length > 0) {
          let points = new List<AnyValue>()
          pointsArray.forEach(item => {
            let pointMap = NativeDataConvert.latLngToMap(item)
            if (pointMap) {
              points.add(pointMap)
            }
          })
          stepItemMap.set('points', points)
        }
      }
      return stepItemMap
    }
    return
  }

  static routeNodeToMap(resultMap: Map<string, AnyValue>, result: RouteNode | undefined | null, key: string) {
    if (result) {
      let map = new Map<string, AnyValue>()
      map.set('uid', result.uid)
      map.set('title', result.title)
      map.set('location', NativeDataConvert.latLngToMap(result.location))
      resultMap.set(key, map)
    }
  }

  static vehicleInfoToMap(resultMap: Map<string, AnyValue>, result: VehicleInfo | undefined, key: string) {
    if (result) {
      let map = new Map<string, AnyValue>()
      map.set('uid', result.uid)
      map.set('title', result.title)
      map.set('passStationNum', result.passStationNum)
      map.set('totalPrice', result.totalPrice)
      map.set('zonePrice', result.zonePrice)
      resultMap.set(key, map)
    }
  }

  static taxiInfoToMap(result: TaxiInfo | undefined): Nullable<Map<string, AnyValue>> {
    if (result) {
      let taxiMap = new Map<string, AnyValue>()
      taxiMap.set('desc', result.desc ?? '')
      taxiMap.set('distance', result.distance ? result.distance : 0)
      taxiMap.set('duration', result.duration ? result.duration : 0)
      taxiMap.set('perKMPrice', result.perKMPrice ? result.perKMPrice : 0)
      taxiMap.set('startPrice', result.startPrice ? result.startPrice : 0)
      taxiMap.set('totalPrice', result.startPrice ? result.totalPrice : 0)
      return taxiMap
    }
    return
  }

  static suggestAddrInfoToMap(resultMap: Map<string, AnyValue>, result: SuggestAddrInfo | undefined) {
    if (result) {

      let map = new Map<string, AnyValue>()
      if (result.suggestStartNode && result.suggestStartNode.length > 0) {
        let poiList = new List<Map<string, AnyValue>>()
        result.suggestStartNode.forEach(item => {
          let poi = NativeDataConvert.poiInfoToMap(item)
          if (poi) {
            poiList.add(poi)
          }
        })
        map.set('startPoiList', poiList)
      }

      if (result.suggestEndNode && result.suggestEndNode.length > 0) {
        let poiList = new List<Map<string, AnyValue>>()
        result.suggestEndNode.forEach(item => {
          let poi = NativeDataConvert.poiInfoToMap(item)
          if (poi) {
            poiList.add(poi)
          }
        })
        map.set('endPoiList', poiList)
      }

      if (result.suggestWpNode && result.suggestWpNode.length > 0) {
        let poiList = new List<Map<string, AnyValue>>()
        result.suggestWpNode.forEach(itemList => {
          if (itemList && itemList.length > 0) {
            itemList.forEach(item => {
              let poi = NativeDataConvert.poiInfoToMap(item)
              if (poi) {
                poiList.add(poi)
              }
            })
          }
        })
        map.set('wayPointPoiList', poiList)
      }

      if (result.suggestStartCity && result.suggestStartCity.length > 0) {
        let cityList = new List<Map<string, AnyValue>>()
        result.suggestStartCity.forEach(item => {
          let city = NativeDataConvert.cityInfoToMap(item)
          if (city) {
            cityList.add(city)
          }
        })
        map.set('startCityList', cityList)
      }

      if (result.suggestEndCity && result.suggestEndCity.length > 0) {
        let cityList = new List<Map<string, AnyValue>>()
        result.suggestEndCity.forEach(item => {
          let city = NativeDataConvert.cityInfoToMap(item)
          if (city) {
            cityList.add(city)
          }
        })
        map.set('endCityList', cityList)
      }
      if (result.suggestWpCity && result.suggestWpCity.length > 0) {
        let cityList = new List<Map<string, AnyValue>>()
        result.suggestWpCity.forEach(itemList => {
          if (itemList && itemList.length > 0) {
            itemList.forEach(item => {
              let city = NativeDataConvert.cityInfoToMap(item)
              if (city) {
                cityList.add(city)
              }
            })
          }
        })
        map.set('wayPointCityList', cityList)
      }
      resultMap.set('suggestAddrResult', map)
    }
  }

  static cityInfoToMap(cityInfo: CityInfo): Nullable<Map<string, AnyValue>> {
    if (cityInfo) {
      let cityMap = new Map<string, AnyValue>()
      cityMap.set('city', cityInfo.city ?? '')
      cityMap.set('count', Number(cityInfo.num))
      return cityMap
    }
    return
  }
}