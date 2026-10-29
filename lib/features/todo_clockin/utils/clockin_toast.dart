// 通用提示 - 对齐 Android com.p.a_b.utils.SimpleToast
import 'package:flutter/material.dart';

void showClockinToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 1500),
      behavior: SnackBarBehavior.floating,
    ));
}
