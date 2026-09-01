# Wi-Fi migration boundary

This migration ports the user-facing `ToolsWifiHomeFragment` flow into Flutter while keeping platform access behind the existing MVVM layers:

`WifiPage -> WifiViewModel -> WifiRepository -> WifiService -> WifiNativeChannel -> ohos WifiPlugin`

## Ported

- Android header background, title, connection card, SSID/operator/no-network states.
- Wi-Fi scan cache loading, scan-complete event refresh, de-duplication and RSSI sorting.
- Single-column Wi-Fi cards, signal/security assets, connected-state styling and system Wi-Fi settings handoff.
- One-second network and traffic polling, including the Android 1024-based byte unit formatting.
- HarmonyOS runtime location authorization for real SSID and nearby scan results.

## Explicitly excluded

- The Android "优化提速"/accelerator flow and its activities, as requested.
- Android-only Activities, Fragments, RecyclerView adapters, Volley calls and ProGuard configuration.
- `build/`, `.appanalyzer/`, `.DS_Store`, `junkcode` and mapping outputs. These are ignored and are not migration inputs.
- Android Wi-Fi assets are copied with a `toolbox_` prefix and referenced only through `AppAssets` to avoid resource collisions.

## Dependency policy

The Flutter project keeps one package source/version per capability in `pubspec.yaml`; HarmonyOS implementations are selected through the existing `*_ohos` git packages and the single `dependency_overrides.image_picker` entry. No Android Gradle dependencies or ProGuard rules are introduced into the Flutter/HarmonyOS build.
