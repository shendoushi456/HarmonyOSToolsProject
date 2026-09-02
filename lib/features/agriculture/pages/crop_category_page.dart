// 对齐 Android CropCategoryActivity：类别选择 → 添加页，顶部入口 → 统一记录列表。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/standard_page_header.dart';
import '../../weather/models/weather_warning.dart';
import '../models/agriculture_catalog.dart';
import '../models/agriculture_models.dart';
import 'crop_record_list_page.dart';
import 'crop_record_editor_page.dart';

const _agricultureBackground = Color(0xFF0A0D0E);

class CropCategoryPage extends ConsumerWidget {
  final List<WeatherWarning> warnings;

  const CropCategoryPage({super.key, required this.warnings});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        backgroundColor: _agricultureBackground,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            StandardPageHeader(
              title: '农作物类别选择',
              leading: IconButton(
                  tooltip: '返回',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Image.asset(AppAssets.agricultureBack,
                      width: 28, height: 28)),
              trailing: IconButton(
                tooltip: '农作物记录列表',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CropRecordListPage(warnings: warnings))),
                icon: Image.asset(AppAssets.agricultureCategoryList,
                    width: 27, height: 27),
              ),
            ),
            const SizedBox(height: 37),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                itemCount: agricultureCategories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, index) => _CategoryCard(
                  category: agricultureCategories[index],
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CropRecordEditorPage(
                      category: agricultureCategories[index],
                      warnings: warnings,
                    ),
                  )),
                ),
              ),
            ),
          ]),
        ),
      );
}

class _CategoryCard extends StatelessWidget {
  final CropCategory category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 76,
          child: Stack(children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 54,
                padding: const EdgeInsets.only(left: 102, right: 8),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .3),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 4)
                  ],
                ),
                child: Text(category.selectionText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
            Positioned(
              left: 20,
              top: 0,
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black)),
                child: ClipOval(
                    child: Image.asset(category.iconAsset, fit: BoxFit.cover)),
              ),
            ),
          ]),
        ),
      );
}
