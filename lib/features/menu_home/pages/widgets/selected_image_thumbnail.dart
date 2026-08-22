import 'dart:io';
import 'package:flutter/material.dart';

/// 已选图片缩略图 + 删除按钮 - 对齐 ImageToPdfActivity grid_item_image.xml
class SelectedImageThumbnail extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;

  const SelectedImageThumbnail({
    super.key,
    required this.path,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
