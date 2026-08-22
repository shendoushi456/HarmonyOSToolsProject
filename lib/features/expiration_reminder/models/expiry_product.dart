import 'package:flutter/foundation.dart';

@immutable
class ExpiryProduct {
  final int id;
  final String name;
  final DateTime productionDate;
  final DateTime expiryDate;
  final int reminderDaysBefore;
  final String reminderOption;
  final int createdAt;
  final int updatedAt;
  final bool isActive;

  const ExpiryProduct({
    required this.id,
    required this.name,
    required this.productionDate,
    required this.expiryDate,
    this.reminderDaysBefore = 0,
    this.reminderOption = '不提醒',
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  ExpiryProduct copyWith({
    String? name,
    DateTime? productionDate,
    DateTime? expiryDate,
    int? reminderDaysBefore,
    String? reminderOption,
    int? updatedAt,
    bool? isActive,
  }) =>
      ExpiryProduct(
        id: id,
        name: name ?? this.name,
        productionDate: productionDate ?? this.productionDate,
        expiryDate: expiryDate ?? this.expiryDate,
        reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
        reminderOption: reminderOption ?? this.reminderOption,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'productionDate': _dateKey(productionDate),
        'expiryDate': _dateKey(expiryDate),
        'reminderDaysBefore': reminderDaysBefore,
        'reminderOption': reminderOption,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'isActive': isActive,
      };

  factory ExpiryProduct.fromJson(Map<String, dynamic> json) => ExpiryProduct(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '',
        productionDate:
            DateTime.tryParse(json['productionDate']?.toString() ?? '') ??
                DateTime.now(),
        expiryDate: DateTime.tryParse(json['expiryDate']?.toString() ?? '') ??
            DateTime.now(),
        reminderDaysBefore: (json['reminderDaysBefore'] as num?)?.toInt() ?? 0,
        reminderOption: json['reminderOption']?.toString() ?? '不提醒',
        createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
        updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
        isActive: json['isActive'] as bool? ?? true,
      );
}

DateTime expiryDateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);
String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
