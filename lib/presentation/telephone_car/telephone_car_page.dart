import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/providers/search_car_info_provider.dart';
import '../../../application/providers/telephone_car_provider.dart';
import '../../../application/services/external_app_service.dart';
import '../../../domain/models/phone_info.dart';
import 'widgets/emergency_phone_card.dart';
import 'widgets/phone_list_item.dart';
import 'widgets/tab_button.dart';

/// 应急电话页（TelephoneCarFragment 第三个页面）
///
/// 对应 Android: TelephoneCarFragment.kt
/// 4 个紧急电话卡片 + Tab 切换（道路救援/保险公司）+ 电话列表，点击拨号。
class TelephoneCarPage extends ConsumerWidget {
  const TelephoneCarPage({super.key});

  // 4 个紧急电话数据（对应 EmergencyPhoneCards 213-248）
  static const _emergencyPhones = <(String, String, Color)>[
    ('110', '匪警电话', Color(0xFF4A90E2)),
    ('122', '事故电话', Color(0xFFE74C3C)),
    ('120', '急救电话', Color(0xFF2ECC71)),
    ('119', '火警电话', Color(0xFFE67E22)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(telephoneTabProvider);
    final repo = ref.watch(phoneRepositoryProvider);
    final phones =
        tabIndex == 0 ? repo.getRoadRescuePhones() : repo.getInsurancePhones();

    return Scaffold(
      appBar: AppBar(title: const Text('应急电话')),
      body: ColoredBox(
        color: const Color(0xFFF8F8F8),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: phones.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              // 紧急电话卡片组
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    for (var i = 0; i < _emergencyPhones.length; i++)
                      _EmergencyPhoneSlot(
                        phone: _emergencyPhones[i],
                        isLast: i == _emergencyPhones.length - 1,
                        onTap: () => ref
                            .read(externalAppServiceProvider)
                            .dialPhone(_emergencyPhones[i].$1),
                      ),
                  ],
                ),
              );
            }
            if (index == 1) {
              // Tab 切换
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    TelephoneTabButton(
                      text: '道路救援',
                      isSelected: tabIndex == 0,
                      onTap: () => ref
                          .read(telephoneTabProvider.notifier)
                          .state = 0,
                    ),
                    const SizedBox(width: 12),
                    TelephoneTabButton(
                      text: '保险公司',
                      isSelected: tabIndex == 1,
                      onTap: () => ref
                          .read(telephoneTabProvider.notifier)
                          .state = 1,
                    ),
                  ],
                ),
              );
            }
            // 电话列表项
            final phone = phones[index - 2];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PhoneListItem(
                title: phone.title,
                subtitle: phone.phone,
                onTap: () =>
                    ref.read(externalAppServiceProvider).dialPhone(phone.phone),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmergencyPhoneSlot extends StatelessWidget {
  final (String, String, Color) phone;
  final bool isLast;
  final VoidCallback onTap;

  const _EmergencyPhoneSlot({
    required this.phone,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: isLast ? 0 : 8),
        child: EmergencyPhoneCard(
          number: phone.$1,
          title: phone.$2,
          backgroundColor: phone.$3,
          onTap: onTap,
        ),
      ),
    );
  }
}
