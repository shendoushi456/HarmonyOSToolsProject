import path from 'path'
import { coreParameter } from '@ohos/hvigor/src/base/internal/data/global-core-parameters';
import { injectNativeModules } from 'flutter-hvigor-plugin';

// Flutter 的 OHOS Hvigor 插件默认同时注入 arm64 与 x86_64 引擎。
// 真机工程默认只构建 ARM64，以减小 HAP 并缩短部署时间；命令行或设备启动时
// 已传入 TARGET_PLATFORM 的值始终优先，因此仍可显式构建模拟器 x86_64 包。
if (!coreParameter.extParams.TARGET_PLATFORM) {
  coreParameter.extParams = {
    ...coreParameter.extParams,
    TARGET_PLATFORM: 'ohos-arm64',
  };
}

injectNativeModules(__dirname, path.dirname(__dirname))
