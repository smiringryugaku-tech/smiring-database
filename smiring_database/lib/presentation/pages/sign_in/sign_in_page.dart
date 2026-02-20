import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smiring_database/app/routes.dart';
import 'package:smiring_database/infrastructure/supabase/supabase_client.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- ログインロジック ---
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // 成功した場合の遷移は Routerの redirect が自動でやってくれるので
      // ここには何も書かなくてOKです！
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 画面のサイズ
    final size = MediaQuery.of(context).size;
    // スマホなど画面が狭いときは左側（ロゴエリア）を隠す判定
    final isSmallScreen = size.width < 800;

    return Scaffold(
      body: Row(
        children: [
          // --- 左側：ロゴエリア（画面が広い時だけ表示） ---
          if (!isSmallScreen)
            Expanded(
              flex: 1, // 左側 50%
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ロゴ画像
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
                        'SmiRing Database',
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
            flex: 1, // 右側 50%
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  // フォームが横に広がりすぎないように最大幅を指定
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // スマホの時だけここに小さくロゴを出すのもアリ
                        if (isSmallScreen) ...[
                          const Center(
                             child: Text('SmiRing DB', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                          ),
                          const SizedBox(height: 32),
                        ],

                        const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // メールアドレス入力
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'メールアドレスを入力してください';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // パスワード入力
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true, // 文字を隠す
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'パスワードを入力してください';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('For test use: '),
                            Row(
                              children: [
                                const Text('Email: smiring.ryugaku@gmail.com'),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 20),
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      const ClipboardData(text: "smiring.ryugaku@gmail.com"),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Email copied to clipboard')),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('Password: SmiRingTech'),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 20),
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      const ClipboardData(text: "SmiRingTech"),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Password copied to clipboard')),
                                    );
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ログインボタン
                        ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
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
                              : const Text('Login', style: TextStyle(fontSize: 16)),
                        ),

                        const SizedBox(height: 16),

                        // パスワード忘れ & 新規登録
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                context.push(AppRoutes.forgotPassword);
                              },
                              child: const Text('Forgot Password?'),
                            ),
                            TextButton(
                              onPressed: () {
                                // 新規登録画面へ
                                context.push(AppRoutes.signUp);
                              },
                              child: const Text('Create Account'),
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