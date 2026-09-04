import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/privacy/presentation/pages/about_page.dart';
import 'features/privacy/presentation/pages/feed_back_page.dart';
import 'features/privacy/presentation/pages/policy_page.dart';
import 'features/privacy/presentation/pages/splash_page.dart';
import 'features/scan_menu/presentation/scan_menu_page.dart';
import 'features/scan_menu/presentation/widgets/placeholder_page.dart';
import 'features/translation/domain/english_result.dart';
import 'features/translation/presentation/pages/article_result_translation_page.dart';
import 'features/translation/presentation/pages/contrast_translation_page.dart';
import 'features/translation/presentation/pages/doc_translation_activity_page.dart';
import 'features/translation/presentation/pages/lang_switch_translation_page.dart';
import 'features/translation/presentation/pages/original_translation_page.dart';
import 'features/translation/presentation/pages/photo_translation_activity_page.dart';
import 'features/translation/presentation/pages/qr_generator_page.dart';
import 'features/translation/presentation/pages/qr_scanner_page.dart';
import 'features/translation/presentation/pages/text_detail_translation_page.dart';

/// 应用路由配置
///
/// 对应原 Android 各 Activity 的 Intent 跳转。
/// 使用 go_router 7.1.1，通过 extra 传递参数。
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: '/scan_menu',
      builder: (_, __) => const ScanMenuPage(),
    ),
    GoRoute(
      path: '/text_detail',
      builder: (_, state) {
        final extra =
            state.extra as Map<String, dynamic>? ?? <String, dynamic>{};
        return TextDetailTranslationPage(
          mode: extra['mode'] as int? ?? 0,
          sourceText: extra['sourceText'] as String? ?? '',
          translatedText: extra['translatedText'] as String? ?? '',
          sourceLanguage: extra['sourceLanguage'] as String? ?? '中文',
          targetLanguage: extra['targetLanguage'] as String? ?? '英语',
          singleText: extra['singleText'] as String? ?? '',
          title: extra['title'] as String? ?? '原文',
        );
      },
    ),
    GoRoute(
      path: '/lang_switch',
      builder: (_, state) {
        final extra =
            state.extra as Map<String, dynamic>? ?? <String, dynamic>{};
        return LangSwitchTranslationPage(
          selectionType: extra['selectionType'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/original',
      builder: (_, state) {
        final extra =
            state.extra as Map<String, dynamic>? ?? <String, dynamic>{};
        return OriginalTranslationPage(
          originalText: extra['originalText'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/doc_translation_activity',
      builder: (_, __) => const DocTranslationActivityPage(),
    ),
    GoRoute(
      path: '/article_result',
      builder: (_, state) {
        final result = state.extra as EnglishResult?;
        return ArticleResultTranslationPage(result: result);
      },
    ),
    GoRoute(
      path: '/placeholder',
      builder: (_, state) {
        final extra =
            state.extra as Map<String, dynamic>? ?? <String, dynamic>{};
        return PlaceholderPage(
          title: extra['title'] as String? ?? '占位页',
        );
      },
    ),
    GoRoute(
      path: '/photo_translation_activity',
      builder: (_, __) => const PhotoTranslationActivityPage(),
    ),
    GoRoute(
      path: '/contrast_translation',
      builder: (_, state) {
        final extra =
            state.extra as Map<String, dynamic>? ?? <String, dynamic>{};
        return ContrastTranslationPage(
          sourceText: extra['sourceText'] as String? ?? '',
          translatedText: extra['translatedText'] as String? ?? '',
          title: extra['title'] as String? ?? '文字提取',
        );
      },
    ),
    GoRoute(
      path: '/qr_scanner',
      builder: (_, __) => const QrScannerPage(),
    ),
    GoRoute(
      path: '/qr_generator',
      builder: (_, __) => const QrGeneratorPage(),
    ),
    GoRoute(
      path: '/policy',
      builder: (_, state) {
        final extra =
            state.extra as Map<String, dynamic>? ?? <String, dynamic>{};
        return PolicyPage(
          title: extra['title'] as String? ?? '隐私政策',
          url: extra['url'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/about',
      builder: (_, __) => const AboutPage(),
    ),
    GoRoute(
      path: '/feedback',
      builder: (_, __) => const FeedBackPage(),
    ),
  ],
);
