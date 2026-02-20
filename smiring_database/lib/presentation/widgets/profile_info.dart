import 'package:flutter/material.dart';

class ProfileInfoRow extends StatefulWidget {
  final String title;
  final String value;
  final VoidCallback onEdit;
  final List<ProfileInfoRow> children; // 子要素のリスト

  const ProfileInfoRow({
    super.key,
    required this.title,
    required this.value,
    required this.onEdit,
    this.children = const [], // デフォルトは空（子なし）
  });

  @override
  State<ProfileInfoRow> createState() => _ProfileInfoRowState();
}

class _ProfileInfoRowState extends State<ProfileInfoRow> {
  bool _isExpanded = false; // アコーディオンの開閉状態

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- メインの行 ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // 開閉ボタン（子がいる場合のみ表示、いなければ見えないスペース）
              if (hasChildren)
                IconButton(
                  icon: Icon(_isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                const SizedBox(width: 24), // アイコンと同じ幅の余白を空けて縦を揃える

              const SizedBox(width: 8),

              // 左側：Key
              Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),

              const Spacer(), // 真ん中の余白を自動で埋める

              // 右側：Value
              Text(
                widget.value.isEmpty ? '未設定' : widget.value,
                style: TextStyle(
                  color: widget.value.isEmpty ? Colors.grey.shade400 : Colors.black87,
                ),
              ),
              const SizedBox(width: 16),

              // 編集ボタン
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                onPressed: widget.onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),

        // --- 子要素（アコーディオン部分） ---
        if (hasChildren && _isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 32.0), // 子は少し右にずらす
            child: Column(
              children: widget.children,
            ),
          ),
        
        const Divider(height: 1), // 区切り線
      ],
    );
  }
}