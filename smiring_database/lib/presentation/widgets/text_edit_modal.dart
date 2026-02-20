import 'package:flutter/material.dart';

/// 汎用テキスト編集モーダルを表示し、入力された文字列を返す（キャンセルの場合はnull）
Future<String?> showTextEditModal(
  BuildContext context, {
  required String title,
  required String initialValue,
}) {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('$title の編集'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null), // キャンセル
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text), // 保存
            child: const Text('保存'),
          ),
        ],
      );
    },
  );
}