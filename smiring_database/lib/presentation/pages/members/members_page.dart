import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MembersPage extends ConsumerWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // 全体の背景を少しグレーにしてカードを目立たせる
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ヘッダー部分（タイトル ＆ 検索バー） ---
            Padding(
              padding: const EdgeInsets.only(top: 64),
              child: Row(
                children: [
                  // 左側：タイトル
                  const Text(
                    'Our Members',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // 余白（検索バーを中央付近に寄せるため）
                  const SizedBox(width: 40),

                  // 中央：検索バー
                  Expanded(
                    flex: 2,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500), // 検索バーが広がりすぎないように制限
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search members by name, university, major...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0), // 高さをスッキリさせる
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none, // 枠線を消してモダンに
                          ),
                        ),
                        onChanged: (value) {
                          // TODO: ここでRiverpodの検索用プロバイダーの値を更新する
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 40,), 
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // --- 2. メンバー一覧（GridView） ---
            Expanded(
              child: GridView.builder(
                // MaxCrossAxisExtent を使うと「1つのカードの最大幅」を指定でき、
                // 画面幅に合わせて自動で列数を調整してくれます（レスポンシブ！）
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 500, // カードの最大幅
                  mainAxisExtent: 300,     // カードの縦幅（固定）
                  crossAxisSpacing: 32,    // 横の隙間
                  mainAxisSpacing: 32,     // 縦の隙間
                ),
                itemCount: 12, // 仮のデータ件数
                itemBuilder: (context, index) {
                  return _MemberCard(index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 個別のプロフィールカード ---
class _MemberCard extends StatelessWidget {
  final int index;
  
  const _MemberCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: タップしたらその人の詳細プロフィール画面(ProfilePageの他己紹介版)へ遷移
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // --- 左側 (1): 丸いプロフィール画像 ---
              Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/profile_photo_empty.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // --- 右側 (2): テキスト情報 ---
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, // 上下中央揃え
                  children: [
                    // 名前
                    Text(
                      'Taro SmiRing $index',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // アイコン付き情報（国、大学、専攻）
                    _buildIconText(Icons.location_on_outlined, 'America'),
                    _buildIconText(Icons.school_outlined, 'SmiRing University'),
                    _buildIconText(Icons.work_outline, 'Computer Science'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 小さい文字とアイコンを並べるヘルパーメソッド
  Widget _buildIconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // 長すぎたら「...」にする
            ),
          ),
        ],
      ),
    );
  }
}