import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expiry_product.dart';
import '../repositories/expiry_repository.dart';
import '../services/expiry_reminder_scheduler.dart';
import 'expiry_state.dart';

final expiryRepositoryProvider =
    Provider<ExpiryRepository>((ref) => ExpiryRepository());
final expiryReminderSchedulerProvider = Provider<ExpiryReminderScheduler>(
    (ref) => const OhosExpiryReminderScheduler());
final expiryViewModelProvider =
    NotifierProvider<ExpiryViewModel, ExpiryState>(ExpiryViewModel.new);

class ExpiryViewModel extends Notifier<ExpiryState> {
  late final ExpiryRepository _repository;
  late final ExpiryReminderScheduler _scheduler;

  @override
  ExpiryState build() {
    _repository = ref.read(expiryRepositoryProvider);
    _scheduler = ref.read(expiryReminderSchedulerProvider);
    Future.microtask(_load);
    return ExpiryState.initial();
  }

  Future<void> _load() async {
    final products = await _repository.load();
    state = state.copyWith(loading: false, products: products);
    await _scheduler.restore(products);
  }

  void selectFilter(ExpiryFilter value) =>
      state = state.copyWith(filter: value);

  int remainingDays(ExpiryProduct product) => expiryDateOnly(product.expiryDate)
      .difference(expiryDateOnly(DateTime.now()))
      .inDays;
  List<ExpiryProduct> get activeProducts =>
      state.products.where((item) => item.isActive).toList()
        ..sort((left, right) => left.expiryDate.compareTo(right.expiryDate));
  List<ExpiryProduct> get filteredProducts {
    final products = activeProducts;
    return products.where((item) {
      final days = remainingDays(item);
      switch (state.filter) {
        case ExpiryFilter.valid:
          return days > 0;
        case ExpiryFilter.expired:
          return days <= 0;
        case ExpiryFilter.days30:
          return days >= 1 && days <= 30;
        case ExpiryFilter.days7:
          return days >= 1 && days <= 7;
        case ExpiryFilter.days3:
          return days >= 1 && days <= 3;
        case ExpiryFilter.day1:
          return days == 1;
        case ExpiryFilter.all:
          return true;
      }
    }).toList();
  }

  ExpiryStatistics get statistics {
    final products = activeProducts;
    return ExpiryStatistics(
        total: products.length,
        expired: products.where((item) => remainingDays(item) <= 0).length,
        days7: products.where((item) {
          final days = remainingDays(item);
          return days >= 1 && days <= 7;
        }).length,
        days30: products.where((item) {
          final days = remainingDays(item);
          return days >= 1 && days <= 30;
        }).length);
  }

  Future<void> saveProduct(
      {ExpiryProduct? original,
      required String name,
      required DateTime productionDate,
      required DateTime expiryDate,
      required int reminderDaysBefore,
      required String reminderOption}) async {
    if (name.trim().isEmpty ||
        !expiryDateOnly(expiryDate).isAfter(expiryDateOnly(productionDate))) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final product = original == null
        ? ExpiryProduct(
            id: now,
            name: name.trim(),
            productionDate: expiryDateOnly(productionDate),
            expiryDate: expiryDateOnly(expiryDate),
            reminderDaysBefore: reminderDaysBefore,
            reminderOption: reminderOption,
            createdAt: now,
            updatedAt: now)
        : original.copyWith(
            name: name.trim(),
            productionDate: expiryDateOnly(productionDate),
            expiryDate: expiryDateOnly(expiryDate),
            reminderDaysBefore: reminderDaysBefore,
            reminderOption: reminderOption,
            updatedAt: now);
    state = state.copyWith(
        products: original == null
            ? [product, ...state.products]
            : state.products
                .map((item) => item.id == product.id ? product : item)
                .toList());
    await _repository.save(state.products);
    await _scheduler.cancel(product.id);
    if (product.reminderDaysBefore > 0) {
      await _scheduler.schedule(product);
    }
  }

  Future<void> deleteProduct(ExpiryProduct product) async {
    state = state.copyWith(
        products:
            state.products.where((item) => item.id != product.id).toList());
    await _repository.save(state.products);
    await _scheduler.cancel(product.id);
  }
}

class ExpiryStatistics {
  final int total;
  final int expired;
  final int days7;
  final int days30;
  const ExpiryStatistics(
      {required this.total,
      required this.expired,
      required this.days7,
      required this.days30});
}
