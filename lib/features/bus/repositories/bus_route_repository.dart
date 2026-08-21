// 公交路线数据仓库 - 对齐 Android bus/repository/BusRouteRepository.kt
// 含 POI 搜索 + 公交线路搜索 + 定时搜索
//
// 鸿蒙端差异：
// - Android: PoiSearch.newInstance() / BusLineSearch.newInstance() 同步回调
// - 鸿蒙端: BMFPoiCitySearch / BMFBusLineSearch 异步回调 + Completer 包装为 Future
// - Android: CoroutineScope + Mutex + Job 用于定时搜索
// - 鸿蒙端: Timer.periodic + bool 标志位（Dart 单线程模型无需 Mutex）
// - Android: SearchResult.ERRORNO 判断错误
// - 鸿蒙端: BMFSearchErrorCode 枚举判断错误
// - Android: setOnGetPoiSearchResultListener 单监听器复用
// - 鸿蒙端: 每次搜索创建新实例避免回调冲突
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';

import '../models/baidu_extensions.dart';
import '../models/bus_route_data.dart';

/// 公交路线数据仓库 - 对齐 Android BusRouteRepository
class BusRouteRepository {
  BusRouteRepository();

  /// 定时搜索定时器（对齐 Android timerJob: Job?）
  Timer? _timerJob;

  /// 是否正在执行搜索请求（对齐 Android requestMutex.withLock 语义）
  bool _searchInProgress = false;

  /// 缓存最新搜索结果（对齐 Android @Volatile latestBusLineResult）
  BusRouteDetail? _latestBusLineResult;

  /// 根据路线名称搜索公交线路详情 - 对齐 Android searchBusRoute
  ///
  /// [routeName] 路线名称
  /// [city] 城市，默认"北京"
  Future<Result<List<BusRouteDetail>>> searchBusRoute(
    String routeName, {
    String city = '北京',
  }) async {
    final completer = Completer<Result<List<BusRouteDetail>>>();
    try {
      final allRouteDetails = <BusRouteDetail>[];

      // 对齐 Android: poiSearch?.setOnGetPoiSearchResultListener(...)
      // 鸿蒙端: 每次创建新实例避免回调冲突
      final poiSearch = BMFPoiCitySearch();
      poiSearch.onGetPoiCitySearchResult(
        callback: (result, errorCode) async {
          // 对齐 Android: result?.error == SearchResult.ERRORNO.NO_ERROR
          if (errorCode == BMFSearchErrorCode.NO_ERROR) {
            final pois = result.poiInfoList;
            if (pois == null || pois.isEmpty) {
              // 对齐 Android: 搜索结果为空
              if (!completer.isCompleted) {
                completer.complete(Result.failure(Exception('搜索结果为空')));
              }
              return;
            }

            // 对齐 Android: filter { poi.name.contains(routeName) || poi.name.contains("路") }
            final busLinePois = pois.where((poi) {
              final name = poi.name ?? '';
              return name.contains(routeName) || name.contains('路');
            }).toList();

            if (busLinePois.isEmpty) {
              if (!completer.isCompleted) {
                completer.complete(Result.failure(Exception('未找到相关公交线路')));
              }
              return;
            }

            // 对齐 Android: 遍历所有匹配 POI 获取详情
            for (final poi in busLinePois) {
              final detail = await _searchBusLineDetail(poi.uid ?? '', city);
              if (detail != null) {
                allRouteDetails.add(detail);
              }
            }

            // 处理完所有线路（对齐 Android: if (allRouteDetails.size == busLinePois.size)）
            if (!completer.isCompleted) {
              if (allRouteDetails.isEmpty) {
                completer.complete(Result.failure(Exception('未找到相关公交线路详情')));
              } else {
                completer.complete(Result.success(allRouteDetails));
              }
            }
          } else {
            if (!completer.isCompleted) {
              completer.complete(Result.failure(Exception('搜索失败: $errorCode')));
            }
          }
        },
      );

      // 对齐 Android: PoiCitySearchOption().city(city).keyword(routeName).pageNum(0).pageCapacity(20)
      final option = BMFPoiCitySearchOption(
        keyword: routeName,
        city: city,
        pageIndex: 0,
        pageSize: 20,
      );

      // 对齐 Android: poiSearch?.searchInCity(option)
      final ok = await poiSearch.poiCitySearch(option);
      if (!ok) {
        if (!completer.isCompleted) {
          completer.complete(Result.failure(Exception('POI 搜索请求失败')));
        }
      }
    } catch (e, stackTrace) {
      debugPrint('BusRouteRepository.searchBusRoute 异常: $e\n$stackTrace');
      if (!completer.isCompleted) {
        completer.complete(Result.failure(e is Exception ? e : Exception('$e')));
      }
    }
    return completer.future;
  }

