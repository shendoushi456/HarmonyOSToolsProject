import { SearchMethod } from '../Constants';
import FlutterDataConvert, { isBoolean, isNumber, toMap } from '../FlutterDataConvert';
import BaseHandler from './BaseHandler';
import {
  GeoCodeOption,
  GeoCoder,
  GeoCodeResult,
  ReverseGeoCodeOption,
  ReverseGeoCodeOptionParams,
  ReverseGeoCodeResult
} from '@bdmap/search';
import { isString } from '../../search/FlutterDataConvert';
import NativeDataConvert from '../NativeDataConvert';

export default class GeoCodeSearchHandler extends BaseHandler {
  search: GeoCoder | null = null

  handleMethod(): void {
    if (this.search == null) {
      this.search = GeoCoder.newInstance()
    }
    switch (this.method) {
      case SearchMethod.GEO_CODE_SEARCH:
        this.searchGeocode()
        break
      case SearchMethod.REVERSE_GEO_CODE_SEARCH:
        this.searchReverseGeocode()
        break
      default:
        this.sendReturnResult(false)
        break
    }
  }

  searchGeocode() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('geoCodeSearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let city = optionMap.get('city');
        let address = optionMap.get('address');
        if (isString(address)) {
          let option: GeoCodeOption = new GeoCodeOption(isString(city) ? String(city) : '', String(address))
          this.search.geocode(option).then((result: GeoCodeResult) => {
            this.callback(SearchMethod.GEO_CODE_SEARCH, Object(NativeDataConvert.GeoCodeResultToMap(result, id)),
              this.getErrorCode(result?.error))
          })
          this.sendReturnResult(true)
          return
        }
      }
    }
    this.sendReturnResult(false)
  }

  searchReverseGeocode() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('reverseGeoCodeSearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let locationMap = toMap(optionMap.get('location'));
        let isLatestAdmin = optionMap.get('isLatestAdmin');
        let radius = optionMap.get('radius');
        let pageSize = optionMap.get('pageSize');
        let pageNum = optionMap.get('pageNum');
        if (locationMap) {
          let location = FlutterDataConvert.mapToLatLng(locationMap)
          if (location) {
            let optionParams: ReverseGeoCodeOptionParams = {
              location: location
            }
            if (isBoolean(isLatestAdmin)) {
              optionParams.latestAdmin = Boolean(isLatestAdmin) ? 1 : 0
            }
            if (isNumber(radius)) {
              optionParams.radius = Number(radius)
            }
            if (isNumber(pageSize)) {
              optionParams.pageSize = Number(pageSize)
            }
            if (isNumber(pageNum)) {
              optionParams.pageNum = Number(pageNum)
            }
            let option: ReverseGeoCodeOption = new ReverseGeoCodeOption(optionParams)
            this.search.reverseGeoCode(option).then((result: ReverseGeoCodeResult) => {
              this.callback(SearchMethod.REVERSE_GEO_CODE_SEARCH,
                Object(NativeDataConvert.ReverseGeoCodeResultToMap(result, id)),
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

  clean(): void {
    if (this.search) {
      this.search.destroy()
    }
  }
}