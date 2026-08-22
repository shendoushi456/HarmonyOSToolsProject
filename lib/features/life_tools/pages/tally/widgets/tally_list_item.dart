// 记账列表项 - 对齐 Android record_item_layout.xml
// 4 列横向(日期/类型/金额/说明)
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/tally_bean.dart';

class TallyListItem extends StatelessWidget {
  const TallyListItem({
    super.key,
    required this.tally,
    required this.onTap,
    required this.onLongPress,
  });

  final Tally tally;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            // 日期 weight 1.5
            Expanded(
              flex: 15,
              child: Text(
                tally.tallyTime,
                style: const TextStyle(fontSize: 16, color: AppColors.tallyHeaderText),
                textAlign: TextAlign.center,
              ),
            ),
            // 类型 weight 1
            Expanded(
              flex: 10,
              child: Text(
                tally.tallyType,
                style: TextStyle(
                  fontSize: 16,
                  color: tally.tallyType == '收入'
                      ? AppColors.wifiConnectGreen
                      : AppColors.expenseOrange,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // 金额 weight 1
            Expanded(
              flex: 10,
              child: Text(
                tally.tallyMoney.toStringAsFixed(2),
                style: const TextStyle(fontSize: 16, color: AppColors.tallyHeaderText),
                textAlign: TextAlign.center,
              ),
            ),
            // 说明 weight 1.5
            Expanded(
              flex: 15,
              child: Text(
                tally.tallyState,
                style: const TextStyle(fontSize: 16, color: AppColors.tallyHeaderText),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
