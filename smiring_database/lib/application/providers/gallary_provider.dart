import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smiring_database/infrastructure/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 自分のギャラリー画像の公開URLリストを取得するProvider
final myGalleryProvider = FutureProvider<List<String>>((ref) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  try {
    // 1. 'gallery' バケット内の 自分のID(userId) フォルダの中身をリストアップ
    final List<FileObject> files = await supabase
        .storage
        .from('gallery')
        .list(path: userId);

    // 2. 取得したファイル情報から「公開URL」のリストを作成する
    final List<String> imageUrls = files
        // ※フォルダ作成時にできる見えない設定ファイルなどを除外する
        .where((file) => file.name.isNotEmpty && !file.name.startsWith('.'))
        .map((file) {
          // publicUrlを生成 (バケット名/フォルダ名/ファイル名)
          return supabase.storage.from('gallery').getPublicUrl('$userId/${file.name}');
        })
        .toList();

    return imageUrls; // URLのリスト(List<String>)を返す
  } catch (e) {
    // フォルダがまだ存在しない場合などもここでキャッチされる
    return [];
  }
});