// 公交线路换乘详情 ViewModel - 对齐 Android bus/viewmodel/BusRouteLineDetailViewModel.kt
// 根据起终点规划公交换乘路线，展示路线步骤
//
// 鸿蒙端差异：
// - Android: ViewModel + MutableStateFlow → Flutter: Riverpod Notifier + State
// - Android: viewModelScope.launch → Flutter: Future.microtask / async
// - Android: repository.planBusTransferRouteByAddress / planBusTransferRoute 返回 Result<List>
// - 鸿蒙端: BusTransferRepository 对应方法返回 Future<Result<List>>
import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bus_transfer_data.dart';
import '../repositories/bus_transfer_repository.dart';

/// 公交线路换乘详情 ViewModel - 对齐 Android BusRouteLineDetailViewModel
class BusRouteLineDetailViewModel
    extends Notifier<BusTransferUiState> {
  /// 公交换乘 Repository（对齐 Android repository = BusTransferRepository(context)）
  late final BusTransferRepository _repository;

  /// 当前起点（对齐 Android currentStartPoint: String）
  String _currentStartPoint = '';
  String _currentEndPoint = '';
  String _currentCity = '北京';

  @override
  BusTransferUiState build() {
    _repository = BusTransferRepository();
    return const BusTransferUiState();
  }

  /// 根据起终点地址规划换乘路线 - 对齐 Android planTransferRoute(startAddress, endAddress, city)
  Future<void> planTransferRouteByAddress({
    required String startAddress,
    required String endAddress,
    String city = '北京',
  }) async {
    _currentStartPoint = startAddress;
    _currentEndPoint = endAddress;
    _currentCity = city;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 对齐 Android: repository.planBusTransferRouteByAddress(...)
      final result = await _repository.planBusTransferRouteByAddress(
        startAddress: startAddress,
        endAddress: endAddress,
        city: city,
      );

      _applyTransferResult(result, failureFallback: '规划路线失败');
    } catch (e, stackTrace) {
      debugPrint('BusRouteLineDetailViewModel: planTransferRouteByAddress 异常: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: '规划路线失败: $e',
      );
    }
  }

  /// 根据起终点坐标规划换乘路线 - 对齐 Android planTransferRoute(startPoint, endPoint, startName, endName, city)
  Future<void> planTransferRouteByCoordinates({
    required BMFCoordinate startPoint,
    required BMFCoordinate endPoint,
    String startName = '起点',
    String endName = '终点',
    String city = '北京',
  }) async {
    _currentStartPoint = startName;
    _currentEndPoint = endName;
    _currentCity = city;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 对齐 Android: repository.planBusTransferRoute(...)
      final result = await _repository.planBusTransferRoute(
        startPoint: startPoint,
        endPoint: endPoint,
        startName: startName,
        endName: endName,
        city: city,
      );

      _applyTransferResult(result, failureFallback: '规划路线失败');
    } catch (e, stackTrace) {
      debugPrint('BusRouteLineDetailViewModel: planTransferRouteByCoordinates 异常: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: '规划路线失败: $e',
      );
    }
  }

  /// 重新规划路线 - 对齐 Android replanRoute
  Future<void> replanRoute() async {
    if (_currentStartPoint.isEmpty || _currentEndPoint.isEmpty) {
      return;
    }
    // 对齐 Android: planTransferRoute(currentStartPoint, currentEndPoint, currentCity)
    // 这里按地址重算（保持与 Android 一致的行为）
    await planTransferRouteByAddress(
      startAddress: _currentStartPoint,
      endAddress: _currentEndPoint,
      city: _currentCity,
    );
  }

  /// 设置公交路线数据 - 对齐 Android setBusRouteData(transitRouteLines, transitRouteResult)
  ///
  /// 鸿蒙端差异：Android transitRouteResult 参数保留以对齐签名，鸿蒙端同样未使用其内部数据
  Future<void> setBusRouteData(
    List<BMFTransitRouteLine> transitRouteLines, {
    BMFTransitRouteResult? transitRouteResult,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 对齐 Android: repository.processBusRouteData(transitRouteLines, transitRouteResult)
      final result = _repository.processBusRouteData(
        transitRouteLines,
        transitRouteResult: transitRouteResult,
      );

      _applyTransferResult(result, failureFallback: '处理路线数据失败');
    } catch (e, stackTrace) {
      debugPrint('BusRouteLineDetailViewModel: setBusRouteData 异常: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: '处理路线数据失败: $e',
      );
    }
  }

  /// 清除错误状态 - 对齐 Android clearError
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// 应用换乘路线结果（内部工具方法）
  ///
  /// 对齐 Android result.fold(onSuccess = {...}, onFailure = {...}) 的统一逻辑
  void _applyTransferResult(
    Result<List<BusTransferRoute>> result, {
    required String failureFallback,
  }) {
    if (result.isSuccess) {
      // 对齐 Android: transferRoutes.takeIf { it.isNotEmpty() }
      // 注：getOrNull() 返回非空 T，故直接判断 isNotEmpty
      final transferRoutes = result.getOrNull();
      if (transferRoutes.isNotEmpty) {
        // 对齐 Android: 取第一个推荐路线
        final bestRoute = transferRoutes.first;
        state = state.copyWith(
          isLoading: false,
          transferRoute: bestRoute,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '未找到换乘路线',
        );
      }
    } else {
      final error = result.exceptionOrNull();
      // 鸿蒙端差异：Dart Exception 基类无 message getter，用 toString() 兜底
      // 对齐 Android: error.message ?: failureFallback
      final errorText = error != null ? error.toString() : failureFallback;
      state = state.copyWith(
        isLoading: false,
        error: errorText,
      );
    }
  }
}

/// 公交线路换乘详情 ViewModel Provider
final busRouteLineDetailViewModelProvider =
    NotifierProvider<BusRouteLineDetailViewModel, BusTransferUiState>(
  BusRouteLineDetailViewModel.new,
);
