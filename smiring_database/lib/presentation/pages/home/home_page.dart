import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smiring_database/app/routes.dart';
import 'package:smiring_database/application/providers/profile_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // --- 左側：メインコンテンツ (2:1の "2") ---
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 横長ロゴ
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Image.asset(
                        'assets/images/smiring_logo_side_by_side.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Profiles セクション
                  const _HorizontalSection(
                    title: 'Profiles',
                    imageAsset: 'assets/images/profile_photo_empty.png',
                    itemTitlePrefix: 'Name',
                  ),

                  const SizedBox(height: 48),

                  // Photo Gallery セクション
                  const _HorizontalSection(
                    title: 'Photo Gallery',
                    imageAsset: 'assets/images/photo_empty.png',
                    itemTitlePrefix: 'Photo',
                  ),
                ],
              ),
            ),
          ),

          // --- 右側：後で実装 ---
          Expanded(
            flex: 1,
            // 背景色を少しつけてエリアを区別
            child: Container(
              color: Colors.grey[50], 
              // 右側のパネル全体を実装したWidgetを呼ぶ
              child: const _RightPanel(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalSection extends HookConsumerWidget {
  final String title;
  final String imageAsset;
  final String itemTitlePrefix;

  const _HorizontalSection({
    super.key,
    required this.title,
    required this.imageAsset,
    required this.itemTitlePrefix,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ★ 魔法の1行！ 
    // これだけでScrollControllerが作成され、画面が閉じる時に自動でdispose()してくれます
    final scrollController = useScrollController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: (){}, 
              child: Text("もっと見る"),
            )
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // 表示数の計算（1個あたりの最小幅を160程度と想定して調整）
            double visibleCount = (constraints.maxWidth / 160);
            if (visibleCount < 2.2) visibleCount = 2.2; // 最低でも2個とちょっと見せる
            if (visibleCount > 5.2) visibleCount = 5.2; // 最大でも5個とちょっと

            // アイテムの横幅を計算
            final itemWidth = (constraints.maxWidth - (16 * (visibleCount.floor()))) / visibleCount;

            // 高さの計算
            final itemHeight = (itemWidth * 3 / 4) + 100;

            return SizedBox(
              height: itemHeight,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 8,
                  interactive: true, // スクロールバーを直接掴めるようにする
                  radius: const Radius.circular(8),
                  child: ListView.separated(
                    controller: scrollController, // ★ リスト側にも同じコントローラーをセット
                    padding: const EdgeInsets.only(bottom: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(), // 端っこでビヨーンとならないようにする（戻る誤爆防止）
                    itemCount: 10,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return _ContentCard(
                        width: itemWidth,
                        imageAsset: imageAsset,
                        title: '$itemTitlePrefix ${index + 1}',
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  final double width;
  final String imageAsset;
  final String title;

  const _ContentCard({
    required this.width,
    required this.imageAsset,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // カード全体を角丸にする
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2, // 少し影をつける
      margin: EdgeInsets.zero, // ListViewのseparatorで間隔を調整するのでmarginは不要
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上部: 写真 (上だけ角丸の横長 4:3)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 4 / 3, // 横長比率
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 下部: ディスクリプションエリア
            Expanded( // 残りのスペースを全部使う
              child: Padding(
                padding: const EdgeInsets.all(12.0), // 内側の余白
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, // 上下中央寄せ
                  children: [
                    // タイトル
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // はみ出たら...
                    ),
                    const SizedBox(height: 4), // タイトルとインフォの間隔
                    // インフォメーション
                    Text(
                      'Some information is shown here. This text might be long.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1, // 2行まで表示（必要に応じて1行でも）
                      overflow: TextOverflow.ellipsis, // はみ出たら...
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. User Profile Section (固定高さ)
          const _UserProfileCard(),
          
          const SizedBox(height: 24),
          
          // 2. Calendar Section (カレンダーのサイズに合わせて高さ確保)
          const Text('Calendar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            elevation: 0, // フラットなデザイン
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300), // 薄い枠線
            ),
            child: Theme(
              // カレンダーのテーマを少し調整（文字サイズなど）
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).primaryColor, // 今日のハイライト色
                ),
              ),
              child: CalendarDatePicker(
                initialDate: DateTime.now(), // 今日を選択状態に
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                onDateChanged: (value) {
                  // 日付タップ時の処理（今は何もしない）
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 3. Timeline Section (残りのスペースを全部使う)
          const Text('Timeline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 10, // 仮データ数
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  return _TimelineItem(index: index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserProfileCard extends ConsumerWidget {
  const _UserProfileCard(); 

  Widget _buildInfoText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    
    final profileAsyncValue = ref.watch(profileProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push(AppRoutes.profile);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // ★ _isLoadingのif文の代わりに .when() を使って出し分けます
          child: profileAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()), // ロード中
            error: (error, stack) => const Center(child: Text('エラーが発生しました')), // エラー時
            data: (profileData) {
              // ★ ここから下は元の build メソッドの中身とほぼ同じです！
              final name = profileData?['name_english']?.toString().isNotEmpty == true 
                  ? profileData!['name_english'] 
                  : 'Name not set';
              final country = profileData?['study_abroad_country']?.toString().isNotEmpty == true 
                  ? profileData!['study_abroad_country'] 
                  : '-';
              final school = profileData?['current_school']?.toString().isNotEmpty == true 
                  ? profileData!['current_school'] 
                  : '-';
              final major = profileData?['majors']?.toString().isNotEmpty == true 
                  ? profileData!['majors'] 
                  : '-';
              
              final avatarUrl = profileData?['avatar_link'] as String?;
              final imageProvider = (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? NetworkImage(avatarUrl)
                  : const AssetImage('assets/images/profile_photo_empty.png') as ImageProvider;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 左側：写真
                  Container(
                    width: 80, 
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // 右側：テキスト情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoText(Icons.location_on_outlined, country),
                        _buildInfoText(Icons.school_outlined, school),
                        _buildInfoText(Icons.work_outline, major),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// タイムラインのアイテムWidget
class _TimelineItem extends StatelessWidget {
  final int index;
  const _TimelineItem({required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 時間表示
        SizedBox(
          width: 50,
          child: Text(
            '10:${index}0', // 適当な時間
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        // 丸ポチと線
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            // 下に続く線（最後の要素でなければ表示、など本当は制御する）
            Container(
              width: 2,
              height: 30, // 線の長さ
              color: Colors.grey[300],
            ),
          ],
        ),
        const SizedBox(width: 12),
        // 内容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Event Created $index',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Someone added a new event to the database. Check it out!',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}