import { SearchMethod } from '../Constants';
import { toMap } from '../FlutterDataConvert';
import BaseHandler from './BaseHandler';
import {
  DistrictResult, DistrictSearch, DistrictSearchOption
} from '@bdmap/search';
import { isString } from '../../search/FlutterDataConvert';
import NativeDataConvert from '../NativeDataConvert';

export default class DistrictSearchHandler extends BaseHandler {
  search: DistrictSearch | null = null

  handleMethod(): void {
    if (this.search == null) {
      this.search = DistrictSearch.newInstance()
    }
    switch (this.method) {
      case SearchMethod.DISTRICT_SEARCH:
        this.searchDistrict()
        break
      default:
        this.sendReturnResult(false)
        break
    }
  }

  searchDistrict() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('districtSearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let city = optionMap.get('city');
        let district = optionMap.get('district');
        if (isString(city)) {
          let option: DistrictSearchOption = {
            cityName: String(city),
            districtName: isString(district) ? String(district) : ''
          }
          this.search.searchDistrict(option).then((result: DistrictResult) => {
            this.callback(SearchMethod.DISTRICT_SEARCH, Object(NativeDataConvert.DistrictResultToMap(result, id)),
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