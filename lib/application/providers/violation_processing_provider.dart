import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/violation_processing_repository.dart';
import '../../domain/models/violation_processing_item.dart';

/// 违章处理仓库 provider
final violationProcessingRepositoryProvider =
    Provider<ViolationProcessingRepository>((ref) {
  return ViolationProcessingRepository();
});

/// 全部违章处理项列表
final violationProcessingListProvider =
    Provider<List<ViolationProcessingItem>>((ref) {
  return ref.watch(violationProcessingRepositoryProvider).getAll();
});
