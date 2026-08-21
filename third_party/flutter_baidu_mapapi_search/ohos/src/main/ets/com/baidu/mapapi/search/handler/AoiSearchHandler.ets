import { SearchMethod } from '../Constants';
import { toMap } from '../FlutterDataConvert';
import BaseHandler from './BaseHandler';
import {
  AoiResult, AoiSearch, AoiSearchOption
} from '@bdmap/search';
import { isString } from '../../search/FlutterDataConvert';
import NativeDataConvert from '../NativeDataConvert';
import { LatLng } from '@bdmap/base';
import LogUtil from '../LogUtil';

export default class AoiSearchHandler extends BaseHandler {
  search: AoiSearch | null = null

  handleMethod(): void {
    if (this.search == null) {
      this.search = AoiSearch.newInstance()
    }
    switch (this.method) {
      case SearchMethod.AOI_SEARCH:
        this.searchAoi()
        break
      default:
        this.sendReturnResult(false)
        break
    }
  }

  searchAoi() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('AOISearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let locations = optionMap.get('locations');
        if (isString(locations)) {
          let locationArray = String(locations).split(';')
          if (locationArray) {
            let latLngList = new Array<LatLng>()
            locationArray.forEach(item => {
              if (item && item.includes(',')) {
                let itemArray = item.split(',')
                try {
                  let latLng = new LatLng(Number(itemArray[1]), Number(itemArray[0]))
                  latLngList.push(latLng)
                } catch (e) {
                  LogUtil.error(`经纬度转换异常,e=${e}`)
                }
              }
            })
            let option: AoiSearchOption = {
              latLngList: latLngList
            }
            this.search.requestAoi(option).then((result: AoiResult) => {
              this.callback(SearchMethod.AOI_SEARCH, Object(NativeDataConvert.AoiResultToMap(result, id)),
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