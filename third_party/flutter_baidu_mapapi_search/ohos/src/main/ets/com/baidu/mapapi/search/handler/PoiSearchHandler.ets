import { AnyValue, PoiMethod, PoiSortBasicType } from '../Constants';
import FlutterDataConvert, { isBoolean, toMap } from '../FlutterDataConvert';
import BaseHandler from './BaseHandler';
import {
  CaterSortName,
  HotelSortName,
  IndustryType,
  LifeSortName,
  PoiBoundSearchOption,
  PoiBoundSearchOptionParams,
  PoiCitySearchOption,
  PoiCitySearchOptionParams,
  PoiDetailSearchResult,
  PoiFilter,
  PoiIndoorOption,
  PoiIndoorResult,
  PoiNearbySearchOption,
  PoiNearbySearchOptionParams,
  PoiResult,
  PoiSearch,
  SortName
} from '@bdmap/search';
import { isNumber, isString } from '../../search/FlutterDataConvert';
import NativeDataConvert from '../NativeDataConvert';
import { LatLngBounds } from '@bdmap/base';
import LogUtil from '../LogUtil';

export default class PoiSearchHandler extends BaseHandler {
  search: PoiSearch | null = null

  handleMethod(): void {
    if (this.search == null) {
      this.search = PoiSearch.newInstance()
    }
    switch (this.method) {
      case PoiMethod.POI_SEARCH_IN_CITY:
        this.searchInCity()
        break
      case PoiMethod.POI_SEARCH_INBOUNDS:
        this.searchInBound()
        break
      case PoiMethod.POI_SEARCH_NEARBY:
        this.searchNearby()
        break
      case PoiMethod.POI_DETAIL_SEARCH:
        this.searchPoiDetail()
        break
      case PoiMethod.POI_INDOOR_SEARCH:
        this.searchIndoor()
        break
      default:
        this.sendReturnResult(false)
        break
    }
  }

