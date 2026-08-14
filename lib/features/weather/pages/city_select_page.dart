// 城市选择页 - 对齐 Android AddCityActivity.kt + ac_add_city.xml
// 单选模式:选择城市后替换当前城市并返回
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../models/citys.dart';
import '../viewmodels/city_select_state.dart';
import '../viewmodels/city_select_view_model.dart';
import 'widgets/city_item.dart';

class CitySelectPage extends ConsumerStatefulWidget {
  const CitySelectPage({super.key});

  @override
  ConsumerState<CitySelectPage> createState() => _CitySelectPageState();
}

class _CitySelectPageState extends ConsumerState<CitySelectPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 选择城市 - 对齐 AddCityActivity.saveAndJump 单选分支
  Future<void> _onCitySelected(Citys city) async {
    final success =
        await ref.read(addCityViewModelProvider.notifier).selectCity(city);
    if (success && mounted) {
      // 返回 true 通知首页刷新
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addCityViewModelProvider);

    return Scaffold(
      // 蓝色背景 - 对齐 ac_add_city.xml #3F5BDF
      backgroundColor: AppColors.addCityBg,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部搜索栏 - marginTop 20dp
            _buildSearchBar(),
            // 下方内容区
            Expanded(
              child: state.isSearching
                  ? _buildSearchResults(state.searchResults)
                  : _buildHotCities(state),
            ),
          ],
        ),
      ),
    );
  }

  /// 搜索栏 - 对齐 ac_add_city.xml 顶部 RelativeLayout
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          // 搜索框 - marginStart 16, marginEnd 55(给取消按钮留空间)
          Expanded(
            child: Container(
              height: 40,
              margin: const EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                // 半透明白背景 + 圆角 20 - 对齐 shape_search_bg.xml
                color: AppColors.searchBoxBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // 搜索图标 16dp - 对齐 marginLeft 34(相对父),搜索框 marginLeft 16
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Image.asset(
                      AppAssets.icSearch,
                      width: 16,
                      height: 16,
                    ),
                  ),
                  // 输入框 - paddingStart 40(对齐原版),距图标约 6dp
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: '请输入城市或地区',
                        hintStyle:
                            TextStyle(color: Colors.white, fontSize: 16),
                        contentPadding: EdgeInsets.only(left: 6),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      // maxLength: 20,
                      // IME_ACTION_SEARCH - 对齐 et_search.imeOptions
                      textInputAction: TextInputAction.search,
                      onSubmitted: (keyword) {
                        ref
                            .read(addCityViewModelProvider.notifier)
                            .search(keyword);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // "取消"按钮 - alignParentRight, marginRight 16
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.only(right: 16, left: 8),
              alignment: Alignment.center,
              child: const Text(
                '取消',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 热门城市网格 - 对齐 ac_add_city.xml ll_history + rv_hot_city
  /// GridLayoutManager spanCount=4
  Widget _buildHotCities(AddCityState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (state.hotCities.isEmpty) {
      return const Center(
        child: Text(
          '请稍后再查询',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题"城市" - marginLeft 10, marginBottom 8, 白字 16sp
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 8),
            child: Text(
              '城市',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 对齐 spanCount=4
                childAspectRatio: 2.2, // 适配热门城市项宽高比
              ),
              itemCount: state.hotCities.length,
              itemBuilder: (context, index) {
                final city = state.hotCities[index];
                return HotCityItem(
                  city: city,
                  onTap: () => _onCitySelected(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 搜索结果列表 - 对齐 ac_add_city.xml rv_search(白底,默认 gone)
  Widget _buildSearchResults(List<Citys> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          '抱歉未找到当前城市',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      );
    }
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final city = results[index];
          return SearchCityItem(
            city: city,
            onTap: () => _onCitySelected(city),
          );
        },
      ),
    );
  }
}
