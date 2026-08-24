import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../viewmodels/outdoor_dashboard_view_model.dart';
import 'widgets/outdoor_dashboard_widgets.dart';

/// Android AltitudeFragment 的 Flutter 页面。
class AltitudePage extends ConsumerStatefulWidget {
  const AltitudePage({super.key});

  @override
  ConsumerState<AltitudePage> createState() => _AltitudePageState();
}

class _AltitudePageState extends ConsumerState<AltitudePage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(outdoorDashboardViewModelProvider);
    final viewModel = ref.read(outdoorDashboardViewModelProvider.notifier);
    return _OutdoorScaffold(
      title: '高原海拔助手',
      children: [
        OutdoorCompass(heading: state.heading),
        LocationInfoCard(
          location: state.location,
          isLoading: state.isLocationLoading,
          needsPermission: state.needsLocationPermission,
          error: state.locationError,
          onRequestPermission: viewModel.requestLocation,
        ),
        const SizedBox(height: 16),
        OutdoorMetricGrid(
            metrics: altitudeMetrics(state.weather, state.airQuality)),
        const SizedBox(height: 16),
        AltitudeCard(altitude: state.location?.altitude),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _OutdoorScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _OutdoorScaffold({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: [
          Positioned.fill(
            child:
                Image.asset(AppAssets.outdoorHomeBackground, fit: BoxFit.fill),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF1265A9).withValues(alpha: .28),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(children: [
              SizedBox(
                height: 50,
                child: Center(
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              Expanded(
                  child:
                      SingleChildScrollView(child: Column(children: children))),
            ]),
          ),
        ]),
      );
}