  searchInCity() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('poiCitySearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let city = optionMap.get('city');
        let keyword = optionMap.get('keyword');
        if (isString(city) && isString(keyword)) {
          let optionParams: PoiCitySearchOptionParams = {
            city: String(city),
            keyword: String(keyword)
          }
          if (isBoolean(optionMap.get('isCityLimit'))) {
            optionParams.isCityLimit = Boolean(optionMap.get('isCityLimit'))
          }
          this.parseCommonParams(optionMap, optionParams)
          let option = new PoiCitySearchOption(optionParams)
          this.search.searchInCity(option).then((result: PoiResult) => {
            this.callback(PoiMethod.POI_SEARCH_IN_CITY, Object(NativeDataConvert.PoiResultToMap(result, id)),
              this.getErrorCode(result?.error))
          })
            .catch((err: Error) => {
              LogUtil.error('poiCitySearch error:' + JSON.stringify(err))
              this.callback(PoiMethod.POI_SEARCH_IN_CITY, Object(new Map().set('id', id)), this.getErrorCode())
            })
          this.sendReturnResult(true)
          return
        }
      }
    }
    this.sendReturnResult(false)
  }

  searchInBound() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('poiBoundSearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let keywordArray = optionMap.get('keywords') as Array<string>
        let leftBottomMap = toMap(optionMap.get('leftBottom'))
        let rightTopMap = toMap(optionMap.get('rightTop'))
        if (leftBottomMap && rightTopMap && keywordArray instanceof Array) {
          let southWest = FlutterDataConvert.mapToLatLng(leftBottomMap)
          let northEast = FlutterDataConvert.mapToLatLng(rightTopMap)
          let keywords = ''
          keywordArray.forEach((value, index) => {
            if (index == 0) {
              keywords = value
            } else {
              keywords = keywords + '$' + value
            }
          })
          if (keywords && southWest && northEast) {
            let optionParams: PoiBoundSearchOptionParams = {
              bound: new LatLngBounds(southWest, northEast),
              keyword: String(keywords)
            }
            this.parseCommonParams(optionMap, optionParams)
            let option = new PoiBoundSearchOption(optionParams)
            this.search.searchInBound(option).then((result: PoiResult) => {
              this.callback(PoiMethod.POI_SEARCH_INBOUNDS, Object(NativeDataConvert.PoiResultToMap(result, id)),
                this.getErrorCode(result?.error))
            })
            this.sendReturnResult(true)
            return
          }
        }
      }
    }
    this.sendReturnResult(false)
  }

  searchNearby() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('poiNearbySearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let keywordArray = optionMap.get('keywords') as Array<string>
        let locationMap = toMap(optionMap.get('location'))
        let radius = optionMap.get('radius')
        if (locationMap && isNumber(radius) && keywordArray instanceof Array) {
          let location = FlutterDataConvert.mapToLatLng(locationMap)
          let keywords = ''
          keywordArray.forEach((value, index) => {
            if (index == 0) {
              keywords = value
            } else {
              keywords = keywords + '$' + value
            }
          })
          if (keywords && location) {
            let optionParams: PoiNearbySearchOptionParams = {
              keyword: keywords,
              location: location,
              radius: Number(radius)
            }

            if (isBoolean(optionMap.get('isRadiusLimit'))) {
              optionParams.radiusLimit = Boolean(optionMap.get('isRadiusLimit'))
            }
            this.parseCommonParams(optionMap, optionParams)
            let option = new PoiNearbySearchOption(optionParams)
            this.search.searchNearby(option).then((result: PoiResult) => {
              this.callback(PoiMethod.POI_SEARCH_NEARBY, Object(NativeDataConvert.PoiResultToMap(result, id)),
                this.getErrorCode(result?.error))
            })
            this.sendReturnResult(true)
            return
          }
        }
      }
    }
    this.sendReturnResult(false)
  }

  searchPoiDetail() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('poiDetailSearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let uidArray = optionMap.get('poiUIDs') as Array<string>
        if (uidArray instanceof Array) {
          this.search.searchPoiDetail({
            uids: uidArray.toString(),
            isExtendAdcode:
            isBoolean(optionMap.get('extensionsAdcode')) ? Boolean(optionMap.get('extensionsAdcode')) : false
          }).then((result: PoiDetailSearchResult) => {
            this.callback(PoiMethod.POI_DETAIL_SEARCH, Object(NativeDataConvert.PoiDetailResultToMap(result, id)),
              this.getErrorCode(result?.error))
          })
          this.sendReturnResult(true)
          return
        }
      }
    }
    this.sendReturnResult(false)
  }

  searchIndoor() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('poiIndoorSearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let indoorID = optionMap.get('indoorID');
        let keyword = optionMap.get('keyword');
        let floor = optionMap.get('floor');
        if (isString(indoorID) && isString(keyword)) {
          let optionParams: PoiIndoorOption = {
            bid: String(indoorID),
            wd: String(keyword),
            floor: isString(floor) ? String(floor) : ''
          }
          let pageIndex = optionMap.get('pageIndex')
          if (isNumber(pageIndex)) {
            optionParams.currentPage = Number(pageIndex)
          }
          if (isNumber(optionMap.get('pageSize'))) {
            optionParams.pageSize = Number(optionMap.get('pageSize'))
          }
          this.search.searchPoiIndoor(optionParams).then((result: PoiIndoorResult) => {
            this.callback(PoiMethod.POI_INDOOR_SEARCH, Object(NativeDataConvert.poiIndoorToMap(result, id, pageIndex)),
              this.getErrorCode(result?.error))
          })
          this.sendReturnResult(true)
          return
        }
      }
    }
    this.sendReturnResult(false)
  }

  clean(): void {
    if (this.search) {
      this.search.destroy()
    }
  }

  parseCommonParams(optionMap: Map<string, AnyValue>,
    optionParams: PoiCitySearchOptionParams | PoiBoundSearchOptionParams | PoiNearbySearchOptionParams) {
    if (optionMap && optionParams) {
      if (isNumber(optionMap.get('pageIndex'))) {
        optionParams.pageNum = Number(optionMap.get('pageIndex'))
      }
      if (isNumber(optionMap.get('pageSize'))) {
        optionParams.pageCapacity = Number(optionMap.get('pageSize'))
      }
      if (isNumber(optionMap.get('scope'))) {
        optionParams.scope = Number(optionMap.get('scope')) + 1
      }
      if (isBoolean(optionMap.get('extensionsAdcode'))) {
        optionParams.isExtendAdcode = Boolean(optionMap.get('extensionsAdcode'))
      }
      if (optionMap.get('tags') instanceof Array) {
        let tags: string = ''
        let tagsArray = optionMap.get('tags') as Array<string>
        tagsArray.forEach((value, index) => {
          index == 0 ? tags = value : tags = tags + `,${value}`
        })
      }
      let filter = this.getPoiFilter(optionMap)
      if (filter) {
        optionParams.poiFilter = filter
      }
    }
  }

  getIndustryType(industryType: number): Nullable<IndustryType> {
    if (industryType == 0) {
      return IndustryType.HOTEL
    } else if (industryType == 1) {
      return IndustryType.CATER
    } else if (industryType == 2) {
      return IndustryType.LIFE
    }
    return;
  }

  getSortName(sortType: number): Nullable<SortName> {
    let sortName: SortName | undefined
    switch (sortType) {
      case PoiSortBasicType.HOTEL_DEFAULT:
        sortName = HotelSortName.DEFAULT;
        break;
      case PoiSortBasicType.HOTEL_PRICE:
        sortName = HotelSortName.HOTEL_PRICE;
        break;
      case PoiSortBasicType.HOTEL_DISTANCE:
        sortName = HotelSortName.HOTEL_DISTANCE;
        break;
      case PoiSortBasicType.HOTEL_TOTAL_SCORE:
        sortName = HotelSortName.HOTEL_TOTAL_SCORE;
        break;
      case PoiSortBasicType.HOTEL_LEVEL:
        sortName = HotelSortName.HOTEL_LEVEL;
        break;
      case PoiSortBasicType.HOTEL_HEALTH_SCORE:
        sortName = HotelSortName.HOTEL_HEALTH_SCORE;
        break;
      case PoiSortBasicType.CATER_DEFAULT:
        sortName = CaterSortName.DEFAULT;
        break;
      case PoiSortBasicType.CATER_PRICE:
        sortName = CaterSortName.CATER_PRICE;
        break;
      case PoiSortBasicType.CATER_DISTANCE:
        sortName = CaterSortName.CATER_DISTANCE;
        break;
      case PoiSortBasicType.CATER_TASTE_RATING:
        sortName = CaterSortName.CATER_TASTE_RATING;
        break;
      case PoiSortBasicType.CATER_OVERALL_RATING:
        sortName = CaterSortName.CATER_OVERALL_RATING;
        break;
      case PoiSortBasicType.CATER_SERVICE_RATING:
        sortName = CaterSortName.CATER_SERVICE_RATING;
        break;
      case PoiSortBasicType.LIFE_DEFAULT:
        sortName = LifeSortName.DEFAULT;
        break;
      case PoiSortBasicType.LIFE_PRICE:
        sortName = LifeSortName.PRICE;
        break;
      case PoiSortBasicType.LIFE_DISTANCE:
        sortName = LifeSortName.DISTANCE;
        break;
      case PoiSortBasicType.LIFE_OVERALL_RATING:
        sortName = LifeSortName.LIFE_OVERALL_RATING;
        break;
      case PoiSortBasicType.LIFE_COMMENT_NUMBER:
        sortName = LifeSortName.LIFE_COMMENT_RATING;
        break;
      default:
        break;
    }
    return sortName;
  }

  getPoiFilter(optionMap: Map<string, AnyValue>): Nullable<PoiFilter> {
    if (this.call) {
      let filterMap = toMap(optionMap.get('filter'))
      if (filterMap) {
        let filter = new PoiFilter()
        if (isBoolean(filterMap.get('isGroupon'))) {
          filter.groupOn = Boolean(filterMap.get('isGroupon')) ? '1' : '0'
        }
        if (isBoolean(filterMap.get('isDiscount'))) {
          filter.discount = Boolean(filterMap.get('isDiscount')) ? '1' : '0'
        }
        if (isNumber(filterMap.get('sortRule'))) {
          filter.sortRule = Number(filterMap.get('sortRule')).toString()
        }
        if (isNumber(filterMap.get('industryType'))) {
          let industryType = this.getIndustryType(Number(filterMap.get('industryType')))
          if (industryType) {
            filter.industryType = industryType
          }
        }
        if (isNumber(filterMap.get('sortBasis'))) {
          let sortName = this.getSortName(Number(filterMap.get('sortBasis')))
          if (sortName) {
            filter.sortName = sortName
          }
        }
        return filter
      }
    }
    return;
  }
}
