使用中文回复以及注释

使用下面的组件和版本：
组件	                 版本
Flutter	                flutter_ohos 3.27.4（2026-07-28，对应 Dart 3.6.2）
Dart	                3.6.2
DevEco/HarmonyOS SDK	6.1.1 / API 24
工程结构	             flutter_ohos 标准结构（鸿蒙工程在 ohos/ 子目录，根目录为 Flutter 工程）；melos 6.3.1 暂未启用
状态管理	             flutter_riverpod 2.3.7 + riverpod_annotation 2.1.2 + riverpod_generator 2.2.0
路由	                go_router 7.1.1
图表	                fl_chart 0.55.2（暂未启用）
日历	                table_calendar 3.0.8（暂未启用）
国际化	                官方 gen_l10n + flutter_localizations + intl 0.19.0（flutter_localizations 3.27.4 强制要求 ≥0.19.0）
存储	                path_provider 2.1.0(ohos) + shared_preferences 2.1.0(ohos)（暂未启用）
字体渲染	            flutter_svg 2.0.5
Lint	               very_good_analysis 4.0.0
Golden	               alchemist 0.6.1
引擎	                Skia；Impeller 已鸿蒙化但该分支未启用