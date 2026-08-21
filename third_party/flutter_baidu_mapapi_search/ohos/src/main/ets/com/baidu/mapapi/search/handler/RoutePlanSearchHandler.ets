import { RoutePlanMethod } from '../Constants';
import FlutterDataConvert, { isNumber, toMap } from '../FlutterDataConvert';
import BaseHandler from './BaseHandler';
import {
  BikingRoutePlanOption,
  BikingRouteResult,
  DrivingPolicy,
  DrivingRoutePlanOption,
  DrivingRouteResult,
  DrivingTrafficPolicy,
  MassTransitRoutePlanOption,
  MassTransitRouteResult,
  PlanNode,
  RidingType,
  RoadPrefer,
  RoutePlanSearch,
  TacticsInCity,
  TacticsIntercity,
  TransitPolicy,
  TransitRoutePlanOption,
  TransitRouteResult,
  TransTypeIntercity,
  WalkingRoutePlanOption,
  WalkingRouteResult
} from '@bdmap/search';
import { isString } from '../../search/FlutterDataConvert';
import LogUtil from '../LogUtil';
import NativeDataConvert from '../NativeDataConvert';
import { List } from '@kit.ArkTS';

export default class RoutePlanSearchHandler extends BaseHandler {
  search: RoutePlanSearch | null = null

  handleMethod(): void {
    if (this.search == null) {
      this.search = RoutePlanSearch.newInstance()
    }
    switch (this.method) {
      case RoutePlanMethod.TRANSIT_ROUTE_SEARCH:
        this.transitPlan()
        break
      case RoutePlanMethod.MASS_TRANSIT_ROUTE_SEARCH:
        this.massTransitPlan()
        break
      case RoutePlanMethod.DRIVING_ROUTE_SEARCH:
        this.drivingPlan()
        break
      case RoutePlanMethod.RIDING_ROUTE_SEARCH:
        this.ridingPlan()
        break
      case RoutePlanMethod.WALKING_ROUTE_SEARCH:
        this.walkingPlan()
        break
      case RoutePlanMethod.INDOOR_ROUTE_SEARCH:
        this.sendReturnResult(false)
        break
      default:
        this.sendReturnResult(false)
        break
    }
  }

