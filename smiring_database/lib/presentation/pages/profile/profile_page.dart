import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smiring_database/application/providers/profile_provider.dart';
import 'package:smiring_database/infrastructure/supabase/supabase_client.dart';
import 'package:smiring_database/presentation/widgets/photo_edit_modal.dart';
import 'package:smiring_database/presentation/widgets/profile_info.dart';
import 'package:smiring_database/presentation/widgets/text_edit_modal.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {

  final profileAsyncValue = ref.watch(profileProvider);

    // 2. 写真変更処理 (buildの中に書くことで ref と context がそのまま使えます)
    Future<void> handleAvatarEdit() async {
      final newUrl = await showPhotoEditModal(context);

      if (newUrl != null) {
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
    }
    
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 左側：プロフィールサマリー & 写真一覧 (Flex: 1) ---
          Expanded(
            flex: 1,
            child: Container(
              // 背景を少しグレーにしてエリアを区切る
              color: Colors.grey[50],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: profileAsyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => const Center(child: Text('エラーが発生しました')),
                data: (profileData) {
                  // DBからURLを取り出す
                  final avatarUrl = profileData?['avatar_link'] as String?;
                  
                  // URLの有無で表示する画像を決定
                  final ImageProvider imageProvider = (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : const AssetImage('assets/images/profile_photo_empty.png') as ImageProvider;

              return Column(
                children: [
                  // 1. 大きな丸いプロフィール写真
                  AspectRatio( // 正方形の比率を保つ
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

                  Expanded(
                    child: GridView.builder(
                      // グリッドの設定
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8, // 横の隙間
                        mainAxisSpacing: 8,  // 縦の隙間
                        childAspectRatio: 1.0, // 正方形にする
                      ),
                      itemCount: 20, // 仮で20枚
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8), // 角を少し丸く
                          child: Image.asset(
                            'assets/images/photo_empty.png',
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );}, )
            ),
          ),

          // --- 右側：メインコンテンツ (Flex: 4) ---
          Expanded(
            flex: 2,
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

class _ProfileEditorPanel extends ConsumerWidget { // ★ StatefulWidgetからConsumerWidgetに変更！
  const _ProfileEditorPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) { // ★ WidgetRef ref を追加
    // 1. Providerからプロフィールデータを監視
    final profileAsyncValue = ref.watch(profileProvider);

    // 2. データの取得状態によって表示を出し分ける
    return profileAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(child: Text('エラーが発生しました')),
      data: (profileData) {
        // データがnullの場合は空のMapとして扱う
        final data = profileData ?? {};

        // --- 編集＆保存処理 (buildの中に書くことでrefとcontextが使えます) ---
        Future<void> handleEdit(String key, String title) async {
          final currentValue = data[key]?.toString() ?? '';

          final newValue = await showTextEditModal(
            context,
            title: title,
            initialValue: currentValue,
          );

          if (newValue != null && newValue != currentValue) {
            try {
              final userId = supabase.auth.currentUser!.id;

              // Supabaseを更新
              await supabase.from('basic_profile_info').upsert({
                'id': userId,
                key: newValue,
                'updated_at': DateTime.now().toIso8601String(),
              });

              ref.read(profileProvider.notifier).refresh();

            } catch (e) {
              debugPrint('保存に失敗しました: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('保存に失敗しました'), backgroundColor: Colors.red),
                );
              }
            }
          }
        }

        // --- 画面のUI構築 ---
        return ListView(
          padding: const EdgeInsets.all(40),
          children: [
            const Text('Profile Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),

            // --- セクション1: Name ---
            _buildSectionTitle('Basic Information'),
            ProfileInfoRow(
              title: 'Name (English)',
              value: data['name_english'] ?? '',
              onEdit: () => handleEdit('name_english', 'Name (English)'),
              children: [
                ProfileInfoRow(
                  title: 'Name (Kanji)',
                  value: data['name_kanji'] ?? '',
                  onEdit: () => handleEdit('name_kanji', 'Name (Kanji)'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- セクション2: Background & Education ---
            _buildSectionTitle('Background & Education'),
            ProfileInfoRow(
              title: 'Birthday',
              value: data['birthday'] ?? '',
              onEdit: () => handleEdit('birthday', 'Birthday'),
            ),
            ProfileInfoRow(
              title: 'Hometown',
              value: data['hometown'] ?? '',
              onEdit: () => handleEdit('hometown', 'Hometown'),
            ),
            ProfileInfoRow(
              title: 'Study Abroad Country',
              value: data['study_abroad_country'] ?? '',
              onEdit: () => handleEdit('study_abroad_country', 'Study Abroad Country'),
              children: [
                ProfileInfoRow(
                  title: 'City',
                  value: data['study_aborad_city'] ?? '',
                  onEdit: () => handleEdit('study_aborad_city', 'City'),
                ),
                ProfileInfoRow(
                  title: 'Type',
                  value: data['study_abroad_type'] ?? '',
                  onEdit: () => handleEdit('study_abroad_type', 'Type'),
                ),
                ProfileInfoRow(
                  title: 'History',
                  value: data['study_abroad_history'] ?? '',
                  onEdit: () => handleEdit('study_abroad_history', 'History'),
                ),
                ProfileInfoRow(
                  title: 'English School',
                  value: data['english_school'] ?? '',
                  onEdit: () => handleEdit('english_school', 'English School'),
                ),
              ],
            ),
            ProfileInfoRow(
              title: 'Current School',
              value: data['current_school'] ?? '',
              onEdit: () => handleEdit('current_school', 'Current School'),
              children: [
                ProfileInfoRow(
                  title: 'School History',
                  value: data['school_history'] ?? '',
                  onEdit: () => handleEdit('school_history', 'School History'),
                ),
              ],
            ),
            ProfileInfoRow(
              title: 'Grade Level',
              value: data['grade_level'] ?? '',
              onEdit: () => handleEdit('grade_level', 'Grade Level'),
            ),
            ProfileInfoRow(
              title: 'Majors',
              value: data['majors'] ?? '',
              onEdit: () => handleEdit('majors', 'Majors'),
              children: [
                ProfileInfoRow(
                  title: 'Minors',
                  value: data['minors'] ?? '',
                  onEdit: () => handleEdit('minors', 'Minors'),
                ),
                ProfileInfoRow(
                  title: 'Major History',
                  value: data['major_history'] ?? '',
                  onEdit: () => handleEdit('major_history', 'Major History'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- セクション3: Personal Identity ---
            _buildSectionTitle('Personal Identity'),
            ProfileInfoRow(
              title: 'Personality',
              value: data['personality'] ?? '',
              onEdit: () => handleEdit('personality', 'Personality'),
            ),
            ProfileInfoRow(
              title: 'Important Values',
              value: data['important_values'] ?? '',
              onEdit: () => handleEdit('important_values', 'Important Values'),
            ),
            ProfileInfoRow(
              title: 'Future Image',
              value: data['future_image'] ?? '',
              onEdit: () => handleEdit('future_image', 'Future Image'),
            ),

            const SizedBox(height: 32),

            // --- セクション4: SmiRing ---
            _buildSectionTitle('SmiRing Info'),
            ProfileInfoRow(
              title: 'Department',
              value: data['smiring_department'] ?? '',
              onEdit: () => handleEdit('smiring_department', 'Department'),
            ),
            ProfileInfoRow(
              title: 'Join Date',
              value: data['smiring_join_date'] ?? '',
              onEdit: () => handleEdit('smiring_join_date', 'Join Date'),
            ),
          ],
        );
      },
    );
  }

  // セクションのタイトル用ヘルパーメソッド
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700),
      ),
    );
  }
}