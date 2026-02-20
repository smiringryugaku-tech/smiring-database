import 'package:flutter/material.dart';


class MainLayout extends StatelessWidget {
  final Widget child; // 中身を入れ替えるための枠

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 1. Global Nav Bar (AppBar) ---
      appBar: AppBar(
        // 背景色（Webっぽく少し色をつけても良いですし、白でもOK）
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        // 左側のハンバーガーメニュー (ダミー)
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            debugPrint("ハンバーガーメニューが押されました");
          },
        ),

        // 真ん中のタイトル (左寄せ)
        // centerTitle: false にすることで左寄せを強制します
        centerTitle: false,
        title: const Text(
          'SmiRing Database',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // --- 2. ボディ (中身) ---
      body: child,

      // --- 3. Floating Button (左下 & チャット) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("チャットボタンが押されました");
        },
        child: const Icon(Icons.chat),
      ),
      // ここで配置場所を決めます。startFloat = 左下
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}