import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// PDF 密码输入弹窗
class PdfPasswordDialog extends StatefulWidget {
  final String? errorText;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PdfPasswordDialog({
    super.key,
    this.errorText,
    required this.onPasswordChanged,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<PdfPasswordDialog> createState() => _PdfPasswordDialogState();
}

class _PdfPasswordDialogState extends State<PdfPasswordDialog> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('输入 PDF 密码'),
      content: TextField(
        autofocus: true,
        obscureText: _obscure,
        decoration: InputDecoration(
          labelText: '密码',
          errorText: widget.errorText,
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        onChanged: widget.onPasswordChanged,
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('取消')),
        ElevatedButton(
          onPressed: widget.onConfirm,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.qmtqBlue),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