  /// 搜索公交线路详情 - 对齐 Android searchBusLineDetail
  ///
  /// 注：Android 原代码注释提到百度地图 SDK 不支持通过 UID 直接搜索线路详情，
  /// 暂时跳过详情获取并回调 null。鸿蒙端保持相同行为以对齐原项目（迁移保真原则）。
  Future<BusRouteDetail?> _searchBusLineDetail(String uid, String city) async {
    try {
      // 参数验证（对齐 Android）
      if (uid.isBlank) {
        debugPrint('BusRouteRepository: UID为空，无法查询公交线路详情');
        return null;
      }

      // 对齐 Android: busLineSearch?.setOnGetBusLineSearchResultListener(...)
      // 对齐 Android 注释: 百度地图SDK不支持通过UID直接搜索线路详情，暂时跳过
      // 鸿蒙端保持相同行为
      debugPrint('BusRouteRepository: 百度地图SDK不支持通过UID搜索线路详情，跳过: $uid');
      return null;
    } catch (e, stackTrace) {
      debugPrint('BusRouteRepository: 搜索公交线路详情异常: $e\n$stackTrace');
      return null;
    }
  }

  /// 根据公交线路 ID 获取详细信息 - 对齐 Android getBusRouteDetail
  Future<Result<BusRouteDetail>> getBusRouteDetail(
    String routeId, {
    String city = '北京',
  }) async {
    // 对齐 Android: 百度地图SDK需要线路名称进行搜索，不支持直接通过ID搜索
    // 由于百度SDK的限制，暂时返回失败结果
    debugPrint('BusRouteRepository: 百度地图SDK不支持通过路线ID搜索，返回失败结果: $routeId');
    return Result.failure(Exception('百度地图SDK不支持通过路线ID进行搜索'));
  }

