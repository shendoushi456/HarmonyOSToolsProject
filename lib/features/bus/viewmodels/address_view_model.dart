// 地址管理 ViewModel - 对齐 Android bus/viewmodel/AddressViewmodel.kt
// 通过 AddressRepository 管理地址和交通方式数据
// 鸿蒙端差异：Android 用 AndroidViewModel + StateFlow，Flutter 用 Riverpod Notifier + State
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address_info.dart';
import '../repositories/address_repository.dart';

/// 地址管理 UI 状态 - 对齐 Android AddressViewmodel 暴露的多个 StateFlow
class AddressUiState {
  const AddressUiState({
    this.transportMode = TransportMode.publicTransport,
    this.companyAddress,
    this.homeAddress,
    this.schoolAddress,
  });

  /// 默认交通方式（对齐 Android transportMode: StateFlow<TransportMode>）
  final TransportMode transportMode;

  /// 公司地址（对齐 Android companyAddress: StateFlow<AddressInfo?>）
  final AddressInfo? companyAddress;

  /// 家庭地址（对齐 Android homeAddress: StateFlow<AddressInfo?>）
  final AddressInfo? homeAddress;

  /// 学校地址（对齐 Android schoolAddress: StateFlow<AddressInfo?>）
  final AddressInfo? schoolAddress;

  AddressUiState copyWith({
    TransportMode? transportMode,
    AddressInfo? companyAddress,
    AddressInfo? homeAddress,
    AddressInfo? schoolAddress,
  }) {
    return AddressUiState(
      transportMode: transportMode ?? this.transportMode,
      companyAddress: companyAddress ?? this.companyAddress,
      homeAddress: homeAddress ?? this.homeAddress,
      schoolAddress: schoolAddress ?? this.schoolAddress,
    );
  }
}

/// 地址管理 ViewModel - 对齐 Android AddressViewmodel
class AddressViewModel extends Notifier<AddressUiState> {
  /// 地址 Repository（对齐 Android addressRepository = AddressRepository.getInstance(application)）
  late final AddressRepository _addressRepository;

  @override
  AddressUiState build() {
    _addressRepository = AddressRepository.instance;
    // 对齐 Android init 中从 Repository 加载初始数据
    // 鸿蒙端 SharedPreferences 异步，初始返回默认状态，reload() 中异步加载
    final state = AddressUiState();
    // 异步加载持久化数据
    Future.microtask(() => reload());
    return state;
  }

  /// 设置通勤方式 - 对齐 Android setTransportMode
  Future<void> setTransportMode(TransportMode mode) async {
    await _addressRepository.saveDefaultTransportMode(mode);
    state = state.copyWith(transportMode: mode);
  }

  /// 设置地址 - 对齐 Android setAddress
  Future<void> setAddress(AddressType type, AddressInfo address) async {
    await _addressRepository.saveAddress(type, address);
    state = state.copyWith(
      companyAddress: type == AddressType.company ? address : state.companyAddress,
      homeAddress: type == AddressType.home ? address : state.homeAddress,
      schoolAddress: type == AddressType.school ? address : state.schoolAddress,
    );
  }

  /// 删除地址 - 对齐 Android deleteAddress
  Future<void> deleteAddress(AddressType type) async {
    await _addressRepository.deleteAddress(type);
    state = AddressUiState(
      transportMode: state.transportMode,
      companyAddress: type == AddressType.company ? null : state.companyAddress,
      homeAddress: type == AddressType.home ? null : state.homeAddress,
      schoolAddress: type == AddressType.school ? null : state.schoolAddress,
    );
  }

  /// 获取地址 - 对齐 Android getAddress
  AddressInfo? getAddress(AddressType type) {
    switch (type) {
      case AddressType.company:
        return state.companyAddress;
      case AddressType.home:
        return state.homeAddress;
      case AddressType.school:
        return state.schoolAddress;
    }
  }

  /// 重新从 Repository 加载所有数据 - 对齐 Android reload
  /// 用于页面返回时刷新数据
  Future<void> reload() async {
    final transportMode = await _addressRepository.getDefaultTransportMode();
    final companyAddress = await _addressRepository.getAddress(AddressType.company);
    final homeAddress = await _addressRepository.getAddress(AddressType.home);
    final schoolAddress = await _addressRepository.getAddress(AddressType.school);

    state = AddressUiState(
      transportMode: transportMode,
      companyAddress: companyAddress,
      homeAddress: homeAddress,
      schoolAddress: schoolAddress,
    );
  }
}

/// 地址管理 ViewModel Provider
final addressViewModelProvider =
    NotifierProvider<AddressViewModel, AddressUiState>(AddressViewModel.new);
