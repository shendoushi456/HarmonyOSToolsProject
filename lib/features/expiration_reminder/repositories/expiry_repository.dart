import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/expiry_product.dart';

class ExpiryRepository {
  static const _storageKey = 'toolbox_expiration_reminder_v1';

  Future<List<ExpiryProduct>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return const [];
      final values = jsonDecode(raw) as List;
      return values
          .whereType<Map>()
          .map(
              (item) => ExpiryProduct.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<ExpiryProduct> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey,
        jsonEncode(products.map((item) => item.toJson()).toList()));
  }
}
