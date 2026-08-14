// 城市选择项 Widget - 对齐 Android hot_city_item.xml + listitem_searching.xml
import 'package:flutter/material.dart';
import '../../models/citys.dart';

/// 热门城市项(网格布局) - 对齐 hot_city_item.xml
/// 透明背景 + 白色 1dp 边框 + 圆角 12dp,白字 12sp
class HotCityItem extends StatelessWidget {
  final Citys city;
  final VoidCallback onTap;

  const HotCityItem({super.key, required this.city, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 水平 margin 10dp,底部 margin 12dp - 对齐 hot_city_item.xml
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0)
          .copyWith(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            // 透明背景 + 白色 1dp 边框 + 圆角 12dp - 对齐 listitem_hot_city.xml
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            city.district,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// 搜索结果项(列表布局) - 对齐 listitem_searching.xml + SearchAdapter
/// 高 44dp,文字色 #7a7a7a 14sp,底部 1dp 分隔线
class SearchCityItem extends StatelessWidget {
  final Citys city;
  final VoidCallback onTap;

  const SearchCityItem({super.key, required this.city, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 44, // 对齐 listitem_searching.xml 高度
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              // 城市名 - marginLeft 20dp,垂直居中
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    city.district, // 只显示 district - 对齐 SearchAdapter 行 24
                    style: const TextStyle(
                      color: Color(0xFF7A7A7A),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              // 底部分隔线 1dp #DCDDE3,左右 margin 10dp
              Positioned(
                left: 10,
                right: 10,
                bottom: 0,
                child: Container(
                  height: 1,
                  color: const Color(0xFFDCDDE3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
