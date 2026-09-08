import 'package:flutter/material.dart';

class NetworkRecipeImage extends StatelessWidget {
  const NetworkRecipeImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ImageFallback();
    return Stack(
      fit: StackFit.expand,
      children: [
        // 保持在底层，直至网络图片实际解码出第一帧，避免加载期间留白。
        const _ImageFallback(),
        Image.network(
          url,
          fit: fit,
          filterQuality: FilterQuality.medium,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) return child;
            return const SizedBox.expand();
          },
          errorBuilder: (context, error, stackTrace) => const SizedBox.expand(),
        ),
      ],
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: Color(0xFFF6E6E5),
        child: Center(
          child: Icon(Icons.restaurant, color: Color(0xFFE36864), size: 42),
        ),
      );
}