  /// 根据线路名称查询公交线路详细方向信息 - 对齐 Android getBusLineDirection
  /// 直接使用线路名称进行百度地图线路搜索
  Future<Result<String>> getBusLineDirection(
    String lineName,
    String city,
  ) async {
    final completer = Completer<Result<String>>();

    try {
      // 参数验证（对齐 Android）
      if (lineName.isBlank || city.isBlank) {
        return Result.failure(Exception('线路名称和城市参数不能为空'));
      }

      debugPrint('BusRouteRepository: 开始通过POI搜索获取线路: $lineName, 城市: $city');

      // 对齐 Android: 先通过 POI 搜索找到公交线路，再用 UID 获取详情
      final poiSearch = BMFPoiCitySearch();
      poiSearch.onGetPoiCitySearchResult(
        callback: (poiResult, poiErrorCode) async {
          if (poiErrorCode != BMFSearchErrorCode.NO_ERROR) {
            if (!completer.isCompleted) {
              completer.complete(Result.failure(Exception('POI搜索失败: $poiErrorCode')));
            }
            return;
          }

          final pois = poiResult.poiInfoList;
          if (pois == null || pois.isEmpty) {
            if (!completer.isCompleted) {
              completer.complete(Result.failure(Exception('POI搜索返回空结果')));
            }
            return;
          }

          // 对齐 Android: 寻找最匹配的公交线路POI
          final matchingPois = pois.where((poi) {
            final poiName = poi.name ?? '';
            // 对齐 Android 匹配逻辑
            return poiName.contains(lineName) ||
                poiName.toLowerCase() == lineName.toLowerCase() ||
                (lineName.contains('路') &&
                    poiName.contains(lineName.substring(0, lineName.length - 1)));
          }).toList();

          if (matchingPois.isEmpty) {
            if (!completer.isCompleted) {
              completer.complete(Result.failure(Exception('未找到线路 $lineName 的POI信息')));
            }
            return;
          }

          // 对齐 Android: 选择最佳匹配的POI
          final bestMatch = _selectBestMatch(matchingPois, lineName);
          final bestUid = bestMatch.uid ?? '';

          debugPrint('BusRouteRepository: 找到匹配POI: ${bestMatch.name}, UID: $bestUid');

          if (bestUid.isBlank) {
            if (!completer.isCompleted) {
              completer.complete(Result.failure(Exception('找到的线路POI缺少UID信息')));
            }
            return;
          }

          // 对齐 Android: 使用找到的POI UID进行公交线路详情搜索
          // 启动定时搜索并等待首次结果
          await _startPeriodicBusLineSearch(
            BMFBusLineSearchOption(busLineUid: bestUid, city: city),
            bestUid,
            completer,
          );
        },
      );

      // 对齐 Android: PoiCitySearchOption().city(city).keyword(lineName).pageNum(0).pageCapacity(20)
      final poiSearchOption = BMFPoiCitySearchOption(
        keyword: lineName,
        city: city,
        pageIndex: 0,
        pageSize: 20,
      );

      final ok = await poiSearch.poiCitySearch(poiSearchOption);
      if (!ok) {
        if (!completer.isCompleted) {
          completer.complete(Result.failure(Exception('POI 搜索请求失败')));
        }
      }
    } catch (e, stackTrace) {
      debugPrint('BusRouteRepository: 查询线路方向异常: $e\n$stackTrace');
      if (!completer.isCompleted) {
        completer.complete(Result.failure(Exception('查询线路方向时发生异常: $e')));
      }
    }
    return completer.future;
  }

  /// 选择最佳匹配的 POI - 对齐 Android bestMatch = matchingPois.minByOrNull { ... }
  BMFPoiInfo _selectBestMatch(List<BMFPoiInfo> matchingPois, String lineName) {
    int scoreOf(BMFPoiInfo poi) {
      final poiName = poi.name ?? '';
      // 对齐 Android: 相似度评分，0=完全匹配，1=包含，2=被包含，3=其他
      if (poiName.toLowerCase() == lineName.toLowerCase()) return 0;
      if (poiName.contains(lineName)) return 1;
      if (lineName.contains(poiName)) return 2;
      return 3;
    }

    matchingPois.sort((a, b) => scoreOf(a).compareTo(scoreOf(b)));
    return matchingPois.first;
  }

