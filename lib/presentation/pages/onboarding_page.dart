import 'package:flutter/material.dart';

import '../../features/bootstrap/app_view_model.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.viewModel});

  final AppViewModel viewModel;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    _OnboardingContent(
        '食谱应用程序\n顶级厨师食谱', Color(0xFF81D4FA), Icons.menu_book_outlined),
    _OnboardingContent(
        '加入厨师\n轻松添加您的食谱。', Color(0xFFF48FB1), Icons.restaurant_menu),
    _OnboardingContent('评论\n评价和评论食谱。', Color(0xFFB39DDB), Icons.star_outline),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (index) => setState(() => _index = index),
        itemBuilder: (context, index) {
          final page = _pages[index];
          return Container(
            color: page.color,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  Icon(page.icon, color: Colors.white, size: 108),
                  const SizedBox(height: 30),
                  Text(
                    page.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 28, height: 1.4),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (dotIndex) => Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: dotIndex == _index
                              ? Colors.white
                              : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _next,
                      child: Text(
                        _index == _pages.length - 1 ? '开始' : '下一步',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _next() async {
    if (_index == _pages.length - 1) {
      await widget.viewModel.completeOnboarding();
    } else {
      await _controller.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }
}

class _OnboardingContent {
  const _OnboardingContent(this.message, this.color, this.icon);
  final String message;
  final Color color;
  final IconData icon;
}
