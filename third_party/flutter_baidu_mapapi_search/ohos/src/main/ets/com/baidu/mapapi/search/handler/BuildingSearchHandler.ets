import { SearchMethod } from '../Constants';
import FlutterDataConvert, { toMap } from '../FlutterDataConvert';
import BaseHandler from './BaseHandler';
import {
  BuildingResult, BuildingSearch, BuildingSearchOption
} from '@bdmap/search';
import NativeDataConvert from '../NativeDataConvert';

export default class BuildingSearchHandler extends BaseHandler {
  search: BuildingSearch | null = null

  handleMethod(): void {
    if (this.search == null) {
      this.search = BuildingSearch.newInstance()
    }
    switch (this.method) {
      case SearchMethod.BUILDING_SEARCH:
        this.searchBuilding()
        break
      default:
        this.sendReturnResult(false)
        break
    }
  }

  searchBuilding() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('buildingSearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let locationMap = toMap(optionMap.get('location'));
        if (locationMap) {
          let location = FlutterDataConvert.mapToLatLng(locationMap)
          if (location) {
            let option: BuildingSearchOption = {
              latlng: location
            }
            this.search.requestBuilding(option).then((result: BuildingResult) => {
              this.callback(SearchMethod.BUILDING_SEARCH, Object(NativeDataConvert.BuildingResultToMap(result, id)),
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