  /// 启动每隔1秒的定时搜索 - 对齐 Android startPeriodicBusLineSearch
  ///
  /// 鸿蒙端差异：使用 Timer.periodic 替代 coroutineScope.launch + repeat
  /// 通过 Completer 等待首次结果（对齐 Android 继续流程的逻辑）
  Future<void> _startPeriodicBusLineSearch(
    BMFBusLineSearchOption busLineOption,
    String uid,
    Completer<Result<String>> completer,
  ) async {
    // 停止之前的定时任务（对齐 Android stopPeriodicSearch()）
    stopPeriodicSearch();

    // 对齐 Android: busLineSearch?.setOnGetBusLineSearchResultListener(...)
    final busLineSearch = BMFBusLineSearch();
    busLineSearch.onGetBuslineSearchResult(
      callback: (result, errorCode) {
        // 对齐 Android: 更新缓存的最新结果（在锁内执行）
        if (errorCode == BMFSearchErrorCode.NO_ERROR) {
          final detail = result.toBusRouteDetailBaidu();
          if (detail != null) {
            _latestBusLineResult = detail;
            debugPrint('BusRouteRepository: 更新缓存结果 - 线路: $uid');
          }
        }

        // 对齐 Android: 返回线路方向信息
        if (errorCode == BMFSearchErrorCode.NO_ERROR && !completer.isCompleted) {
          final detail = result.toBusRouteDetailBaidu();
          if (detail != null) {
            final direction = _generateDirectionFromDetail(detail);
            if (direction != null) {
              debugPrint('BusRouteRepository: 查询线路方向成功 - 方向: $direction');
              completer.complete(Result.success(direction));
            } else {
              completer.complete(Result.failure(Exception('线路详情中缺少方向信息')));
            }
          } else {
            completer.complete(Result.failure(Exception('无法解析线路详情信息')));
          }
        } else if (errorCode != BMFSearchErrorCode.NO_ERROR &&
            !completer.isCompleted) {
          completer.complete(Result.failure(Exception('线路搜索失败: $errorCode')));
        }
      },
    );

    // 对齐 Android: repeat(Int.MAX_VALUE) { requestMutex.withLock { ... }; delay(1000L) }
    var executionCount = 0;
    _timerJob = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        if (_searchInProgress) {
          // 对齐 Android requestMutex.withLock 语义：跳过本次
          return;
        }
        _searchInProgress = true;
        executionCount += 1;
        debugPrint('BusRouteRepository: 执行定时搜索 - UID: $uid, 执行次数: $executionCount');

        // 对齐 Android: busLineSearch?.searchBusLine(busLineOption)
        await busLineSearch.busLineSearch(busLineOption);
      } catch (e, stackTrace) {
        debugPrint('BusRouteRepository: 定时搜索异常: $e\n$stackTrace');
        // 对齐 Android: 出现异常时暂停一段时间再继续
      } finally {
        _searchInProgress = false;
      }
    });
  }

  /// 停止定时搜索 - 对齐 Android stopPeriodicSearch
  void stopPeriodicSearch() {
    _timerJob?.cancel();
    _timerJob = null;
    debugPrint('BusRouteRepository: 定时搜索已停止');
  }

  /// 获取最新的搜索结果（对齐 Android 线程安全）- 对齐 Android getLatestResult
  ///
  /// 鸿蒙端差异：Dart 单线程模型无需 Mutex
  Future<BusRouteDetail?> getLatestResult() async {
    return _latestBusLineResult;
  }

  /// 根据线路详情生成方向信息 - 对齐 Android generateDirectionFromDetail
  String? _generateDirectionFromDetail(BusRouteDetail detail) {
    try {
      // 对齐 Android: 从站点列表中提取起点和终点
      if (detail.stations.isNotEmpty) {
        final startStation = detail.stations.first.name;
        final endStation = detail.stations.last.name;

        if (startStation.isNotEmpty && endStation.isNotEmpty) {
          return '$startStation → $endStation';
        }
        return null;
      }
      return null;
    } catch (_) {
      // 对齐 Android: catch (_: Exception) { null }
      return null;
    }
  }

  /// 清理资源 - 对齐 Android destroy
  void destroy() {
    stopPeriodicSearch();
  }
}

/// 简单的字符串扩展（对齐 Kotlin String.isBlank()）
extension _StringExt on String {
  bool get isBlank => trim().isEmpty;
}

/// 简单的 Result 类型 - 对齐 Kotlin Result<T>
/// 鸿蒙端差异：Dart 没有内置 Result 类型，这里定义最小实现
class Result<T> {
  Result._({this.value, this.error});

  /// 成功结果
  factory Result.success(T value) => Result._(value: value);

  /// 失败结果
  factory Result.failure(Exception error) => Result._(error: error);

  final T? value;
  final Exception? error;

  /// 是否成功
  bool get isSuccess => error == null;

  /// 是否失败
  bool get isFailure => error != null;

  /// 获取值（失败时抛出异常）
  T getOrNull() => value as T;

  /// 获取错误（成功时返回 null）
  Exception? exceptionOrNull() => error;
}
