import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../viewmodels/outdoor_dashboard_view_model.dart';
import 'widgets/outdoor_dashboard_widgets.dart';

/// Android CompassFragment 的 Flutter 页面。
class CompassPage extends ConsumerStatefulWidget {
  const CompassPage({super.key});

  @override
  ConsumerState<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends ConsumerState<CompassPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(outdoorDashboardViewModelProvider);
    final viewModel = ref.read(outdoorDashboardViewModelProvider.notifier);
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
            child:
                Image.asset(AppAssets.outdoorHomeBackground, fit: BoxFit.fill)),
        Positioned.fill(
            child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF1265A9).withValues(alpha: .28),
          ),
        )),
        SafeArea(
          bottom: false,
          child: Column(children: [
            const SizedBox(
              height: 50,
              child: Center(
                child: Text('指南针',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  OutdoorCompass(heading: state.heading),
                  if (state.isHeadingUnavailable)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('当前设备未提供方向传感器',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  LocationInfoCard(
                    location: state.location,
                    isLoading: state.isLocationLoading,
                    needsPermission: state.needsLocationPermission,
                    error: state.locationError,
                    onRequestPermission: viewModel.requestLocation,
                  ),
                  const SizedBox(height: 16),
                  OutdoorMetricGrid(
                      metrics: compassMetrics(state.location, state.weather)),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
