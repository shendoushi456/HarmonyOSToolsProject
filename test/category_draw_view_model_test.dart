import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:qingman_weather/features/life_tools/viewmodels/category_draw_view_model.dart';

void main() {
  testWidgets('索引色线稿会标准化为无调色板的 RGBA 图片', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final viewModel = container.read(categoryDrawViewModelProvider.notifier);

    // gp2_2 是索引色 PNG，覆盖原先“选色变黑”的素材类型。
    await viewModel.initImage(2, 2);
    final initial = container.read(categoryDrawViewModelProvider).initialBytes!;
    final initialImage = img.decodeImage(initial)!;
    expect(initialImage.hasPalette, isFalse);
    expect(initialImage.numChannels, 4);
  });
}
