const LOG_TAG = 'flutter_baidu_map'
const OPEN = true

export function printMap(paramsMap: Map<string, object | number> | undefined) {
  if (!paramsMap) {
    LogUtil.debug('paramsMap is undefined')
    return
  }
  let mapString = '';
  paramsMap.forEach((value, key) => {
    if (Object(value) instanceof Map) {
      printMap(value as Map<string, object>)
    } else {
      mapString = mapString + 'key=' + key + ', value=' + value + '\n'
    }
  })
  if (mapString) {
    LogUtil.debug(mapString)
  }
}

export default class LogUtil {
  static debug(msg: string) {
    if (OPEN) {
      console.debug(LOG_TAG, msg)
    }
  }

  static error(msg: string) {
    console.error(LOG_TAG, msg)
  }
}