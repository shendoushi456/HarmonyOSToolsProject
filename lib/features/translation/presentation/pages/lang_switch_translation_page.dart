import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/core/theme/app_colors.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/providers/translation_provider.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/states/lang_switch_ui_state.dart';

/// 语言选择页类型常量（保真原 `TYPE_SOURCE` / `TYPE_TARGET`）
const int _typeSource = 0;
const int _typeTarget = 1;

/// 语言切换翻译页面
///
/// 对应原 Android `LangSwitchTranslationActivity`，保真还原：
/// 顶部蓝色栏（返回 + 源/目标 Tab + 交换）+ 搜索栏 + 语言列表（含 TTS 麦克风图标）。
class LangSwitchTranslationPage extends ConsumerStatefulWidget {
  const LangSwitchTranslationPage({super.key, required this.selectionType});

  final int selectionType;

  @override
  ConsumerState<LangSwitchTranslationPage> createState() =>
      _LangSwitchTranslationPageState();
}

class _LangSwitchTranslationPageState
    extends ConsumerState<LangSwitchTranslationPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(langSwitchNotifierProvider.notifier)
          .setSelectionType(widget.selectionType);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onLanguageSelected(String language) async {
    await ref.read(langSwitchNotifierProvider.notifier).selectLanguage(language);
    if (mounted) {
      final selectionType = ref.read(langSwitchNotifierProvider).selectionType;
      context.pop(<String, dynamic>{
        'selectedLanguage': language,
        'selectionType': selectionType,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(langSwitchNotifierProvider);
    final notifier = ref.read(langSwitchNotifierProvider.notifier);
    final filteredLanguages = notifier.getFilteredLanguages();
    final selectedLanguage = notifier.getSelectedLanguage();

    return Scaffold(
      backgroundColor: AppColors.langSwitchBackground,
      body: Column(
        children: [
          _buildTopBar(uiState, notifier),
          const SizedBox(height: 20),
          _buildSearchBar(uiState, notifier),
          const SizedBox(height: 32),
          Expanded(child: _buildLanguageList(filteredLanguages, selectedLanguage)),
        ],
      ),
    );
  }

  /// 顶部语言选项卡栏
  Widget _buildTopBar(
      LangSwitchUiState uiState, LangSwitchNotifier notifier) {
    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 80,
          child: Stack(
            children: [
              // 返回按钮
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              // 源/目标 Tab + 交换
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.languageSelectorBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => notifier.setSelectionType(_typeSource),
                        child: Text(
                          uiState.fromLanguage,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.langSwitchText,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: notifier.swapLanguages,
                          child: Image.asset(
                            'assets/images/ic_trans_switch.png',
                            width: 13,
                            height: 13,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => notifier.setSelectionType(_typeTarget),
                        child: Text(
                          uiState.toLanguage,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.langSwitchText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 搜索栏
  Widget _buildSearchBar(
      LangSwitchUiState uiState, LangSwitchNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.search, color: AppColors.searchText, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.searchText,
                ),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: '输入语言名称',
                  hintStyle: TextStyle(fontSize: 15, color: AppColors.searchHint),
                ),
                onChanged: notifier.updateSearchQuery,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 46,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.langSwitchPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: const Center(
                  child: Text(
                    '搜索',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 语言列表
  Widget _buildLanguageList(List<String> languages, String selectedLanguage) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        final language = languages[index];
        final isSelected = language == selectedLanguage;
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _LanguageItem(
            language: language,
            isSelected: isSelected,
            onTap: () => _onLanguageSelected(language),
          ),
        );
      },
    );
  }
}

/// 语言列表项
class _LanguageItem extends StatelessWidget {
  const _LanguageItem({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                language,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.langSwitchPrimary
                      : AppColors.langSwitchUnselected,
                ),
              ),
            ],
          ),
          if (isSelected)
            Image.asset(
              'assets/images/ic_trans_confirm.png',
              width: 12,
              height: 12,
              fit: BoxFit.fitWidth,
            ),
        ],
      ),
    );
  }
}
