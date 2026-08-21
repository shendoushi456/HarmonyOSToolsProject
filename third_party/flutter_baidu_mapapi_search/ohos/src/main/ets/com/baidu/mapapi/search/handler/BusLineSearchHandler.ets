import { SearchMethod } from '../Constants';
import { toMap } from '../FlutterDataConvert';
import BaseHandler from './BaseHandler';
import {
  BusLineResult, BusLineSearch, BusLineSearchOption
} from '@bdmap/search';
import { isString } from '../../search/FlutterDataConvert';
import NativeDataConvert from '../NativeDataConvert';

export default class BusLineSearchHandler extends BaseHandler {
  search: BusLineSearch | null = null

  handleMethod(): void {
    if (this.search == null) {
      this.search = BusLineSearch.newInstance()
    }
    switch (this.method) {
      case SearchMethod.BUS_LINE_SEARCH:
        this.searchBusLine()
        break
      default:
        this.sendReturnResult(false)
        break
    }
  }

  searchBusLine() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('busLineSearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let city = optionMap.get('city');
        let busLineUid = optionMap.get('busLineUid');
        // let startUid = optionMap.get('startUid');
        // let endUid = optionMap.get('endUid');
        if (isString(city) && isString(busLineUid)) {
          let option: BusLineSearchOption = {
            uid: String(busLineUid),
            city: String(city)
          }
          this.search.searchBusLine(option).then((result: BusLineResult) => {
            this.callback(SearchMethod.BUS_LINE_SEARCH, Object(NativeDataConvert.BusLineResultToMap(result, id)),
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