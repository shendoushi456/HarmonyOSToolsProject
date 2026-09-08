import 'package:flutter/material.dart';

import '../../features/bootstrap/app_view_model.dart';
import 'home_page.dart';
import 'onboarding_page.dart';
import 'privacy_consent_page.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key, required this.viewModel});

  final AppViewModel viewModel;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) return const _LaunchPage();
        if (widget.viewModel.loadError != null) {
          return _LoadErrorPage(viewModel: widget.viewModel);
        }
        if (!widget.viewModel.isPrivacyAccepted) {
          return PrivacyConsentPage(viewModel: widget.viewModel);
        }
        if (!widget.viewModel.isOnboardingDone) {
          return OnboardingPage(viewModel: widget.viewModel);
        }
        return HomePage(viewModel: widget.viewModel);
      },
    );
  }
}

class _LaunchPage extends StatelessWidget {
  const _LaunchPage();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(image: AssetImage('assets/images/recipes_tools/ic_logo.png'), width: 72, height: 72),
              SizedBox(height: 24),
              Text('乐熊菜谱',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
}

class _LoadErrorPage extends StatelessWidget {
  const _LoadErrorPage({required this.viewModel});

  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 52),
                const SizedBox(height: 16),
                const Text('食谱数据加载失败，请重试。'),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: viewModel.initialize, child: const Text('重新加载')),
              ],
            ),
          ),
        ),
      );
}
