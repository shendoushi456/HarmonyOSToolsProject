import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/providers/search_car_info_provider.dart';
import '../../../domain/validators/license_plate_validator.dart';
import 'widgets/selection_item.dart';
import 'widgets/text_input_item.dart';

/// 违章查询页（SearchCarInfoFragment 第二个页面）
///
/// 对应 Android: SearchCarInfoFragment.kt
/// 4 个下拉/输入项 + 说明 + 立即查询按钮（跳转交管12123）。
class SearchCarInfoPage extends ConsumerWidget {
  const SearchCarInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsRepo = ref.watch(licensePlateOptionsProvider);
    final energyType = ref.watch(energyTypeSelectedProvider);
    final platePrefix = ref.watch(platePrefixSelectedProvider);
    final plateNumber = ref.watch(plateNumberSelectedProvider);
    final plateType = ref.watch(plateTypeSelectedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('违章查询')),
      body: ColoredBox(
        color: const Color(0xFFF8F8F8),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 选择卡片（4 项）
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  SelectionItem(
                    title: '能源类型',
                    selectedValue: energyType,
                    options: optionsRepo.getEnergyTypes(),
                    onValueChanged: (v) =>
                        ref.read(energyTypeSelectedProvider.notifier).state = v,
                  ),
                  const SizedBox(height: 20),
                  SelectionItem(
                    title: '车牌前缀',
                    selectedValue: platePrefix,
                    options: optionsRepo.getPlatePrefixes(),
                    onValueChanged: (v) =>
                        ref.read(platePrefixSelectedProvider.notifier).state = v,
                  ),
                  const SizedBox(height: 20),
                  TextInputItem(
                    title: '车牌号码',
                    placeholder: '请输入车牌号码',
                    inputValue: plateNumber,
                    onValueChanged: (v) =>
                        ref.read(plateNumberSelectedProvider.notifier).state = v,
                    errorMessage: LicensePlateValidator.errorMessage(plateNumber),
                  ),
                  const SizedBox(height: 20),
                  SelectionItem(
                    title: '车牌类型',
                    selectedValue: plateType,
                    options: optionsRepo.getPlateTypes(),
                    onValueChanged: (v) =>
                        ref.read(plateTypeSelectedProvider.notifier).state = v,
                  ),
                ],
              ),
            ),
            // 说明文字
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Text(
                '说明：以上信息仅供查询，我们将严格保密',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFF6B6B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // 立即查询按钮
            _QueryButton(onPressed: () => _onQuery(context, ref)),
          ],
        ),
      ),
    );
  }

  /// 立即查询：校验 + 跳转交管12123
  /// 对应 Android: SearchCarInfoFragment.kt:539-580 openTrafficManagement12123
  void _onQuery(BuildContext context, WidgetRef ref) {
    final energyType = ref.read(energyTypeSelectedProvider);
    final plateNumber = ref.read(plateNumberSelectedProvider);
    final platePrefix = ref.read(platePrefixSelectedProvider);
    final plateType = ref.read(plateTypeSelectedProvider);

    // 校验所有选项是否已选择
    if (energyType == '请选择' ||
        plateNumber.trim().isEmpty ||
        platePrefix == '请选择' ||
        plateType == '请选择') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先完成所有选项的选择'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 校验车牌号格式
    if (!LicensePlateValidator.isValid(plateNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入正确的车牌号格式'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 跳转交管12123
    ref.read(externalAppServiceProvider).openTrafficManagement12123();
  }
}

/// 查询按钮
/// 对应 Android: SearchCarInfoFragment.kt:498-536 QueryButton
class _QueryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _QueryButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF0FC093),
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.center,
        child: const Text(
          '立即查询',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