  massTransitPlan() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('massTransitRoutePlanOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let startMap = toMap(optionMap.get('from'))
        let endMap = toMap(optionMap.get('to'))
        if (startMap && endMap) {
          let startNode = FlutterDataConvert.mapToPlanNode(startMap)
          let endNode = FlutterDataConvert.mapToPlanNode(endMap)
          if (startNode && endNode) {
            let option: MassTransitRoutePlanOption = {
              from: startNode,
              to: endNode
            }
            let pageCapacity = optionMap.get('pageCapacity');
            let pageIndex = optionMap.get('pageIndex');
            let inCityPolicyObj = optionMap.get('incityPolicy');
            let intercityPolicyObj = optionMap.get('intercityPolicy');
            let intercityTransPolicyObj = optionMap.get('intercityTransPolicy');

            if (isNumber(pageCapacity)) {
              option.pageSize = Number(pageCapacity)
            }
            if (isNumber(pageIndex)) {
              option.pageIndex = Number(pageIndex)
            }

            if (isNumber(inCityPolicyObj)) {
              let inCityPolicy = Number(inCityPolicyObj)
              if (inCityPolicy == 0) {
                option.tacticsInCity = TacticsInCity.ETRANS_SUGGEST
              } else if (inCityPolicy == 1) {
                option.tacticsInCity = TacticsInCity.ETRANS_LEAST_TRANSFER
              } else if (inCityPolicy == 2) {
                option.tacticsInCity = TacticsInCity.ETRANS_LEAST_WALK
              } else if (inCityPolicy == 3) {
                option.tacticsInCity = TacticsInCity.ETRANS_NO_SUBWAY
              } else if (inCityPolicy == 4) {
                option.tacticsInCity = TacticsInCity.ETRANS_LEAST_TIME
              } else if (inCityPolicy == 5) {
                option.tacticsInCity = TacticsInCity.ETRANS_SUBWAY_FIRST
              }
            }

            if (isNumber(intercityPolicyObj)) {
              let intercityPolicy = Number(intercityPolicyObj)
              if (intercityPolicy == 0) {
                option.tacticsIntercity = TacticsIntercity.ETRANS_LEAST_TIME
              } else if (intercityPolicy == 1) {
                option.tacticsIntercity = TacticsIntercity.ETRANS_START_EARLY
              } else if (intercityPolicy == 2) {
                option.tacticsIntercity = TacticsIntercity.ETRANS_LEAST_PRICE
              }
            }

            if (isNumber(intercityTransPolicyObj)) {
              let intercityTransPolicy = Number(intercityTransPolicyObj)
              if (intercityTransPolicy == 0) {
                option.transTypeIntercity = TransTypeIntercity.ETRANS_TRAIN_FIRST
              } else if (intercityTransPolicy == 1) {
                option.transTypeIntercity = TransTypeIntercity.ETRANS_PLANE_FIRST
              } else if (intercityTransPolicy == 2) {
                option.transTypeIntercity = TransTypeIntercity.ETRANS_COACH_FIRST
              }
            }

            this.search.masstransitSearch(option)
              .then((result: MassTransitRouteResult) => {
                this.callback(RoutePlanMethod.MASS_TRANSIT_ROUTE_SEARCH,
                  Object(NativeDataConvert.massTransitRouteResultToMap(result, id)),
                  this.getErrorCode(result?.error))
              })
              .catch((err: Error) => {
                LogUtil.error('massTransitSearch error:' + JSON.stringify(err))
              })
            this.sendReturnResult(true)
            return
          }
        }
      }
    }
    this.sendReturnResult(false)
  }

  transitPlan() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('transitRoutePlanOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let startMap = toMap(optionMap.get('from'))
        let endMap = toMap(optionMap.get('to'))
        if (startMap && endMap) {
          let startNode = FlutterDataConvert.mapToPlanNode(startMap)
          let endNode = FlutterDataConvert.mapToPlanNode(endMap)
          if (startNode && endNode) {
            let option: TransitRoutePlanOption = {
              from: startNode,
              to: endNode
            }
            let city = optionMap.get('city');
            let transitPolicy = optionMap.get('transitPolicy');
            if (isString(city)) {
              option.cityName = String(city)
            }
            if (isNumber(transitPolicy)) {
              let policy = Number(transitPolicy)
              if (policy == 0) {
                option.policy = TransitPolicy.EBUS_TIME_FIRST
              } else if (policy == 1) {
                option.policy = TransitPolicy.EBUS_TRANSFER_FIRST
              } else if (policy == 2) {
                option.policy = TransitPolicy.EBUS_WALK_FIRST
              } else {
                option.policy = TransitPolicy.EBUS_NO_SUBWAY
              }
            }
            this.search.transitSearch(option)
              .then((result: TransitRouteResult) => {
                this.callback(RoutePlanMethod.TRANSIT_ROUTE_SEARCH,
                  Object(NativeDataConvert.TransitRouteResultToMap(result, id)),
                  this.getErrorCode(result?.error))
              })
              .catch((err: Error) => {
                LogUtil.error('transitSearch error:' + JSON.stringify(err))
              })
            this.sendReturnResult(true)
            return
          }
        }
      }
    }
    this.sendReturnResult(false)
  }

  drivingPlan() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('drivingRoutePlanOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let startMap = toMap(optionMap.get('from'))
        let endMap = toMap(optionMap.get('to'))
        if (startMap && endMap) {
          let startNode = FlutterDataConvert.mapToPlanNode(startMap)
          let endNode = FlutterDataConvert.mapToPlanNode(endMap)
          if (startNode && endNode) {
            let option: DrivingRoutePlanOption = {
              mFrom: startNode,
              mTo: endNode
            }
            let wayPointArrayObj = optionMap.get('wayPointsArray')
            if (wayPointArrayObj instanceof Array) {
              let wayPointList = new List<PlanNode>()
              let wayPointArray = wayPointArrayObj as Array<Map<string, object>>
              wayPointArray.forEach(wayPointMap => {
                let wayPoint = FlutterDataConvert.mapToPlanNode(wayPointMap)
                if (wayPoint) {
                  wayPointList.add(wayPoint)
                }
              })
              option.mWayPoints = wayPointList.convertToArray()
            }

            let drivingPolicyObj = optionMap.get('drivingPolicy');
            if (isNumber(drivingPolicyObj)) {
              let drivingPolicy = Number(drivingPolicyObj)
              if (drivingPolicy == 0) {
                option.mPolicy = DrivingPolicy.ECAR_AVOID_JAM
              } else if (drivingPolicy == 1) {
                option.mPolicy = DrivingPolicy.ECAR_TIME_FIRST
              } else if (drivingPolicy == 2) {
                option.mPolicy = DrivingPolicy.ECAR_DIS_FIRST
              } else if (drivingPolicy == 3) {
                option.mPolicy = DrivingPolicy.ECAR_FEE_FIRST
              }
            }
            let drivingRequestTrafficTypeObj = optionMap.get('drivingRequestTrafficType');
            if (isNumber(drivingRequestTrafficTypeObj)) {
              let drivingRequestTrafficType = Number(drivingRequestTrafficTypeObj)
              if (drivingRequestTrafficType == 0) {
                option.mtrafficPolicy = DrivingTrafficPolicy.ROUTE_PATH
              } else if (drivingRequestTrafficType == 1) {
                option.mtrafficPolicy = DrivingTrafficPolicy.ROUTE_PATH_AND_TRAFFIC
              }
            }

            this.search.drivingSearch(option)
              .then((result: DrivingRouteResult) => {
                this.callback(RoutePlanMethod.DRIVING_ROUTE_SEARCH,
                  Object(NativeDataConvert.drivingRouteResultToMap(result, id)),
                  this.getErrorCode(result?.error))
              })
              .catch((err: Error) => {
                LogUtil.error('drivingSearch error:' + JSON.stringify(err))
              })
            this.sendReturnResult(true)
            return
          }
        }
      }
    }
    this.sendReturnResult(false)
  }

  ridingPlan() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('ridingRoutePlanOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let startMap = toMap(optionMap.get('from'))
        let endMap = toMap(optionMap.get('to'))
        if (startMap && endMap) {
          let startNode = FlutterDataConvert.mapToPlanNode(startMap)
          let endNode = FlutterDataConvert.mapToPlanNode(endMap)
          if (startNode && endNode) {
            let option: BikingRoutePlanOption = {
              from: startNode,
              to: endNode
            }
            let wayPointArrayObj = optionMap.get('wayPointsArray')
            if (wayPointArrayObj instanceof Array) {
              let wayPointList = new List<PlanNode>()
              let wayPointArray = wayPointArrayObj as Array<Map<string, object>>
              wayPointArray.forEach(wayPointMap => {
                let wayPoint = FlutterDataConvert.mapToPlanNode(wayPointMap)
                if (wayPoint) {
                  wayPointList.add(wayPoint)
                }
              })
              option.wayPoints = wayPointList.convertToArray()
            }
            let ridingTypeObj = optionMap.get('ridingType');
            if (isNumber(ridingTypeObj)) {
              let ridingType = Number(ridingTypeObj)
              if (ridingType == 0) {
                // 普通骑行
                option.ridingType = RidingType.NORMAL
              } else if (ridingType == 1) {
                // 电动车骑行
                option.ridingType = RidingType.E_BIKE
              }
            }
            let roadPreferObj = optionMap.get('roadPrefer');
            if (isNumber(roadPreferObj)) {
              let roadPrefer = Number(roadPreferObj)
              if (roadPrefer == 0) {
                // 智能推荐
                option.roadPrefer = RoadPrefer.RECOMMEND
              } else if (roadPrefer == 2) {
                // 规避逆行
                option.roadPrefer = RoadPrefer.AVOID_RETROGRADE
              }
            }
            this.search.bikingSearch(option)
              .then((result: BikingRouteResult) => {
                this.callback(RoutePlanMethod.RIDING_ROUTE_SEARCH,
                  Object(NativeDataConvert.bikingRouteResultToMap(result, id)),
                  this.getErrorCode(result?.error))
              })
              .catch((err: Error) => {
                LogUtil.error('ridingSearch error:' + JSON.stringify(err))
              })
            this.sendReturnResult(true)
            return
          }
        }
      }
    }
    this.sendReturnResult(false)
  }

  walkingPlan() {
    if (this.call && this.search) {
      let optionMap = toMap(this.call.argument('walkingRoutePlanOption'))
      if (optionMap) {
        let id = optionMap.get('id');
        let startMap = toMap(optionMap.get('from'))
        let endMap = toMap(optionMap.get('to'))
        if (startMap && endMap) {
          let startNode = FlutterDataConvert.mapToPlanNode(startMap)
          let endNode = FlutterDataConvert.mapToPlanNode(endMap)
          if (startNode && endNode) {
            let option: WalkingRoutePlanOption = {
              from: startNode,
              to: endNode
            }

            this.search.walkingSearch(option)
              .then((result: WalkingRouteResult) => {
                this.callback(RoutePlanMethod.WALKING_ROUTE_SEARCH,
                  Object(NativeDataConvert.walkingRouteResultToMap(result, id)),
                  this.getErrorCode(result?.error))
              })
              .catch((err: Error) => {
                LogUtil.error('walkingSearch error:' + JSON.stringify(err))
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