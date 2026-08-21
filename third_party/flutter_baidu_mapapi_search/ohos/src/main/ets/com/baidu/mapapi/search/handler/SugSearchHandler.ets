import { SearchMethod } from '../Constants';
import { isBoolean, toMap } from '../FlutterDataConvert';
import BaseHandler from './BaseHandler';
import { SuggestionResult, SuggestionSearch, SuggestionSearchOption } from '@bdmap/search';
import { isString } from '../../search/FlutterDataConvert';
import NativeDataConvert from '../NativeDataConvert';
import LogUtil from '../LogUtil';

export default class SugSearchHandler extends BaseHandler {
  search: SuggestionSearch | null = null

  handleMethod(): void {
    if (this.search == null) {
      this.search = SuggestionSearch.newInstance()
    }
    switch (this.method) {
      case SearchMethod.SUGGESTION_SEARCH:
        this.searchSug()
        break
      default:
        this.sendReturnResult(false)
        break
    }
  }

  searchSug() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('suggestionSearchOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let city = optionMap.get('cityname');
        let keyword = optionMap.get('keyword');
        if (isString(keyword)) {
          let option: SuggestionSearchOption = {
            city: city ? String(city) : null,
            keyword: String(keyword)
          }
          if (isBoolean(optionMap.get('cityLimit'))) {
            option.cityLimit = Boolean(optionMap.get('cityLimit'))
          }
          this.search.requestSuggestion(option).then((result: SuggestionResult) => {
            this.callback(SearchMethod.SUGGESTION_SEARCH, Object(NativeDataConvert.SuggestionResultToMap(result, id)),
              this.getErrorCode(result?.error))
          })
            .catch((err: Error) => {
              LogUtil.error('suggestionSearch error:' + JSON.stringify(err))
              this.callback(SearchMethod.SUGGESTION_SEARCH, Object(new Map().set('id', id)), this.getErrorCode())
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
