import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ↓ お使いの環境に合わせてパスを調整してください
import 'package:smiring_database/app/routes.dart'; 
import 'package:smiring_database/infrastructure/supabase/supabase_client.dart'; 

class MainLayout extends StatelessWidget {
  final Widget child; // 中身を入れ替えるための枠

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 1. Global Nav Bar (AppBar) ---
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        // 💡 leadingは削除！ 
        // 下で `drawer` を設定すると、Flutterが自動的にハンバーガーメニューを表示してくれます。

        centerTitle: false,
        title: const Text(
          'SmiRing Database',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // --- 🌟 追加：横から出てくるメニュー (Drawer) ---
      drawer: Drawer(
        child: SafeArea( // スマホのノッチなどに被らないようにする
          child: Column(
            children: [
              // --- メニュー上部 ---
              // 今後「設定」や「ホーム」などのメニューを追加する場合はここに書きます
              const SizedBox(height: 16),
              const Text(
                'Menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              
              // --- 余白 ---
              // Expanded を使うことで、これより下の要素を「一番下」に押しやります
              const Spacer(), 

              // --- メニュー下部（ログアウト） ---
              const Divider(height: 1), // うすい区切り線
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'ログアウト',
                  style: TextStyle(
                    color: Colors.red, // 赤文字にする
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  // 1. まずドロワー（メニュー）を閉じる
                  Navigator.of(context).pop();

                  // 2. Supabaseからログアウトする
                  await supabase.auth.signOut();

                  // 3. ログイン画面（またはWelcome画面）に戻る
                  if (context.mounted) {
                    context.go(AppRoutes.welcome); // ※ .signIn など適宜変更してください
                  }
                },
              ),
              const SizedBox(height: 16), // 画面一番下とのちょっとした余白
            ],
          ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}