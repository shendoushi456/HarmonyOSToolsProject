import { SearchMethod } from '../Constants';
import FlutterDataConvert, { isBoolean, toMap } from '../FlutterDataConvert';
import BaseHandler from './BaseHandler';
import {
  RecommendStopResult, RecommendStopSearch, RecommendStopSearchOption
} from '@bdmap/search';
import NativeDataConvert from '../NativeDataConvert';
import LogUtil from '../LogUtil';

export default class RecommendStopSearchHandler extends BaseHandler {
  search: RecommendStopSearch | null = null

  handleMethod(): void {
    if (this.search == null) {
      this.search = RecommendStopSearch.newInstance()
    }
    switch (this.method) {
      case SearchMethod.RECOMMEND_STOP_SEARCH:
        this.searchRecommendStop()
        break
      default:
        this.sendReturnResult(false)
        break
    }
  }

  searchRecommendStop() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('recommendStopSearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let locationMap = toMap(optionMap.get('location'));
        if (locationMap) {
          let location = FlutterDataConvert.mapToLatLng(locationMap)
          if (location) {
            let option: RecommendStopSearchOption = {
              location: location
            }
            if (isBoolean(optionMap.get('isNeedStationInfo'))) {
              option.isNeedStationInfo = Boolean(optionMap.get('isNeedStationInfo'))
            }
            this.search.requestRecommendStop(option).then((result: RecommendStopResult) => {
              this.callback(SearchMethod.RECOMMEND_STOP_SEARCH,
                Object(NativeDataConvert.RecommendStopResultToMap(result, id)),
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