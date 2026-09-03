// Android CropCategoryActivity 的 Zyyt 版 UI：两列 160dp 作物卡片。
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../weather/models/weather_warning.dart';
import '../models/agriculture_catalog.dart';
import '../models/agriculture_models.dart';
import 'crop_record_editor_page.dart';
import 'crop_record_list_page.dart';

const _agriPageBackground = Color(0xFFE4F6FF);
const _agriText = Color(0xFF1E1E1E);

class CropCategoryPage extends StatelessWidget {
  final List<WeatherWarning> warnings;
  const CropCategoryPage({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _agriPageBackground,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            _Header(
              title: '农作物列表选择',
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Image.asset(AppAssets.zyytBack, width: 27, height: 27),
              ),
              trailing: IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CropRecordListPage(warnings: warnings))),
                icon: Image.asset(AppAssets.agricultureZyytCategoryList,
                    width: 24, height: 24),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                itemCount: agricultureCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 15,
                  mainAxisExtent: 160,
                ),
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

class _Header extends StatelessWidget {
  final String title;
  final Widget leading;
  final Widget trailing;
  const _Header(
      {required this.title, required this.leading, required this.trailing});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 72,
        child: Stack(children: [
          Center(
              child: Text(title,
                  style: const TextStyle(
                      color: _agriText,
                      fontSize: 23,
                      fontWeight: FontWeight.w500))),
          Positioned(
              left: 8,
              top: 12,
              child: SizedBox(width: 48, height: 48, child: leading)),
          Positioned(
              right: 8,
              top: 12,
              child: SizedBox(width: 48, height: 48, child: trailing)),
        ]),
      );
}

class _CategoryCard extends StatelessWidget {
  final CropCategory category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final copy = _copy(category.id);
    return Material(
      color: const Color(0xFFF1FAFF),
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          child: Column(children: [
            Image.asset(category.iconAsset, width: 82, height: 82),
            Text(copy.title,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _agriText,
                    fontSize: category.id == 'oil_field' ? 15 : 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(copy.subtitle,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF242424), fontSize: 11)),
          ]),
        ),
      ),
    );
  }

  _CategoryCopy _copy(String id) =>
      {
        'grain': const _CategoryCopy('粮食作物', '(小麦、水稻、玉米、大豆)'),
        'fruit_vegetable': const _CategoryCopy('果蔬经济作物', '(果树、露天蔬菜、瓜果)'),
        'greenhouse': const _CategoryCopy('大棚设施产业', '(大棚蔬菜、花卉、育苗)'),
        'forest': const _CategoryCopy('林果林木', '(果树、苗木、山林经济作物)'),
        'oil_field': const _CategoryCopy('油料、经济大田作物', '(花生、油菜、棉花)'),
      }[id] ??
      _CategoryCopy(category.title, '');
}

class _CategoryCopy {
  final String title;
  final String subtitle;
  const _CategoryCopy(this.title, this.subtitle);
}
