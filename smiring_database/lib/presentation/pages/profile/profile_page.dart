import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smiring_database/application/providers/gallary_provider.dart';
import 'package:smiring_database/application/providers/profile_provider.dart';
import 'package:smiring_database/application/services/gallary_service.dart';
import 'package:smiring_database/infrastructure/supabase/supabase_client.dart';
import 'package:smiring_database/presentation/pages/profile/basic_profile_page.dart';
import 'package:smiring_database/presentation/widgets/photo_edit_modal.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- 1. Providerの監視 (watch) ---
    final profileAsyncValue = ref.watch(profileProvider);
    // ★ ここを追加！ ギャラリーの画像URLリストを監視します
    // ※ myGalleryProvider の部分は、gallary_provider.dart で定義した名前に合わせてください
    final galleryAsyncValue = ref.watch(myGalleryProvider); 

    // --- 2. 関数定義 ---
    Future<void> handleAvatarEdit() async {
      final newUrl = await showPhotoEditModal(context);

      if (newUrl == null) return;
      if (!context.mounted) return;

      try {
        final userId = supabase.auth.currentUser!.id;
        
        // SupabaseのDBを更新
        await supabase.from('basic_profile_info').update({
          'avatar_link': newUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
        
        ref.read(profileProvider.notifier).refresh();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('プロフィール写真を変更しました！')),
          );
        }
      } catch (e) {
        debugPrint('アバター保存失敗: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('写真の保存に失敗しました'), backgroundColor: Colors.red),
          );
        }
      }
    }
    
    // --- 3. 画面のビルド ---
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 左側：プロフィールサマリー & 写真一覧 (Flex: 1) ---
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              
              // ★ プロフィールデータの出し分け
              child: profileAsyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => const Center(child: Text('エラーが発生しました')),
                data: (profileData) {
                  
                  final avatarUrl = profileData?['avatar_link'] as String?;
                  final ImageProvider imageProvider = (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : const AssetImage('assets/images/profile_photo_empty.png') as ImageProvider;

                  return Column(
                    children: [
                      // 1. 大きな丸いプロフィール写真
                      AspectRatio(
                        aspectRatio: 1, 
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: InkWell(
                            onTap: handleAvatarEdit, 
                            customBorder: const CircleBorder(), 
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300, width: 4),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: avatarUrl == null 
                                  ? const Center(child: Icon(Icons.add_a_photo, color: Colors.grey)) 
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      const Text(
                        'My Photos',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),

                      // 2. ギャラリー画像一覧
                      Expanded(
                        // ★ ギャラリーデータの出し分け
                        child: galleryAsyncValue.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => const Center(child: Text('画像の読み込みに失敗しました')),
                          data: (imageUrls) {
                            if (imageUrls.isEmpty) {
                              return Center(
                                child: Text(
                                  'まだ写真がありません\n上のアイコンからアップロードしてみましょう！',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              );
                            }

                            return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8, 
                                mainAxisSpacing: 8,  
                                childAspectRatio: 1.0, 
                              ),
                              itemCount: imageUrls.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrls[index], 
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }, 
              ),
            ),
          ),

          // --- 右側：メインコンテンツ (Flex: 3) ---
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: Center(
                child: _ProfileEditorPanel(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// --- profile_page.dart の下半分をこれで上書き ---

class _ProfileEditorPanel extends ConsumerWidget {
  const _ProfileEditorPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Details', 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 24),
                // --- タブの切り替え部分 ---
                TabBar(
                  isScrollable: true,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(text: 'Basic Information'),
                    Tab(text: 'Detail Information'),
                  ],
                ),
              ],
            ),
          ),
          
          // --- コンテンツエリア ---
          Expanded(
            child: TabBarView(
              children: [
                const BasicInfoPage(),
                const Center(child: Text('Detail Information Content (Coming Soon)')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}