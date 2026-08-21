import { SearchMethod } from '../Constants';
import FlutterDataConvert, { isNumber, toMap } from '../FlutterDataConvert';
import BaseHandler from './BaseHandler';
import {
  WeatherResult, WeatherSearch, WeatherSearchOption
} from '@bdmap/search';
import { isString } from '../../search/FlutterDataConvert';
import NativeDataConvert from '../NativeDataConvert';

export default class WeatherSearchHandler extends BaseHandler {
  search: WeatherSearch | null = null

  handleMethod(): void {
    if (this.search == null) {
      this.search = WeatherSearch.newInstance()
    }
    switch (this.method) {
      case SearchMethod.WEATHER_SEARCH:
        this.searchWeather()
        break
      default:
        this.sendReturnResult(false)
        break
    }
  }

  searchWeather() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('weatherSearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let districtID = optionMap.get('districtID');
        let locationMap = toMap(optionMap.get('location'));
        if (isString(districtID) || locationMap) {
          let option: WeatherSearchOption = {}
          if (isString(districtID)) {
            option.districtID = String(districtID)
          }
          if (locationMap) {
            option.location = FlutterDataConvert.mapToLatLng(locationMap)
          }
          if (isNumber(optionMap.get('serverType'))) {
            option.serverType = Number(optionMap.get('serverType'))
          }
          if (isNumber(optionMap.get('dataType'))) {
            option.dataType = Number(optionMap.get('dataType'))
          }
          if (isNumber(optionMap.get('languageType'))) {
            option.languageType = Number(optionMap.get('languageType'))
          }
          this.search.request(option).then((result: WeatherResult) => {
            this.callback(SearchMethod.WEATHER_SEARCH, Object(NativeDataConvert.WeatherResultToMap(result, id)),
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
}