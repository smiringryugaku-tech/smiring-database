import 'dart:async'; // Future.delayedのために必要
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smiring_database/app/routes.dart'; // AppRoutesの定義場所に合わせてください

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    // 画面が描画されたらカウントダウン開始
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // 1. 2秒待つ
    await Future.delayed(const Duration(seconds: 2));

    // 非同期処理の間に画面が閉じられている場合は何もしない（エラー防止）
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    // 3. 画面サイズを取得
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    // 4. ロゴサイズの計算ロジック
    // 縦と横を比較して、短い方を基準にする
    final double logoSize = (screenHeight < screenWidth)
        ? screenHeight / 3 // 縦の方が短い（横長画面）
        : screenWidth / 1.5; // 横の方が短い（縦長画面）

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 上下中央揃え
          children: [
            // ロゴ
            SizedBox(
              width: logoSize,
              height: logoSize,
              child: Image.asset(
                'assets/images/SmiRing_logo_temp.png',
                fit: BoxFit.contain, // 枠内にきれいに収める
              ),
            ),
            
            const SizedBox(height: 24), // ロゴと文字の間隔
            
            // タイトル
            const Text(
              'SmiRing Database',
              style: TextStyle(
                fontSize: 32, // 大きく
                fontWeight: FontWeight.bold, // 太く
                letterSpacing: 1.2, // 少し文字間隔を空けるとオシャレに見えます
              ),
            ),
          ],
        ),
      ),
    );
  }
}