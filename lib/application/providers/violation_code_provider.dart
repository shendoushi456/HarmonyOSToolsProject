import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/violation_code_repository.dart';
import '../../domain/models/violation_code.dart';

/// 违章代码仓库 provider
final violationCodeRepositoryProvider = Provider<ViolationCodeRepository>((ref) {
  return ViolationCodeRepository();
});

/// 按代码查询违章结果（family：code 参数）
/// 对应 Android: SearchViolationCodeResultActivity 的 getViolationData(code)
final violationCodeResultProvider =
    Provider.family<ViolationCode?, String>((ref, code) {
  return ref.watch(violationCodeRepositoryProvider).findByCode(code);
});
