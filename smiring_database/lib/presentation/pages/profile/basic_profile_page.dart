import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smiring_database/application/providers/profile_provider.dart';
import 'package:smiring_database/infrastructure/supabase/supabase_client.dart';
import 'package:smiring_database/presentation/widgets/profile_info.dart';
import 'package:smiring_database/presentation/widgets/text_edit_modal.dart';


class BasicInfoPage extends ConsumerWidget {
  const BasicInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(profileProvider);

    return profileAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(child: Text('エラーが発生しました')),
      data: (profileData) {
        final data = profileData ?? {};

        // 保存処理
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
              await supabase.from('basic_profile_info').upsert({
                'id': userId,
                key: newValue,
                'updated_at': DateTime.now().toIso8601String(),
              });
              ref.read(profileProvider.notifier).refresh();
            } catch (e) {
              debugPrint('保存に失敗しました: $e');
            }
          }
        }

        return ListView(
          padding: const EdgeInsets.all(40),
          children: [
            _buildSectionTitle('Name'),
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