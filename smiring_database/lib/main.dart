import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

const supabaseUrl = 'https://ivkdyeubbiyjdavpskjv.supabase.co';
const supabaseAnonKey = 'sb_publishable_R31_7PVRpDPoCQjjM0-GeA_UdBO4Sba';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}