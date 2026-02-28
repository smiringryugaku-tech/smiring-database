import 'dart:typed_data';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smiring_database/infrastructure/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// どこからでもこのサービスを呼び出せるようにするProvider
final galleryServiceProvider = Provider((ref) => GalleryService());

class GalleryService {
  
  /// 画像をStorageにアップロードし、同時にDatabaseにメタデータを記録する
  Future<String> uploadAndSaveToGallery({
    required Uint8List imageBytes,
    required String fileExtension,
    List<String> tags = const [],
    String imageType = 'photo',
  }) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // Storageに保存する際のファイルパス (例: 1234-abcd/gallery_1690000000.png)
      final storagePath = '$userId/gallery_$timestamp.$fileExtension';

      // 1. Storageの 'gallery' バケットに画像をアップロード
      await supabase.storage.from('gallery').uploadBinary(
        storagePath,
        imageBytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: 'image/$fileExtension',
        ),
      );

      // 2. 表示用の公開URL (Public URL) を取得
      final imageUrl = supabase.storage.from('gallery').getPublicUrl(storagePath);

      // 3. Databaseの 'gallery' テーブルに行をInsert
      // ※ idとcreated_atはSupabase側で自動生成されるので送らなくてOK
      await supabase.from('gallery').insert({
        'user_id': userId,
        'image_url': imageUrl,
        'storage_path': storagePath,
        'image_type': imageType,
        'tags': tags,
      });

      return imageUrl; // 成功したらURLを返す
      
    } catch (e) {
      // エラーが起きたら呼び出し元に伝える
      throw Exception('画像のアップロードに失敗しました: $e');
    }
  }
  
  /// (おまけ) StorageとDatabaseから画像を削除する関数も作っておくと便利です！
  Future<void> deleteGalleryImage(String storagePath) async {
    // 1. DBから削除 (RLSがあるので自分の画像しか消せません)
    await supabase.from('gallery').delete().eq('storage_path', storagePath);
    // 2. Storage本体から削除
    await supabase.storage.from('gallery').remove([storagePath]);
  }
}