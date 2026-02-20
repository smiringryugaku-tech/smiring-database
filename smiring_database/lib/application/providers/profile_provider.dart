import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smiring_database/infrastructure/supabase/supabase_client.dart';

// 1. 状態を管理するNotifierクラス
class ProfileNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async {
    // 初期化時にデータを取得する
    return _fetchProfile();
  }

  // Supabaseからデータを取ってくる処理
  Future<Map<String, dynamic>?> _fetchProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    return await supabase
        .from('basic_profile_info')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading(); // 一旦ローディング状態にする
    state = await AsyncValue.guard(() => _fetchProfile()); // データを取り直す
  }
}

// 2. 他のファイルからこの状態にアクセスするためのProvider
final profileProvider = AsyncNotifierProvider<ProfileNotifier, Map<String, dynamic>?>(() {
  return ProfileNotifier();
});