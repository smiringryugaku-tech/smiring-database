// lib/presentation/widgets/photo_edit_modal.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smiring_database/infrastructure/supabase/supabase_client.dart'; // supabaseクライアントをインポート
import 'package:supabase_flutter/supabase_flutter.dart';

/// 写真を選択してアップロードし、その公開URLを返すモーダル
Future<String?> showPhotoEditModal(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false, // アップロード中は閉じられないようにする
    builder: (context) => const _PhotoEditDialog(),
  );
}

class _PhotoEditDialog extends StatefulWidget {
  const _PhotoEditDialog();

  @override
  State<_PhotoEditDialog> createState() => _PhotoEditDialogState();
}

class _PhotoEditDialogState extends State<_PhotoEditDialog> {
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _pickAndUploadImage() async {
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // 1. 画像を選択
      final picker = ImagePicker();
      // Webではギャラリーのみが基本
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600, // サイズを適度に小さくする
        imageQuality: 80, // 画質を少し落として容量節約
      );

      if (image == null) {
        // キャンセルされたらモーダルを閉じる
        if (mounted) Navigator.of(context).pop(null);
        return;
      }

      // 2. バイトデータを読み込む (Web必須)
      final imageBytes = await image.readAsBytes();
      final fileExtension = image.name.split('.').last.toLowerCase();
      final userId = supabase.auth.currentUser!.id;
      // キャッシュ対策でタイムスタンプをつける
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$userId/profile_$timestamp.$fileExtension';

      // 3. Storageにアップロード (WebはuploadBinary)
      // ※事前に 'gallery' というPublicバケットを作成しておく必要があります！
      await supabase.storage.from('gallery').uploadBinary(
            filePath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$fileExtension', // 必須
            ),
          );

      // 4. 公開URLを取得
      final imageUrl = supabase.storage.from('gallery').getPublicUrl(filePath);

      // 5. URLを返してモーダルを閉じる
      if (mounted) Navigator.of(context).pop(imageUrl);

    } on StorageException catch (e) {
      setState(() => _errorMessage = 'アップロードに失敗しました: ${e.message}');
    } catch (e) {
      setState(() => _errorMessage = 'エラーが発生しました: $e');
    } finally {
      if (mounted && _errorMessage != null) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // モーダルが開いたらすぐに画像選択を開始する
    _pickAndUploadImage();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('プロフィール写真の変更'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isUploading) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('画像をアップロード中...'),
          ] else if (_errorMessage != null) ...[
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          ] else ...[
             const Text('画像を選択してください...'),
          ]
        ],
      ),
      actions: [
        if (!_isUploading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('キャンセル'),
          ),
        if (_errorMessage != null)
           ElevatedButton(
            onPressed: _pickAndUploadImage, // 再試行
            child: const Text('再試行'),
          ),
      ],
    );
  }
}