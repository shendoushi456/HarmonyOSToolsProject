import { ShareUrlMethod } from '../Constants';
import FlutterDataConvert, { isNumber, toMap } from '../FlutterDataConvert';
import BaseHandler from './BaseHandler';
import { RouteShareURLOption, ShareUrlResult, ShareUrlSearch } from '@bdmap/search';
import { isString } from '../../search/FlutterDataConvert';

export default class ShareUrlHandler extends BaseHandler {
  search: ShareUrlSearch | null = null

  handleMethod(): void {
    if (this.search == null) {
      this.search = ShareUrlSearch.newInstance()
    }
    switch (this.method) {
      case ShareUrlMethod.PoiDetailShareUrl:
        this.poiShare()
        break
      case ShareUrlMethod.LocationShareUrl:
        this.locationShare()
        break
      case ShareUrlMethod.RoutePlanShareUrl:
        this.routePlanShare()
        break
      default:
        this.sendReturnResult(false)
        break
    }
  }

  poiShare() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('poiDetailShareURLOption'))
      if (optionMap) {
        let id = optionMap.get('id') as string
        let uid = optionMap.get('uid') as string
        if (isString(id) && isString(uid)) {
          this.search.requestPoiDetailShareUrl({ uid: uid }).then((result: ShareUrlResult) => {
            this.callback(ShareUrlMethod.PoiDetailShareUrl, Object(new Map().set('id', id).set('url', result.url)),
              this.getErrorCode(result?.error))
          })
          this.sendReturnResult(true)
          return
        }
      }
    }
    this.sendReturnResult(false)
  }

  locationShare() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('reverseGeoShareURLOption'))
      if (optionMap) {
        let id = optionMap.get('id') as string
        let location = FlutterDataConvert.mapToLatLng(toMap(optionMap.get('location')))
        if (isString(id) && location) {
          let name = optionMap.get('name') as string
          let snippet = optionMap.get('snippet') as string
          this.search.requestLocationShareUrl({
            location: location,
            name: isString(name) ? name : '',
            snippet: isString(snippet) ? snippet : '',
          }).then((result: ShareUrlResult) => {
            this.callback(ShareUrlMethod.LocationShareUrl, Object(new Map().set('id', id).set('url', result.url)),
              this.getErrorCode(result?.error))
          })
          this.sendReturnResult(true)
          return
        }
      }
    }
    this.sendReturnResult(false)
  }

  routePlanShare() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('routePlanShareURLOption'))
      if (optionMap) {
        let id = optionMap.get('id') as string
        let from = FlutterDataConvert.mapToPlanNode(toMap(optionMap.get('from')))
        let to = FlutterDataConvert.mapToPlanNode(toMap(optionMap.get('to')))
        let routePlanType = optionMap.get('routePlanType') as number
        let cityID = optionMap.get('cityID') as number
        let routeIndex = optionMap.get('routeIndex') as number
        if (isString(id) && from && to) {
          const option: RouteShareURLOption = {
            from: from,
            to: to,
            pn: isNumber(routeIndex) ? routeIndex : 0,
            cityCode: isNumber(cityID) ? cityID : 0,
            routeShareMode: isNumber(routePlanType) ? routePlanType : 0
          }
          this.search.requestRouteShareUrl(option).then((result: ShareUrlResult) => {
            this.callback(ShareUrlMethod.RoutePlanShareUrl, Object(new Map().set('id', id).set('url', result.url)),
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