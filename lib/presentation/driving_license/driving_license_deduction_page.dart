import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/providers/driving_license_provider.dart';
import '../theme/app_colors.dart';

/// 驾照扣分规则页
///
/// 对应 Android: toolCarLib/DrivingLicenseDeductionRulesActivity.kt
/// 5 个 Tab（记12/9/6/3/1分）+ 当前 Tab 对应的扣分规则内容。
class DrivingLicenseDeductionPage extends ConsumerWidget {
  const DrivingLicenseDeductionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(drivingLicenseTabProvider);
    final repo = ref.watch(drivingLicenseRepositoryProvider);
    final tabLabels = repo.tabList;
    return Scaffold(
      appBar: AppBar(title: const Text('驾照扣分规则')),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Tab 标签行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(tabLabels.length, (index) {
                final selected = index == tabIndex;
                return GestureDetector(
                  onTap: () =>
                      ref.read(drivingLicenseTabProvider.notifier).state = index,
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: selected ? 7 : 0,
                      vertical: 1,
                    ),
                    child: Text(
                      tabLabels[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: selected ? Colors.white : AppColors.tabUnselected,
                        fontWeight: FontWeight.w400,
                        height: 20 / 14,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            // 内容
            Expanded(
              child: ListView(
                children: [
                  Text(
                    '一次${tabLabels[tabIndex]}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF444444),
                      fontWeight: FontWeight.w500,
                      height: 22 / 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    repo.getContent(tabIndex),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5E5E5E),
                      height: 22 / 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
