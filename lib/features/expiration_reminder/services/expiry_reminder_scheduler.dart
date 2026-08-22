import 'package:flutter/services.dart';

import '../models/expiry_product.dart';

abstract class ExpiryReminderScheduler {
  Future<void> schedule(ExpiryProduct product);
  Future<void> cancel(int productId);
  Future<void> restore(Iterable<ExpiryProduct> products);
}

class OhosExpiryReminderScheduler implements ExpiryReminderScheduler {
  const OhosExpiryReminderScheduler();
  static const _channel = MethodChannel('com.p.a_b/toolbox_reminder');

  @override
  Future<void> schedule(ExpiryProduct product) =>
      _channel.invokeMethod<void>('scheduleExpiry', {
        'id': product.id,
        'name': product.name,
        'expiryDate': product.expiryDate.millisecondsSinceEpoch,
        'reminderDaysBefore': product.reminderDaysBefore,
        'reminderOption': product.reminderOption,
      });

  @override
  Future<void> cancel(int productId) =>
      _channel.invokeMethod<void>('cancelExpiry', {'id': productId});

  @override
  Future<void> restore(Iterable<ExpiryProduct> products) async {
    for (final product in products) {
      if (product.isActive && product.reminderDaysBefore > 0) {
        await schedule(product);
      }
    }
  }
}
