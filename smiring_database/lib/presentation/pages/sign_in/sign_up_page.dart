import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smiring_database/app/routes.dart'; 
import 'package:smiring_database/infrastructure/supabase/supabase_client.dart'; 

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // 4つの入力用コントローラー
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _signupCodeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- 新規登録ロジック ---
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {

      final code = _signupCodeController.text.trim();

      // 1. まずRPCを使って、コードが正しいか確認する
      final bool isValidCode = await supabase.rpc('check_signup_code', params: {
        'code_to_check': code,
      });

      // 2. 間違っていたら、ここで自然な日本語のエラーを出して終了！
      if (!isValidCode) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('サインアップコードが正しくありません。'), // ← 好きな文章にできます
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // ここで処理を止めるので、謎のエラー画面には行きません
      }
      
      // Supabaseでサインアップ
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        
        data: {
          'display_name': _usernameController.text.trim(), // 要望通り display_name へ
          'signup_code': _signupCodeController.text.trim(), // 門番への提出用コード
        },
      );

      if (mounted) {
        if (response.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('確認メールを送信しました。'),
              backgroundColor: Colors.green,
            ),
          );
          context.go(AppRoutes.signIn);
        } else {
          // 成功！
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登録完了！')),
          );
        }
      }
    } on AuthException catch (e) {
      // さっきSQLで設定した「無効なサインアップコードです...」というエラーはここでキャッチされます
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: ${e.message}'), // Supabaseからのメッセージを表示
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('予期せぬエラーが発生しました'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _signupCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 800;

    return Scaffold(
      body: Row(
        children: [
          // --- 左側：ロゴエリア（SignInと同じデザイン） ---
          if (!isSmallScreen)
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.asset(
                          'assets/images/SmiRing_logo_temp.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Join SmiRing DB',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // --- 右側：入力フォームエリア ---
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isSmallScreen) ...[
                          const Center(
                             child: Text('SmiRing DB', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                          ),
                          const SizedBox(height: 32),
                        ],

                        const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // 1. ユーザーネーム
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'ユーザーネームを入力してください' : null,
                        ),
                        const SizedBox(height: 16),

                        // 2. Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty || !value.contains('@')) 
                                  ? '正しいメールアドレスを入力してください' : null,
                        ),
                        const SizedBox(height: 16),

                        // 3. パスワード
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              (value == null || value.length < 6) ? 'パスワードは6文字以上で入力してください' : null,
                        ),
                        const SizedBox(height: 16),

                        // 4. ログインコード
                        TextFormField(
                          controller: _signupCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Sign Up Code',
                            prefixIcon: Icon(Icons.vpn_key_outlined), // 鍵っぽいアイコン
                            border: OutlineInputBorder(),
                            helperText: '管理者から配布されたコードを入力してください', // 補足説明
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'ログインコードを入力してください' : null,
                        ),
                        const SizedBox(height: 24),

                        // 登録ボタン
                        ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Text('Sign Up', style: TextStyle(fontSize: 16)),
                        ),

                        const SizedBox(height: 16),

                        // ログイン画面へ戻るボタン
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?"),
                            TextButton(
                              onPressed: () {
                                // ログイン画面へ戻る (履歴に追加ではなく、戻る動作)
                                if (context.canPop()) {
                                   context.pop();
                                } else {
                                   context.go(AppRoutes.signIn);
                                }
                              },
                              child: const Text('Sign In'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}