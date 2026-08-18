import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 展示违章处理、汽车养护等条目的 Markdown 内容。
///
/// 项目内的内容仅使用标题、段落、列表、分隔线和加粗；在不额外引入
/// `flutter_markdown` 依赖的前提下，使用轻量渲染器展示这些格式。
class MarkdownPage extends StatelessWidget {
  final String title;
  final String content;

  const MarkdownPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.markdownBlue,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: SafeArea(
        top: false,
        child: SelectionArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: _MarkdownContent(content: content).buildBlocks(),
          ),
        ),
      ),
    );
  }
}

class _MarkdownContent {
  final String content;

  const _MarkdownContent({required this.content});

  List<Widget> buildBlocks() {
    final lines = content.trim().split('\n');
    final blocks = <Widget>[];

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        blocks.add(const SizedBox(height: 10));
      } else if (line == '---') {
        blocks.add(const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: Color(0xFFE4E4E4)),
        ));
      } else if (line.startsWith('### ')) {
        blocks.add(_textBlock(line.substring(4), 18, FontWeight.w600));
      } else if (line.startsWith('## ')) {
        blocks.add(_textBlock(line.substring(3), 20, FontWeight.w700));
      } else if (line.startsWith('# ')) {
        blocks.add(_textBlock(line.substring(2), 24, FontWeight.w700));
      } else if (line.startsWith('- ')) {
        blocks.add(_listBlock('•', line.substring(2)));
      } else if (_orderedListPattern.hasMatch(line)) {
        final match = _orderedListPattern.firstMatch(line)!;
        blocks.add(_listBlock('${match.group(1)}.', match.group(2)!));
      } else {
        blocks.add(_textBlock(line, 15, FontWeight.w400));
      }
    }

    return blocks;
  }

  static final RegExp _orderedListPattern = RegExp(r'^(\d+)\.\s+(.+)$');

  Widget _textBlock(String text, double fontSize, FontWeight fontWeight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            color: const Color(0xFF303030),
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: 1.65,
          ),
          children: _inlineSpans(text),
        ),
      ),
    );
  }

  Widget _listBlock(String marker, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              marker,
              style: const TextStyle(
                color: Color(0xFF303030),
                fontSize: 15,
                height: 1.65,
              ),
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  color: Color(0xFF303030),
                  fontSize: 15,
                  height: 1.65,
                ),
                children: _inlineSpans(text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _inlineSpans(String text) {
    final spans = <TextSpan>[];
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    var start = 0;

    for (final match in boldPattern.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans.isEmpty ? <TextSpan>[TextSpan(text: text)] : spans;
  }
}
