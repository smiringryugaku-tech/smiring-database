import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 全体を中央に寄せる
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // 外側の余白
          child: SizedBox(
            height: 300, // ボタンの高さ
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 等間隔に配置
              children: [
                
                // 1. 検索ボタン (青)
                _BigMenuButton(
                  title: '検索',
                  emoji: '🔍', // アイコンの代わりに絵文字
                  color: Colors.blue.shade100,
                  onTap: () {},
                ),

                const SizedBox(width: 24), // ボタン間の隙間

                // 2. 閲覧ボタン (緑)
                _BigMenuButton(
                  title: '閲覧',
                  emoji: '👀',
                  color: Colors.green.shade100,
                  onTap: () {},
                ),

                const SizedBox(width: 24), // ボタン間の隙間

                // 3. 入力ボタン (黄色)
                _BigMenuButton(
                  title: '入力',
                  emoji: '✏️',
                  color: Colors.amber.shade100, // 黄色はamberの方が文字が見やすいです
                  onTap: () {},
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 共通の大きなボタンウィジェット ---
class _BigMenuButton extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _BigMenuButton({
    required this.title,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Expandedを使うことで、横幅いっぱいに3等分されます
    return Expanded(
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(24), // 角丸にする
        elevation: 2, // 少しだけ影をつける
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          hoverColor: Colors.black12, // ホバーした時に少し黒を混ぜて暗くする
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 60), // 絵文字のサイズ
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}