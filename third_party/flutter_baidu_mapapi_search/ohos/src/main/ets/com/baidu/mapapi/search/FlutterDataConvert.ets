import { LatLng } from '@bdmap/base';
import { PlanNode } from '@bdmap/search';
import { List } from '@kit.ArkTS';
import { AnyValue } from './Constants';

export function isBoolean(key: AnyValue): boolean {
  return typeof (key) === 'boolean'
}

export function isNumber(value: AnyValue): boolean {
  return typeof (value) === 'number' && !Number.isNaN(Number(value))
}

export function isString(value: AnyValue): boolean {
  return typeof (value) === 'string' && String(value).length > 0
}

export function toMap(o: AnyValue | undefined): Map<string, AnyValue> | undefined {
  if (o instanceof Map) {
    return o as Map<string, object>
  }
  return
}

/**
 *  将flutter层参数转化为原生层参数对象
 */
export default class FlutterDataConvert {
  static mapToLatLng(argsMap: Map<string, AnyValue> | undefined): Nullable<LatLng> {
    if (argsMap && isNumber(argsMap.get('latitude')) && isNumber(argsMap.get('longitude'))) {
      return new LatLng(Number(argsMap.get('latitude')), Number(argsMap.get('longitude')))
    }
    return
  }


  static listToLatLng(argsList: List<Map<string, object>>): Nullable<Array<LatLng>> {
    if (argsList && argsList.length > 0) {
      let array = new Array<LatLng>()
      argsList.forEach((mapItem, index: number) => {
        if (mapItem) {
          let latLng: LatLng | undefined = FlutterDataConvert.mapToLatLng(mapItem)
          if (latLng) {
            array[index] = latLng
          }
        }
      })
      return array
    }
    return
  }

  static mapToPlanNode(argsMap: Map<string, AnyValue> | undefined): Nullable<PlanNode> {
    if (argsMap) {
      let cityName = argsMap.get('cityName')
      let cityID = argsMap.get('cityID')
      let name = argsMap.get('name')
      let uid = argsMap.get('uid')
      let ptMap = toMap(argsMap.get('pt'))
      if (ptMap) {
        let pt = FlutterDataConvert.mapToLatLng(ptMap)
        if (pt) {
          if (isString(uid) && String(uid).length > 0) {
            return PlanNode.withLocationAndPoiId(pt, String(uid))
          }
          return PlanNode.withLocation(pt)
        }
      }
      if (isString(name)) {

        if (isNumber(cityID)) {
          if (isString(uid) && String(uid).length > 0) {
            return PlanNode.withCityCodeAndPlaceNameAndPoiId(Number(cityID), String(name), String(uid))
          }
          return PlanNode.withCityCodeAndPlaceName(Number(cityID), String(name))
        }

        if (isString(uid) && String(uid).length > 0) {
          return PlanNode.withCityNameAndPlaceNameAndPoiId(String(cityName), String(name), String(uid))
        }
        return PlanNode.withCityNameAndPlaceName(String(cityName), String(name))

      }
    }
    return;
  }
}