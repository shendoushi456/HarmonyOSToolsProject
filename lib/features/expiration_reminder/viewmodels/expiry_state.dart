import 'package:flutter/foundation.dart';

import '../models/expiry_product.dart';

enum ExpiryFilter { all, valid, expired, days30, days7, days3, day1 }

@immutable
class ExpiryState {
  final bool loading;
  final ExpiryFilter filter;
  final List<ExpiryProduct> products;

  const ExpiryState(
      {required this.loading, required this.filter, required this.products});
  factory ExpiryState.initial() =>
      const ExpiryState(loading: true, filter: ExpiryFilter.all, products: []);
  ExpiryState copyWith(
          {bool? loading,
          ExpiryFilter? filter,
          List<ExpiryProduct>? products}) =>
      ExpiryState(
          loading: loading ?? this.loading,
          filter: filter ?? this.filter,
          products: products ?? this.products);
}
